-- ── 02_rpc.sql ────────────────────────────────────────────────────────────────
-- Geo search function — returns cameras within radius_m of a point,
-- with operator details joined, ordered by distance ascending.
--
-- Called from the app as:
--   POST /rest/v1/rpc/cameras_within
--   { "user_lat": 51.5, "user_lng": -0.1, "radius_m": 300 }

CREATE OR REPLACE FUNCTION cameras_within(
    user_lat  float8,
    user_lng  float8,
    radius_m  float8 DEFAULT 300
)
RETURNS TABLE (
    id              text,
    lat             float8,
    lng             float8,
    location_desc   text,
    distance_m      float8,
    operator_id     text,
    operator_name   text,
    ico_reg         text,
    privacy_email   text,
    postal_address  text
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT
        c.id,
        c.lat,
        c.lng,
        c.location_desc,
        ST_Distance(
            c.geom::geography,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        )                       AS distance_m,
        c.operator_id,
        o.name                  AS operator_name,
        o.ico_reg,
        o.privacy_email,
        o.postal_address
    FROM   cameras  c
    JOIN   operators o ON o.id = c.operator_id
    WHERE  ST_DWithin(
               c.geom::geography,
               ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
               radius_m
           )
    ORDER  BY distance_m;
$$;
