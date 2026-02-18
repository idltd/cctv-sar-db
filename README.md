# CCTV SAR — Camera Registry

Community-maintained registry of CCTV cameras and their data controllers in the UK, used by the [CCTV SAR app](https://github.com/idltd/CCTV-Log) to help people submit Subject Access Requests for footage of themselves.

## What's here

`cameras.json` — a structured list of known cameras with operator details (name, ICO registration number, privacy contact email, postal address).

## Privacy

This registry contains **factual, publicly available information only**:
- Camera locations (lat/lng)
- Operator names
- ICO registration numbers (public register)
- Privacy/DPO contact details (public register)

**No personal data about individuals is stored or accepted.**

## Contributing

### Via the app
If you use the [CCTV SAR app](https://github.com/idltd/CCTV-Log) after submitting a request, you can contribute the camera details anonymously — the app opens a pre-filled submission form.

### Via GitHub Issue
[Submit a camera via the issue form →](../../issues/new?template=camera.yml)

### Via Pull Request
Edit `cameras.json` directly and open a PR. The CI workflow will validate your entry automatically. Each camera entry should follow this structure:

```json
{
    "id": "unique-id",
    "lat": 51.507400,
    "lng": -0.127500,
    "location_desc": "Brief description of where the camera is",
    "operator": {
        "name": "Organisation Name",
        "ico_reg": "Z1234567",
        "privacy_email": "dpo@example.com",
        "postal_address": "Address\nTown\nPostcode"
    },
    "added": "YYYY-MM-DD"
}
```

**Required fields:** `id`, `lat`, `lng`, `location_desc`, `operator.name`

**Optional but helpful:** `ico_reg`, `privacy_email`, `postal_address`

## ICO registration lookup

ICO registration numbers can be found at: https://ico.org.uk/ESDWebPages/Search

## Licence

Data is released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) — public domain, no restrictions.
