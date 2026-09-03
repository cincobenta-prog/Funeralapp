-- Digi-Tribute: Storage Buckets, Access Policies & 90-Day Raw Retention Purge Job

-- 1. Insert Storage Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('tributes-raw', 'tributes-raw', FALSE, 524288000, ARRAY['video/*', 'audio/*', 'image/*']), -- 500MB limit for raw uploads
    ('tributes-final', 'tributes-final', FALSE, 2147483648, ARRAY['video/*']) -- 2GB limit for compiled master videos
ON CONFLICT (id) DO NOTHING;

-- 2. Storage Policies for `tributes-raw`
-- Format: {funeral_home_id}/{subject_id}/{file_name}
CREATE POLICY "Admins have full access to their raw storage objects"
ON storage.objects FOR ALL
USING (
    bucket_id = 'tributes-raw' AND
    (storage.foldername(name))[1] = auth_funeral_home_id()::text
)
WITH CHECK (
    bucket_id = 'tributes-raw' AND
    (storage.foldername(name))[1] = auth_funeral_home_id()::text
);

-- 3. Storage Policies for `tributes-final`
CREATE POLICY "Admins have full access to their compiled video storage objects"
ON storage.objects FOR ALL
USING (
    bucket_id = 'tributes-final' AND
    (storage.foldername(name))[1] = auth_funeral_home_id()::text
)
WITH CHECK (
    bucket_id = 'tributes-final' AND
    (storage.foldername(name))[1] = auth_funeral_home_id()::text
);

-- ============================================================================
-- 4. Automated 90-Day Raw Media Retention Purge Routine
-- Deletes raw footage references 90 days after compiled_videos.published_at is set.
-- Tribute metadata stays intact for permanent historical record.
-- ============================================================================

CREATE TABLE IF NOT EXISTS storage_purge_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tribute_id UUID NOT NULL,
    subject_id UUID NOT NULL,
    purged_raw_url TEXT,
    purged_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION purge_expired_raw_media()
RETURNS TABLE(tributes_purged INT) AS $$
DECLARE
    purged_count INT := 0;
BEGIN
    -- Log and nullify raw_media_url for tributes published more than 90 days ago
    WITH expired_tributes AS (
        SELECT 
            t.id AS tribute_id,
            t.subject_id,
            t.raw_media_url
        FROM tributes t
        JOIN compiled_videos cv ON cv.subject_id = t.subject_id
        WHERE cv.status = 'published'
          AND cv.published_at IS NOT NULL
          AND cv.published_at <= NOW() - INTERVAL '90 days'
          AND t.raw_media_url IS NOT NULL
    ),
    logged AS (
        INSERT INTO storage_purge_logs (tribute_id, subject_id, purged_raw_url)
        SELECT tribute_id, subject_id, raw_media_url FROM expired_tributes
    )
    UPDATE tributes t
    SET raw_media_url = NULL,
        updated_at = NOW()
    FROM expired_tributes et
    WHERE t.id = et.tribute_id;

    GET DIAGNOSTICS purged_count = ROW_COUNT;
    RETURN QUERY SELECT purged_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule daily cron job (runs every day at 03:00 AM UTC if pg_cron is enabled)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        PERFORM cron.schedule(
            'daily-purge-raw-footage',
            '0 3 * * *',
            'SELECT purge_expired_raw_media();'
        );
    END IF;
END $$;
