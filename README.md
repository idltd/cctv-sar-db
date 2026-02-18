# CCTV SAR — Camera Registry

Community-maintained registry of CCTV cameras and their data controllers in the UK, used by the **[CCTV SAR app](https://idltd.github.io/CCTV-Log/)** to help people submit Subject Access Requests for footage of themselves under the UK GDPR.

---

## What's here

`cameras.json` has two sections:

### `operators` (keyed object)

Operator details are stored once and referenced by cameras, avoiding duplication.

| Field | Description |
|---|---|
| key | Short unique identifier, e.g. `tesco` or `tfl` |
| `name` | Name of the data controller (required) |
| `ico_reg` | ICO registration number (Z/ZA prefix) |
| `privacy_email` | Email address for SAR / DPO queries |
| `postal_address` | Registered address for postal correspondence |

### `cameras` (array)

| Field | Description |
|---|---|
| `id` | Unique kebab-case identifier (required) |
| `lat` / `lng` | Camera location in decimal degrees (required) |
| `location_desc` | Human-readable description of where the camera is (required) |
| `operator_id` | Key into the `operators` table (use this for known operators) |
| `operator` | Embedded operator object — use only when adding a new operator not yet in the table |
| `added` | ISO date the entry was added |

**Required:** `id`, `lat`, `lng`, `location_desc`, and either `operator_id` or `operator.name`

---

## Privacy

This registry contains **factual, publicly available information only**:

- Camera GPS locations
- Operator / data controller names
- ICO registration numbers (from the public ICO register)
- Privacy contact details (from the public ICO register or operator websites)

**No personal data about individuals is stored or accepted.**
All contributions are reviewed before going live.

---

## Contributing

### Via the CCTV SAR app *(easiest)*
After sending a SAR, the app offers to contribute the camera's location and operator details. It opens a pre-filled GitHub issue — you just confirm and submit.

### Via GitHub Issue *(no git knowledge needed)*
Use the structured submission form:

➡ **[Submit a camera →](../../issues/new?template=camera.yml)**

You'll need a free GitHub account. Your GitHub username will be visible on the issue, but no other personal information is required.

### Via Pull Request *(for git users)*
Edit `cameras.json` directly and open a PR. The CI workflow validates your entry automatically.

**Adding a camera for an operator already in the table** (e.g. a second Tesco):
```json
{
    "id": "tesco-highstreet-anytown-001",
    "lat": 51.507400,
    "lng": -0.127500,
    "location_desc": "Outside Tesco Express, High Street, Anytown — covers entrance and pavement",
    "operator_id": "tesco",
    "added": "YYYY-MM-DD"
}
```

**Adding a camera for a new operator** (include operator details inline — the maintainer will move them to the operators table on merge):
```json
{
    "id": "new-org-location-001",
    "lat": 51.507400,
    "lng": -0.127500,
    "location_desc": "Outside New Org building entrance, Example Street, Anytown",
    "operator": {
        "name": "New Organisation Ltd",
        "ico_reg": "Z1234567",
        "privacy_email": "dpo@neworg.example.com",
        "postal_address": "1 Example Street, Anytown, AB1 2CD"
    },
    "added": "YYYY-MM-DD"
}
```

**Required:** `id`, `lat`, `lng`, `location_desc`, and either `operator_id` or `operator.name`
**Optional but helpful:** `ico_reg`, `privacy_email`, `postal_address`

---

## Finding the operator's ICO registration number

1. Go to [ico.org.uk/ESDWebPages/Search](https://ico.org.uk/ESDWebPages/Search)
2. Search by the organisation's name
3. The registration number starts with **Z** or **ZA**
4. The registered DPO or data controller contact is also listed there

Most large retailers, councils, transport operators, NHS trusts and housing associations are registered.

---

## Validation

Every pull request runs an automated check that verifies:
- JSON is valid and parses correctly
- All required fields are present
- `id` values are unique
- `lat` and `lng` are within the UK bounding box (49.5°N–60.9°N, 8.2°W–1.8°E)

PRs that fail validation cannot be merged.

---

## Licence

Data is released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) — public domain, no restrictions on use.
