-- Add place_name column to comments table
ALTER TABLE public.comments ADD COLUMN IF NOT EXISTS place_name TEXT;

-- Create index for place_name
CREATE INDEX IF NOT EXISTS idx_comments_place_name ON public.comments(place_name);
