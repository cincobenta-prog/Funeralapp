-- Digi-Tribute: Phase 1 & Phase 2 Initial PostgreSQL Schema
-- Supported on PostgreSQL 15+ / Supabase

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enum Types
CREATE TYPE subject_status AS ENUM ('active', 'archived', 'completed');
CREATE TYPE tribute_media_type AS ENUM ('video', 'audio', 'photo');
CREATE TYPE tribute_status AS ENUM ('submitted', 'in_review', 'approved', 'rejected');
CREATE TYPE compiled_video_status AS ENUM ('draft', 'editing', 'family_review', 'published');

-- 1. Funeral Homes (Multi-tenant accounts)
CREATE TABLE funeral_homes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL UNIQUE,
    package_tier VARCHAR(50) NOT NULL DEFAULT 'standard',
    subject_credits_remaining INT NOT NULL DEFAULT 10,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Memorial Subjects (The deceased)
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    funeral_home_id UUID NOT NULL REFERENCES funeral_homes(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    date_of_death DATE,
    date_of_service DATE,
    photo_url TEXT,
    bio_text TEXT,
    status subject_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Topics / Question Bank
CREATE TABLE topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    relationship_type VARCHAR(100) NOT NULL, -- e.g. 'father', 'mother', 'spouse', etc.
    question_text TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Tributes (Uploaded memories from direct entry or invited guests)
CREATE TABLE tributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES topics(id) ON DELETE SET NULL,
    contributor_name VARCHAR(150) NOT NULL,
    contributor_email VARCHAR(255), -- Nullable in Phase 1 (direct admin entry), required in Phase 2
    relationship_type VARCHAR(100) NOT NULL,
    media_type tribute_media_type NOT NULL,
    raw_media_url TEXT, -- Purged 90 days after compiled_video publication
    final_media_url TEXT, -- Populated during compilation/mastering
    status tribute_status NOT NULL DEFAULT 'submitted',
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Compiled Videos (Master memorial presentation)
CREATE TABLE compiled_videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    final_video_url TEXT,
    edited_by VARCHAR(150),
    status compiled_video_status NOT NULL DEFAULT 'draft',
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Events (Phase 2: Guest Invites & PIN Gates)
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    invite_token VARCHAR(64) NOT NULL UNIQUE,
    pin_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_subjects_funeral_home_id ON subjects(funeral_home_id);
CREATE INDEX idx_tributes_subject_id ON tributes(subject_id);
CREATE INDEX idx_tributes_status ON tributes(status);
CREATE INDEX idx_topics_relationship_type ON topics(relationship_type, active);
CREATE INDEX idx_compiled_videos_subject_id ON compiled_videos(subject_id);
CREATE INDEX idx_compiled_videos_published_at ON compiled_videos(published_at);
CREATE INDEX idx_events_invite_token ON events(invite_token);

-- Auto-update updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_funeral_homes_updated_at BEFORE UPDATE ON funeral_homes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tributes_updated_at BEFORE UPDATE ON tributes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_compiled_videos_updated_at BEFORE UPDATE ON compiled_videos
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
