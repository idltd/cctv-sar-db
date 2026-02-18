-- ── 01_schema.sql ─────────────────────────────────────────────────────────────
-- Run once in the Supabase SQL editor (Database → SQL Editor → New query)

-- PostGIS extension (available on all Supabase projects)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ── Operators ──────────────────────────────────────────────────────────────────
-- One row per data controller.  wikidata_id is used by import_overpass.py.
CREATE TABLE IF NOT EXISTS operators (
    id              text PRIMARY KEY,
    name            text NOT NULL,
    ico_reg         text,
    privacy_email   text,
    postal_address  text,
    wikidata_id     text,           -- OpenStreetMap brand:wikidata tag value
    created_at      timestamptz DEFAULT now()
);

-- ── Cameras ────────────────────────────────────────────────────────────────────
-- geom is auto-computed from lat/lng via a GENERATED column.
CREATE TABLE IF NOT EXISTS cameras (
    id              text PRIMARY KEY,
    lat             float8 NOT NULL,
    lng             float8 NOT NULL,
    geom            geometry(Point, 4326)
                        GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(lng, lat), 4326)) STORED,
    location_desc   text NOT NULL,
    operator_id     text REFERENCES operators(id),
    source          text DEFAULT 'manual',
    added           date DEFAULT CURRENT_DATE,
    created_at      timestamptz DEFAULT now()
);

-- Spatial index — essential for ST_DWithin radius queries
CREATE INDEX IF NOT EXISTS cameras_geom_idx ON cameras USING gist(geom);

-- ── Pending contributions ──────────────────────────────────────────────────────
-- Users submit here directly from the app (no GitHub account needed).
-- Reviewed in the Supabase dashboard; approved rows are moved to cameras/operators.
CREATE TABLE IF NOT EXISTS pending_cameras (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    lat             float8 NOT NULL,
    lng             float8 NOT NULL,
    location_desc   text,
    operator_name   text NOT NULL,
    ico_reg         text,
    privacy_email   text,
    postal_address  text,
    submitted_at    timestamptz DEFAULT now(),
    reviewed        boolean DEFAULT false
);
