-- Remove NOT NULL constraint from place_id column
ALTER TABLE public.bookmarks ALTER COLUMN place_id DROP NOT NULL;
