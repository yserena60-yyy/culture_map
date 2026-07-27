-- Create storage bucket for user content (avatars, etc.)
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-content', 'user-content', true)
ON CONFLICT (id) DO NOTHING;

-- Set up RLS policies for user-content bucket
CREATE POLICY "Users can upload their own content"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'user-content' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Anyone can view user content"
ON storage.objects FOR SELECT
USING (bucket_id = 'user-content');

CREATE POLICY "Users can update their own content"
ON storage.objects FOR UPDATE
USING (bucket_id = 'user-content' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own content"
ON storage.objects FOR DELETE
USING (bucket_id = 'user-content' AND auth.uid()::text = (storage.foldername(name))[1]);
