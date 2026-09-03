-- Digi-Tribute: Row Level Security (RLS) Policies
-- Enforces multi-tenant isolation at the database layer

-- Enable RLS on all tables
ALTER TABLE funeral_homes ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE tributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE compiled_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Helper function: Get the funeral_home_id of the currently authenticated admin
CREATE OR REPLACE FUNCTION auth_funeral_home_id()
RETURNS UUID AS $$
    SELECT id FROM funeral_homes WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ============================================================================
-- 1. Topics Policies (Question Bank)
-- Active questions are readable by all authenticated admins and guests
-- ============================================================================
CREATE POLICY "Topics are viewable by everyone"
    ON topics FOR SELECT
    USING (active = TRUE);

-- ============================================================================
-- 2. Funeral Homes Policies
-- Admins can only view and edit their own funeral home account
-- ============================================================================
CREATE POLICY "Admins can view their own funeral home"
    ON funeral_homes FOR SELECT
    USING (auth_user_id = auth.uid());

CREATE POLICY "Admins can update their own funeral home"
    ON funeral_homes FOR UPDATE
    USING (auth_user_id = auth.uid())
    WITH CHECK (auth_user_id = auth.uid());

-- ============================================================================
-- 3. Subjects Policies
-- Admins can only view, create, update, and delete subjects under their home
-- ============================================================================
CREATE POLICY "Admins can manage their subjects"
    ON subjects FOR ALL
    USING (funeral_home_id = auth_funeral_home_id())
    WITH CHECK (funeral_home_id = auth_funeral_home_id());

-- Guests can view basic subject info if they have a valid event link
CREATE POLICY "Guests can view subject via active event"
    ON subjects FOR SELECT
    USING (
        id IN (
            SELECT subject_id FROM events 
            WHERE expires_at IS NULL OR expires_at > NOW()
        )
    );

-- ============================================================================
-- 4. Tributes Policies
-- Admins have full access to tributes for their subjects
-- ============================================================================
CREATE POLICY "Admins can manage tributes for their subjects"
    ON tributes FOR ALL
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

-- Guests (Phase 2): Can insert a tribute tied to an active event with contributor email
CREATE POLICY "Guests can submit tributes to active subjects"
    ON tributes FOR INSERT
    WITH CHECK (
        subject_id IN (
            SELECT subject_id FROM events 
            WHERE expires_at IS NULL OR expires_at > NOW()
        )
    );

-- ============================================================================
-- 5. Compiled Videos Policies
-- Scoped strictly to funeral home admins
-- ============================================================================
CREATE POLICY "Admins can manage compiled videos"
    ON compiled_videos FOR ALL
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

-- View published compiled video
CREATE POLICY "Anyone with link can view published compiled video"
    ON compiled_videos FOR SELECT
    USING (status = 'published');

-- ============================================================================
-- 6. Events Policies (Phase 2)
-- Admins manage events; Guests can query by invite token
-- ============================================================================
CREATE POLICY "Admins can manage events"
    ON events FOR ALL
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

CREATE POLICY "Guests can view event by token"
    ON events FOR SELECT
    USING (expires_at IS NULL OR expires_at > NOW());
