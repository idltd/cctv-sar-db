-- ── 04_seed.sql ───────────────────────────────────────────────────────────────
-- Migrates the curated operators and cameras from cameras.json into Supabase.
-- Safe to re-run — uses ON CONFLICT DO NOTHING.

-- ── Operators ──────────────────────────────────────────────────────────────────
INSERT INTO operators (id, name, ico_reg, privacy_email, postal_address, wikidata_id) VALUES

('gstt',        'Guy''s and St Thomas'' NHS Foundation Trust',
                'Z5636970',
                'gstt.informationgovernance@nhs.net',
                'Trust Headquarters, Gassiot House, St Thomas'' Hospital, Westminster Bridge Road, London, SE1 7EH',
                NULL),

('tfl',         'Transport for London',
                'Z129176X',
                'dpo@tfl.gov.uk',
                'Data Protection Officer, Transport for London, 4th Floor, 5 Endeavour Square, London E20 1JN',
                NULL),

('networkrail', 'Network Rail Infrastructure Limited',
                'Z7071943',
                'data.protection@networkrail.co.uk',
                'Data Protection Officer, Network Rail, 1st Floor Willen, The Quadrant, Milton Keynes MK9 1EN',
                NULL),

('btp',         'Chief Constable, British Transport Police',
                'Z4882139',
                'dataprotection@btp.police.uk',
                'Data Protection & FOI Team, British Transport Police, Second Floor, 3 Callaghan Square, Cardiff CF10 5BT',
                NULL),

('met',         'Commissioner of Police of the Metropolis',
                'Z4888193',
                'DataRights@met.police.uk',
                'MPS Data Office, Metropolitan Police Service, New Scotland Yard, Victoria Embankment, London SW1A 2JL',
                NULL),

('tesco',       'Tesco Stores Limited',
                'Z6712178',
                'subjectaccess.request@tesco.com',
                'Data Protection Executive, Tesco Stores Limited, Tesco House, Shire Park, Kestrel Way, Welwyn Garden City AL7 1GA',
                'Q487494'),

('sainsburys',  'Sainsbury''s Supermarkets Ltd',
                'Z4722394',
                'privacy@sainsburys.co.uk',
                'Data Protection Officer, Privacy Team, Sainsbury''s Supermarkets Ltd, 33 Charterhouse Street, London EC1M 6HA',
                'Q950720'),

('ms',          'Marks and Spencer plc',
                'Z6046528',
                'generaldataprotectionrequests@customer-support.marksandspencer.com',
                'Data Protection, Marks and Spencer plc, Chester Business Park, Wrexham Road, Chester CH4 9GA',
                'Q714491'),

('westfield',   'Westfield Europe Limited',
                'Z5539526',
                'dpo@urw.com',
                'Data Privacy Team, Westfield Europe Limited, 4th Floor, 1 Ariel Way, London W12 7SL',
                NULL),

('nhsengland',  'NHS England',
                'Z2950066',
                'england.dpo@nhs.net',
                'Data Protection Officer, NHS England, 7-8 Wellington Place, 6th Floor, Leeds LS1 4AP',
                NULL)

ON CONFLICT (id) DO NOTHING;

-- ── Cameras ────────────────────────────────────────────────────────────────────
INSERT INTO cameras (id, lat, lng, location_desc, operator_id, source, added) VALUES

('gstt-001',                51.50102,   -0.12445,   'Westminster Bridge Road, outside St Thomas'' Hospital main entrance',                               'gstt',         'manual', '2026-02-18'),
('tfl-brixton-001',         51.462618,  -0.114888,  'Brixton Underground Station street entrance, Brixton Road SW9',                                     'tfl',          'manual', '2026-02-18'),
('networkrail-waterloo-001',51.5032,    -0.1123,    'London Waterloo station main concourse entrance, Waterloo Road SE1',                                 'networkrail',  'manual', '2026-02-18'),
('btp-kingscross-001',      51.5331,    -0.1225,    'King''s Cross / St Pancras International station — British Transport Police operational area',       'btp',          'manual', '2026-02-18'),
('met-nsyard-001',          51.5029,    -0.1242,    'New Scotland Yard exterior, Victoria Embankment, London SW1A',                                       'met',          'manual', '2026-02-18'),
('tesco-wembley-001',       51.5480,    -0.2700,    'Tesco Extra, Great Central Way, Wembley NW10 — car park entrance',                                   'tesco',        'manual', '2026-02-18'),
('sainsburys-nineelms-001', 51.48064,   -0.129065,  'Sainsbury''s superstore, Wandsworth Road, Nine Elms SW8',                                           'sainsburys',   'manual', '2026-02-18'),
('ms-marblearch-001',       51.5145,    -0.1567,    'Marks & Spencer flagship store, 458 Oxford Street, London W1C — main entrance',                      'ms',           'manual', '2026-02-18'),
('westfield-whitecity-001', 51.5072,    -0.2217,    'Westfield London shopping centre, Ariel Way, White City W12 — main entrance',                        'westfield',    'manual', '2026-02-18'),
('westfield-stratford-001', 51.5441,    -0.0054,    'Westfield Stratford City, Montfichet Road, London E20 — main entrance',                              'westfield',    'manual', '2026-02-18'),
('nhsengland-leeds-001',    53.7957,    -1.5561,    'NHS England headquarters, 7-8 Wellington Place, Leeds LS1 — building entrance',                      'nhsengland',   'manual', '2026-02-18')

ON CONFLICT (id) DO NOTHING;
