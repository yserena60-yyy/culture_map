-- ============================================================
-- supabase_add_checkins.sql
-- Adds the check-in ("打卡") system: route waypoints + user checkins.
-- Please run this in your Supabase SQL Editor.
-- Idempotent (safe to re-run).
-- ============================================================

-- 1. Waypoints for multi-stop routes (only 'route' type stamps use this;
--    landmark-type stamps are checked in directly using stamps.lat/lng).
CREATE TABLE IF NOT EXISTS public.stamp_route_waypoints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stamp_id UUID NOT NULL REFERENCES public.stamps(id) ON DELETE CASCADE,
    step_order INTEGER NOT NULL,
    name TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    UNIQUE(stamp_id, step_order)
);

CREATE INDEX IF NOT EXISTS idx_stamp_route_waypoints_stamp_id
    ON public.stamp_route_waypoints(stamp_id);

ALTER TABLE public.stamp_route_waypoints ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "waypoints_select" ON public.stamp_route_waypoints;
CREATE POLICY "waypoints_select" ON public.stamp_route_waypoints FOR SELECT USING (true);

-- 2. Check-ins. waypoint_index = 0 for a single-location stamp (landmark,
--    or a route with no waypoints row); for a route it is the waypoint's
--    step_order. A route counts as fully unlocked once the user has one
--    checkin per waypoint_index from 0..N-1.
CREATE TABLE IF NOT EXISTS public.stamp_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stamp_id UUID NOT NULL REFERENCES public.stamps(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    waypoint_index INTEGER NOT NULL DEFAULT 0,
    photo_url TEXT,
    note TEXT,
    is_backfill BOOLEAN NOT NULL DEFAULT FALSE,
    checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(stamp_id, user_id, waypoint_index)
);

CREATE INDEX IF NOT EXISTS idx_stamp_checkins_user_id ON public.stamp_checkins(user_id);
CREATE INDEX IF NOT EXISTS idx_stamp_checkins_stamp_id ON public.stamp_checkins(stamp_id);

ALTER TABLE public.stamp_checkins ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "stamp_checkins_select" ON public.stamp_checkins;
DROP POLICY IF EXISTS "stamp_checkins_insert" ON public.stamp_checkins;
CREATE POLICY "stamp_checkins_select" ON public.stamp_checkins FOR SELECT USING (true);
CREATE POLICY "stamp_checkins_insert" ON public.stamp_checkins FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. Seed waypoints for the 17 route-type stamps (approximate real-world
--    stops along each route, ordered start to end). Editorially curated,
--    not an authoritative source — safe to re-run (ON CONFLICT DO NOTHING).

