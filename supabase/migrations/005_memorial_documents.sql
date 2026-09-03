-- Digi-Tribute: Unified Memorial Document & Keepsake Book Compilation
-- Collects approved photos, stories, prompts, and audio/video QR links into a unified memorial presentation document.

CREATE TABLE memorial_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    pdf_url TEXT,
    web_presentation_url TEXT,
    page_count INT NOT NULL DEFAULT 0,
    theme_name VARCHAR(50) NOT NULL DEFAULT 'classic_elegance',
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_memorial_documents_subject_id ON memorial_documents(subject_id);

CREATE TRIGGER update_memorial_documents_updated_at BEFORE UPDATE ON memorial_documents
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE memorial_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage memorial documents for their subjects"
    ON memorial_documents FOR ALL
    USING (
        subject_id IN (
            SELECT id FROM subjects WHERE funeral_home_id = auth_funeral_home_id()
        )
    )
    WITH CHECK (
        subject_id IN (
            SELECT id FROM subjects WHERE funeral_home_id = auth_funeral_home_id()
        )
    );

CREATE POLICY "Anyone with link can view published memorial document"
    ON memorial_documents FOR SELECT
    USING (status = 'ready' OR status = 'published');
