-- ============================================================
-- setup_profiles.sql
-- Run this in Supabase SQL Editor to enable Phase 1 features!
-- ============================================================

-- 1. Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  background_url TEXT,
  bio TEXT,
  xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;
CREATE POLICY "Users can update own profile."
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 3. Trigger to automatically create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, avatar_url, background_url)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    'https://wwnvrqijkmhmybcwovwn.supabase.co/storage/v1/object/public/user_images/default_avatar.png',
    'https://wwnvrqijkmhmybcwovwn.supabase.co/storage/v1/object/public/user_images/default_bg.jpg'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. Insert existing auth users into profiles table if they don't exist yet!
INSERT INTO public.profiles (id, username, avatar_url, background_url)
SELECT 
  id, 
  COALESCE(raw_user_meta_data->>'username', 'user_' || substr(id::text, 1, 8)),
  'https://wwnvrqijkmhmybcwovwn.supabase.co/storage/v1/object/public/user_images/default_avatar.png',
  'https://wwnvrqijkmhmybcwovwn.supabase.co/storage/v1/object/public/user_images/default_bg.jpg'
FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- 5. Create Storage Bucket for user_images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('user_images', 'user_images', true)
ON CONFLICT (id) DO NOTHING;

-- 6. Storage RLS (You MUST enable RLS on storage.objects for this to work)
-- Wait, actually Supabase storage.objects has RLS enabled by default.
DROP POLICY IF EXISTS "Avatar images are publicly accessible." ON storage.objects;
CREATE POLICY "Avatar images are publicly accessible."
  ON storage.objects FOR SELECT
  USING (bucket_id = 'user_images');

DROP POLICY IF EXISTS "Anyone can upload an avatar." ON storage.objects;
CREATE POLICY "Anyone can upload an avatar."
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'user_images' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Anyone can update their own avatar." ON storage.objects;
CREATE POLICY "Anyone can update their own avatar."
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'user_images' AND auth.role() = 'authenticated');
