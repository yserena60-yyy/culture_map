-- Add wikidata_entity_id column to bookmarks table
ALTER TABLE public.bookmarks ADD COLUMN IF NOT EXISTS wikidata_entity_id TEXT;

-- Drop old unique constraint
ALTER TABLE public.bookmarks DROP CONSTRAINT IF EXISTS bookmarks_user_id_place_id_key;

-- Add new unique constraint that allows either place_id or wikidata_entity_id
CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmarks_user_place
    ON public.bookmarks(user_id, place_id)
    WHERE place_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmarks_user_wikidata
    ON public.bookmarks(user_id, wikidata_entity_id)
    WHERE wikidata_entity_id IS NOT NULL;

-- Create index for wikidata_entity_id queries
CREATE INDEX IF NOT EXISTS idx_bookmarks_wikidata_entity_id ON public.bookmarks(wikidata_entity_id);