-- Inca Trail
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('30d85c5d-2f55-4eb2-80dd-261669de3c2f', 0, 'Km 82 / Piscacucho', -13.1500, -72.4500),
('30d85c5d-2f55-4eb2-80dd-261669de3c2f', 1, 'Wayllabamba', -13.2167, -72.4333),
('30d85c5d-2f55-4eb2-80dd-261669de3c2f', 2, 'Dead Woman''s Pass', -13.2333, -72.4667),
('30d85c5d-2f55-4eb2-80dd-261669de3c2f', 3, 'Winay Wayna', -13.1833, -72.5333),
('30d85c5d-2f55-4eb2-80dd-261669de3c2f', 4, 'Machu Picchu', -13.1631, -72.5450)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Silk Road
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('33333333-3333-3333-3333-333333333331', 0, 'Xi''an', 34.2658, 108.9541),
('33333333-3333-3333-3333-333333333331', 1, 'Dunhuang', 40.1421, 94.6618),
('33333333-3333-3333-3333-333333333331', 2, 'Samarkand', 39.6542, 66.9597),
('33333333-3333-3333-3333-333333333331', 3, 'Istanbul', 41.0082, 28.9784),
('33333333-3333-3333-3333-333333333331', 4, 'Rome', 41.9028, 12.4964)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Renaissance Trail
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('33333333-3333-3333-3333-333333333332', 0, 'Florence', 43.7696, 11.2558),
('33333333-3333-3333-3333-333333333332', 1, 'Siena', 43.3188, 11.3308),
('33333333-3333-3333-3333-333333333332', 2, 'Venice', 45.4408, 12.3155),
('33333333-3333-3333-3333-333333333332', 3, 'Milan', 45.4642, 9.1900),
('33333333-3333-3333-3333-333333333332', 4, 'Rome', 41.9028, 12.4964)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Route 66
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('33333333-3333-3333-3333-333333333333', 0, 'Chicago, IL', 41.8781, -87.6298),
('33333333-3333-3333-3333-333333333333', 1, 'St. Louis, MO', 38.6270, -90.1994),
('33333333-3333-3333-3333-333333333333', 2, 'Oklahoma City, OK', 35.4676, -97.5164),
('33333333-3333-3333-3333-333333333333', 3, 'Amarillo, TX', 35.2071, -101.8313),
('33333333-3333-3333-3333-333333333333', 4, 'Albuquerque, NM', 35.0844, -106.6504),
('33333333-3333-3333-3333-333333333333', 5, 'Flagstaff, AZ', 35.1983, -111.6513),
('33333333-3333-3333-3333-333333333333', 6, 'Santa Monica, CA', 34.0195, -118.4912)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Route 500 (NC500)
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('46d1a5ae-3561-4b39-b257-ca1f6995f5bb', 0, 'Inverness', 57.4778, -4.2247),
('46d1a5ae-3561-4b39-b257-ca1f6995f5bb', 1, 'Applecross', 57.4333, -5.8167),
('46d1a5ae-3561-4b39-b257-ca1f6995f5bb', 2, 'Ullapool', 57.8956, -5.1600),
('46d1a5ae-3561-4b39-b257-ca1f6995f5bb', 3, 'John o'' Groats', 58.6437, -3.0704),
('46d1a5ae-3561-4b39-b257-ca1f6995f5bb', 4, 'Dornoch', 57.8794, -4.0242)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Karakoram Highway
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('4992a0cf-2756-45a5-b228-621c9354227d', 0, 'Hasan Abdal, Pakistan', 33.8167, 72.6667),
('4992a0cf-2756-45a5-b228-621c9354227d', 1, 'Gilgit, Pakistan', 35.9208, 74.3144),
('4992a0cf-2756-45a5-b228-621c9354227d', 2, 'Hunza Valley', 36.3167, 74.6500),
('4992a0cf-2756-45a5-b228-621c9354227d', 3, 'Khunjerab Pass', 36.8500, 75.4167)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Route of the Castles and Towns (Loire Valley)
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('5d87cc31-9fd2-4c43-bfab-fd63a9d21b5e', 0, 'Chateau de Chambord', 47.6161, 1.5170),
('5d87cc31-9fd2-4c43-bfab-fd63a9d21b5e', 1, 'Chateau de Chenonceau', 47.3242, 0.9847),
('5d87cc31-9fd2-4c43-bfab-fd63a9d21b5e', 2, 'Chateau de Chinon', 47.1667, 0.2411),
('5d87cc31-9fd2-4c43-bfab-fd63a9d21b5e', 3, 'Chateau de Villandry', 47.3400, 0.5150)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Amalfi Coast Drive
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('807b430c-ad63-40a8-ab1b-ef818dfa1af1', 0, 'Sorrento', 40.6263, 14.3757),
('807b430c-ad63-40a8-ab1b-ef818dfa1af1', 1, 'Positano', 40.6280, 14.4848),
('807b430c-ad63-40a8-ab1b-ef818dfa1af1', 2, 'Amalfi', 40.6340, 14.6027),
('807b430c-ad63-40a8-ab1b-ef818dfa1af1', 3, 'Ravello', 40.6494, 14.6114),
('807b430c-ad63-40a8-ab1b-ef818dfa1af1', 4, 'Salerno', 40.6824, 14.7681)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Pan-American Highway
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('8b8e2701-fac0-4309-ba3e-b7f890c05be9', 0, 'Prudhoe Bay, Alaska', 70.2551, -148.3467),
('8b8e2701-fac0-4309-ba3e-b7f890c05be9', 1, 'Mexico City, Mexico', 19.4326, -99.1332),
('8b8e2701-fac0-4309-ba3e-b7f890c05be9', 2, 'Panama City, Panama', 8.9824, -79.5199),
('8b8e2701-fac0-4309-ba3e-b7f890c05be9', 3, 'Bogota, Colombia', 4.7110, -74.0721),
('8b8e2701-fac0-4309-ba3e-b7f890c05be9', 4, 'Santiago, Chile', -33.4489, -70.6693),
('8b8e2701-fac0-4309-ba3e-b7f890c05be9', 5, 'Ushuaia, Argentina', -54.8019, -68.3030)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Trans-Siberian Railway
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('9e6c119a-43a3-4a66-9d53-57c59cabd78f', 0, 'Moscow', 55.7558, 37.6173),
('9e6c119a-43a3-4a66-9d53-57c59cabd78f', 1, 'Yekaterinburg', 56.8389, 60.6057),
('9e6c119a-43a3-4a66-9d53-57c59cabd78f', 2, 'Novosibirsk', 55.0084, 82.9357),
('9e6c119a-43a3-4a66-9d53-57c59cabd78f', 3, 'Irkutsk / Lake Baikal', 52.2870, 104.3050),
('9e6c119a-43a3-4a66-9d53-57c59cabd78f', 4, 'Vladivostok', 43.1155, 131.8855)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Golden Triangle (India)
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('9f59d670-f225-49dc-a568-f62c09b99fcb', 0, 'Delhi', 28.6139, 77.2090),
('9f59d670-f225-49dc-a568-f62c09b99fcb', 1, 'Agra', 27.1767, 78.0081),
('9f59d670-f225-49dc-a568-f62c09b99fcb', 2, 'Jaipur', 26.9124, 75.7873)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Great Ocean Road
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('b88911fe-d199-41ac-8168-5b82e04396fa', 0, 'Torquay', -38.3333, 144.3167),
('b88911fe-d199-41ac-8168-5b82e04396fa', 1, 'Lorne', -38.5417, 143.9750),
('b88911fe-d199-41ac-8168-5b82e04396fa', 2, 'Apollo Bay', -38.7583, 143.6708),
('b88911fe-d199-41ac-8168-5b82e04396fa', 3, 'Twelve Apostles', -38.6656, 143.1039),
('b88911fe-d199-41ac-8168-5b82e04396fa', 4, 'Warrnambool', -38.3818, 142.4879)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Appalachian Trail
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('cc0e40d7-84d4-49c6-bbc1-77fa51231ee1', 0, 'Springer Mountain, GA', 34.6272, -84.1936),
('cc0e40d7-84d4-49c6-bbc1-77fa51231ee1', 1, 'Great Smoky Mountains, TN/NC', 35.6118, -83.4895),
('cc0e40d7-84d4-49c6-bbc1-77fa51231ee1', 2, 'Harpers Ferry, WV', 39.3253, -77.7397),
('cc0e40d7-84d4-49c6-bbc1-77fa51231ee1', 3, 'Mount Washington, NH', 44.2706, -71.3033),
('cc0e40d7-84d4-49c6-bbc1-77fa51231ee1', 4, 'Mount Katahdin, ME', 45.9042, -68.9214)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Romantische Strasse
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('dfebd1d8-25f9-4929-baba-c721e235d105', 0, 'Wurzburg', 49.7913, 9.9534),
('dfebd1d8-25f9-4929-baba-c721e235d105', 1, 'Rothenburg ob der Tauber', 49.3778, 10.1789),
('dfebd1d8-25f9-4929-baba-c721e235d105', 2, 'Nordlingen', 48.8508, 10.4886),
('dfebd1d8-25f9-4929-baba-c721e235d105', 3, 'Augsburg', 48.3705, 10.8978),
('dfebd1d8-25f9-4929-baba-c721e235d105', 4, 'Fussen', 47.5697, 10.7017)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Camino de Santiago (Camino Frances)
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('e6782b7d-6646-47de-b9d4-2c114330c434', 0, 'Saint-Jean-Pied-de-Port', 43.1633, -1.2378),
('e6782b7d-6646-47de-b9d4-2c114330c434', 1, 'Pamplona', 42.8125, -1.6458),
('e6782b7d-6646-47de-b9d4-2c114330c434', 2, 'Burgos', 42.3439, -3.6969),
('e6782b7d-6646-47de-b9d4-2c114330c434', 3, 'Leon', 42.5987, -5.5671),
('e6782b7d-6646-47de-b9d4-2c114330c434', 4, 'Santiago de Compostela', 42.8782, -8.5448)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Pacific Crest Trail
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('e9eca7ee-31de-4186-bacf-aef244976446', 0, 'Campo, CA (Mexico border)', 32.6014, -116.4667),
('e9eca7ee-31de-4186-bacf-aef244976446', 1, 'Mount Whitney area, CA', 36.5786, -118.2923),
('e9eca7ee-31de-4186-bacf-aef244976446', 2, 'Lake Tahoe, CA', 39.0968, -120.0324),
('e9eca7ee-31de-4186-bacf-aef244976446', 3, 'Crater Lake, OR', 42.9446, -122.1090),
('e9eca7ee-31de-4186-bacf-aef244976446', 4, 'Manning Park, BC (Canada border)', 49.0631, -120.7797)
ON CONFLICT (stamp_id, step_order) DO NOTHING;

-- Ring Road (Iceland)
INSERT INTO public.stamp_route_waypoints (stamp_id, step_order, name, lat, lng) VALUES
('6f54534f-94d2-4a08-a6c3-fde03918bd8c', 0, 'Reykjavik', 64.1466, -21.9426),
('6f54534f-94d2-4a08-a6c3-fde03918bd8c', 1, 'Vik', 63.4186, -19.0060),
('6f54534f-94d2-4a08-a6c3-fde03918bd8c', 2, 'Hofn', 64.2539, -15.2082),
('6f54534f-94d2-4a08-a6c3-fde03918bd8c', 3, 'Akureyri', 65.6835, -18.0878),
('6f54534f-94d2-4a08-a6c3-fde03918bd8c', 4, 'Borgarnes', 64.5385, -21.9159)
ON CONFLICT (stamp_id, step_order) DO NOTHING;
