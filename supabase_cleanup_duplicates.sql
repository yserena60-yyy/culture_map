-- Step 1: Delete duplicate bookmarks (keep only the most recent one)
DELETE FROM public.bookmarks a
USING public.bookmarks b
WHERE a.id < b.id
  AND a.user_id = b.user_id
  AND (
    (a.place_id = b.place_id AND a.place_id IS NOT NULL)
    OR (a.wikidata_entity_id = b.wikidata_entity_id AND a.wikidata_entity_id IS NOT NULL)
  );

-- Step 2: Verify unique indexes exist (these prevent future duplicates)
-- For user-defined places
CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmarks_user_place
    ON public.bookmarks(user_id, place_id)
    WHERE place_id IS NOT NULL;

-- For Wikipedia places
CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmarks_user_wikidata
    ON public.bookmarks(user_id, wikidata_entity_id)
    WHERE wikidata_entity_id IS NOT NULL;
