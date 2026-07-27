-- ============================================================
-- supabase_schema_v2.sql
-- 在已有 schema 基础上追加新字段和新表
-- 幂等，可以反复执行（IF NOT EXISTS / IF EXISTS 保护）
-- ============================================================

-- 1. 给 places 表加两个字段
ALTER TABLE public.places
  ADD COLUMN IF NOT EXISTS wikidata_entity_id TEXT UNIQUE,
  ADD COLUMN IF NOT EXISTS timeline_anchors JSONB DEFAULT '[]'::jsonb;

-- 2. landmark_ratings（用户评分+评论）
CREATE TABLE IF NOT EXISTS public.landmark_ratings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  place_id    UUID REFERENCES public.places(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rating      INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(place_id, user_id)
);

-- 3. landmark_checkins（用户打卡）
CREATE TABLE IF NOT EXISTS public.landmark_checkins (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  place_id      UUID REFERENCES public.places(id) ON DELETE CASCADE,
  user_id       UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  checked_in_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(place_id, user_id)
);

-- 4. landmark_stories（用户故事）
CREATE TABLE IF NOT EXISTS public.landmark_stories (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  place_id   UUID REFERENCES public.places(id) ON DELETE CASCADE,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. landmark_stats 聚合视图
CREATE OR REPLACE VIEW public.landmark_stats AS
SELECT
  p.id                              AS place_id,
  COUNT(DISTINCT c.id)              AS checkin_count,
  COUNT(DISTINCT r.id)              AS rating_count,
  ROUND(AVG(r.rating)::numeric, 1)  AS avg_rating,
  COUNT(DISTINCT s.id)              AS story_count
FROM public.places p
LEFT JOIN public.landmark_checkins c ON c.place_id = p.id
LEFT JOIN public.landmark_ratings  r ON r.place_id = p.id
LEFT JOIN public.landmark_stories  s ON s.place_id = p.id
GROUP BY p.id;

-- ============================================================
-- RLS 策略
-- ============================================================

ALTER TABLE public.landmark_ratings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "ratings_select" ON public.landmark_ratings;
DROP POLICY IF EXISTS "ratings_insert" ON public.landmark_ratings;
CREATE POLICY "ratings_select" ON public.landmark_ratings FOR SELECT USING (true);
CREATE POLICY "ratings_insert" ON public.landmark_ratings FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.landmark_checkins ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "checkins_select" ON public.landmark_checkins;
DROP POLICY IF EXISTS "checkins_insert" ON public.landmark_checkins;
CREATE POLICY "checkins_select" ON public.landmark_checkins FOR SELECT USING (true);
CREATE POLICY "checkins_insert" ON public.landmark_checkins FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.landmark_stories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "stories_select" ON public.landmark_stories;
DROP POLICY IF EXISTS "stories_insert" ON public.landmark_stories;
CREATE POLICY "stories_select" ON public.landmark_stories FOR SELECT USING (true);
CREATE POLICY "stories_insert" ON public.landmark_stories FOR INSERT WITH CHECK (auth.uid() = user_id);

-- places 表允许已登录用户插入（懒加载物化用）
ALTER TABLE public.places ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "places_select" ON public.places;
DROP POLICY IF EXISTS "places_insert_auth" ON public.places;
CREATE POLICY "places_select" ON public.places FOR SELECT USING (true);
CREATE POLICY "places_insert_auth" ON public.places FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
