"""
import_overpass.py — bulk-import UK chain store locations from OpenStreetMap into Supabase.

Queries the Overpass API for every operator in the Supabase operators table that has a
wikidata_id set, then upserts the resulting camera entries into the cameras table.

Usage (Windows):
    set SUPABASE_URL=https://lyijydkwitjxbcxurkep.supabase.co
    set SUPABASE_SERVICE_KEY=<your service_role key>
    py scripts/import_overpass.py

    # Dry run (print JSON, don't write to Supabase):
    py scripts/import_overpass.py --dry-run

Requirements: Python 3.8+, no third-party packages needed.
"""

import json
import os
import sys
import time
import urllib.parse
import urllib.request
from datetime import date

# ── Config ─────────────────────────────────────────────────────────────────────

SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://lyijydkwitjxbcxurkep.supabase.co")
SERVICE_KEY  = os.environ.get("SUPABASE_SERVICE_KEY", "")

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
OVERPASS_DELAY = 3  # seconds between chain queries (Overpass fair-use policy)
BATCH_SIZE = 200    # rows per Supabase upsert request
TODAY = date.today().isoformat()
DRY_RUN = "--dry-run" in sys.argv

# ── Helpers ────────────────────────────────────────────────────────────────────

def supabase_get(path):
    req = urllib.request.Request(
        f"{SUPABASE_URL}{path}",
        headers={
            "apikey": SERVICE_KEY,
            "Authorization": f"Bearer {SERVICE_KEY}",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read())

def supabase_upsert(table, rows):
    if DRY_RUN:
        print(f"  [dry-run] would upsert {len(rows)} rows into {table}")
        return
    data = json.dumps(rows).encode()
    req = urllib.request.Request(
        f"{SUPABASE_URL}/rest/v1/{table}",
        data=data,
        method="POST",
        headers={
            "apikey": SERVICE_KEY,
            "Authorization": f"Bearer {SERVICE_KEY}",
            "Content-Type": "application/json",
            "Prefer": "resolution=merge-duplicates,return=minimal",
        },
    )
    with urllib.request.urlopen(req, timeout=60) as r:
        status = r.status
    if status not in (200, 201):
        raise RuntimeError(f"Supabase upsert failed: HTTP {status}")

def overpass_query(wikidata_id):
    """Return all UK nodes/ways/relations tagged with brand:wikidata=wikidata_id."""
    query = f"""
[out:json][timeout:90];
area["ISO3166-1"="GB"][admin_level=2]->.uk;
(
  node["brand:wikidata"="{wikidata_id}"](area.uk);
  way["brand:wikidata"="{wikidata_id}"](area.uk);
  relation["brand:wikidata"="{wikidata_id}"](area.uk);
);
out center tags;
"""
    data = urllib.parse.urlencode({"data": query}).encode()
    req = urllib.request.Request(
        OVERPASS_URL,
        data=data,
        headers={"User-Agent": "CCTV-SAR-App/1.0 (https://github.com/idltd/cctv-sar-db)"},
    )
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read())

def make_camera(element, operator_id, brand_name):
    """Convert an Overpass element to a cameras row."""
    tags = element.get("tags", {})

    if element["type"] == "node":
        lat = element.get("lat")
        lng = element.get("lon")
    else:
        center = element.get("center", {})
        lat = center.get("lat")
        lng = center.get("lon")

    if lat is None or lng is None:
        return None

    # Build a human-readable location description
    name        = tags.get("name") or brand_name
    street      = tags.get("addr:street", "")
    housenumber = tags.get("addr:housenumber", "")
    city        = (tags.get("addr:city")
                   or tags.get("addr:town")
                   or tags.get("addr:suburb")
                   or "")

    addr_parts = []
    if housenumber and street:
        addr_parts.append(f"{housenumber} {street}")
    elif street:
        addr_parts.append(street)
    if city:
        addr_parts.append(city)

    location_desc = name
    if addr_parts:
        location_desc += ", " + ", ".join(addr_parts)

    # Stable ID based on OSM type + ID
    osm_id   = f"{element['type'][0]}{element['id']}"
    entry_id = f"{operator_id}-osm-{osm_id}"

    return {
        "id":            entry_id,
        "lat":           round(float(lat), 6),
        "lng":           round(float(lng), 6),
        "location_desc": location_desc[:500],  # column limit guard
        "operator_id":   operator_id,
        "source":        "openstreetmap",
        "added":         TODAY,
    }

def batches(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    if not SERVICE_KEY and not DRY_RUN:
        print("ERROR: Set SUPABASE_SERVICE_KEY environment variable.", file=sys.stderr)
        sys.exit(1)

    print("Fetching operators with wikidata_id from Supabase...")
    operators = supabase_get(
        "/rest/v1/operators?wikidata_id=not.is.null&select=id,name,wikidata_id"
    )

    if not operators:
        print("No operators with wikidata_id found. Add wikidata_id to operators first.")
        return

    print(f"Found {len(operators)} operator(s) to import:\n")
    for op in operators:
        print(f"  {op['id']:15s}  {op['name']}  ({op['wikidata_id']})")
    print()

    total_new = 0
    for op in operators:
        op_id       = op["id"]
        op_name     = op["name"]
        wikidata_id = op["wikidata_id"]

        print(f"Querying Overpass for {op_name} ({wikidata_id})...")
        try:
            result = overpass_query(wikidata_id)
        except Exception as e:
            print(f"  ERROR: {e}")
            continue

        cameras = []
        for element in result.get("elements", []):
            cam = make_camera(element, op_id, op_name)
            if cam:
                cameras.append(cam)

        print(f"  {len(cameras)} locations found")

        if cameras:
            for batch in batches(cameras, BATCH_SIZE):
                supabase_upsert("cameras", batch)
            total_new += len(cameras)
            print(f"  Upserted {len(cameras)} rows")

        if op != operators[-1]:
            print(f"  Waiting {OVERPASS_DELAY}s...")
            time.sleep(OVERPASS_DELAY)

    print(f"\nDone. {total_new} camera rows upserted across {len(operators)} operator(s).")
    if DRY_RUN:
        print("(Dry run — nothing written to Supabase)")

if __name__ == "__main__":
    main()
