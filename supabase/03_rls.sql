-- ── 03_rls.sql ────────────────────────────────────────────────────────────────
-- Row Level Security policies.
-- Run after 01_schema.sql.

-- Enable RLS on all tables
ALTER TABLE cameras         ENABLE ROW LEVEL SECURITY;
ALTER TABLE operators       ENABLE ROW LEVEL SECURITY;
ALTER TABLE pending_cameras ENABLE ROW LEVEL SECURITY;

-- ── cameras: public read ───────────────────────────────────────────────────────
CREATE POLICY "anon read cameras"
    ON cameras FOR SELECT TO anon
    USING (true);

-- ── operators: public read ─────────────────────────────────────────────────────
CREATE POLICY "anon read operators"
    ON operators FOR SELECT TO anon
    USING (true);

-- ── pending_cameras: insert only ───────────────────────────────────────────────
-- Anonymous users can submit contributions but cannot read, update or delete them.
-- This prevents scraping of submitted (unverified) contact details.
CREATE POLICY "anon submit pending"
    ON pending_cameras FOR INSERT TO anon
    WITH CHECK (true);

-- ── Grant RPC execution to anon ────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION cameras_within(float8, float8, float8) TO anon;
