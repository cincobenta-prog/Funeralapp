-- Digital Tribute: Conversational Follow-Up Prompts & Coffee Table Book Taxonomy
-- Adds follow_up_prompt column to topics and populates deep, relationship-specific storytelling pairs.

ALTER TABLE topics ADD COLUMN IF NOT EXISTS follow_up_prompt TEXT;

-- Update existing topics with follow-up prompts and insert rich new pairs
-- ============================================================================
-- 1. FATHER
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('father', 'What was an unspoken lesson your dad taught you just by the way he lived his daily life?', 'When was the last time you found yourself doing something the exact way he did, and what did that feel like?', 1, TRUE, 'Witnessing in Action'),
('father', 'Describe a moment when you were struggling and your father showed up without making a fuss.', 'What did his quiet presence tell you about what it really means to protect and care for someone?', 2, TRUE, 'Help & Sacrifice'),
('father', 'What is a piece of advice or saying from him that you hated as a kid, but now live by?', 'How has passing that advice down or remembering it shaped who you are today?', 3, TRUE, 'Joy & Laughter'),
('father', 'What was a private mountain or heartbreak you saw him carry with quiet dignity?', 'How did seeing him weather that storm teach you how to face your own hard seasons?', 4, TRUE, 'Pain & Resilience'),
('father', 'What was something that made his face light up with unrestrained pride when he looked at his children?', 'If you could thank him for one specific sacrifice he made for you, what would it be?', 5, TRUE, 'Joy & Laughter');

-- ============================================================================
-- 2. MOTHER
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('mother', 'What is a scent, sound, or ritual from your mother''s kitchen that will always bring her right back to you?', 'What was the secret ingredient or love she poured into those moments that made you feel completely safe?', 1, TRUE, 'Joy & Laughter'),
('mother', 'Describe a sacrifice she made for you that you were too young to understand until you got older.', 'When did the realization hit you of how much love was behind that decision?', 2, TRUE, 'Help & Sacrifice'),
('mother', 'What was a moment your mother held you together when your world felt like it was breaking apart?', 'What words or touch of hers gave you the strength to stand back up?', 3, TRUE, 'Pain & Resilience'),
('mother', 'What was something uniquely hilarious or fierce about her personality that only the family truly knew?', 'What story captures that fire or humor better than anything else?', 4, TRUE, 'Joy & Laughter'),
('mother', 'What value of hers do you most hope lives on through your children and future generations?', 'How do you plan to keep that flame burning in her honor?', 5, TRUE, 'Witnessing in Action');

-- ============================================================================
-- 3. SPOUSE OR PARTNER
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('spouse_partner', 'What was the exact moment or ordinary Tuesday when you realized, "This is the person I want to walk through the rest of my life with"?', 'What was it about the way they looked at you or treated you that made you certain?', 1, TRUE, 'Joy & Laughter'),
('spouse_partner', 'What was a quiet, private ritual of love they did every single day that you already miss so deeply?', 'How did that daily habit anchor your home and marriage across the years?', 2, TRUE, 'Help & Sacrifice'),
('spouse_partner', 'Describe the darkest valley you walked through together and how they held your hand through the storm.', 'What did their devotion in that season reveal about the depth of their soul?', 3, TRUE, 'Pain & Resilience'),
('spouse_partner', 'What was your private shorthand, inside joke, or unspoken look across a crowded room?', 'What memory of laughing together in the middle of the night still brings warmth to your chest?', 4, TRUE, 'Joy & Laughter'),
('spouse_partner', 'If you could whisper one final promise into their ear for eternity, what would you promise them?', 'How will their love continue to guide your footsteps forward?', 5, TRUE, 'Witnessing in Action');

-- ============================================================================
-- 4. SON
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('son', 'What was a moment your son stood up for what was right in a way that made your heart swell with pride?', 'What did that moment tell you about the man he had become?', 1, TRUE, 'Witnessing in Action'),
('son', 'What was an adventure or passion of his that he threw his whole heart into?', 'How did his enthusiasm light up the people who were lucky enough to be in his orbit?', 2, TRUE, 'Joy & Laughter'),
('son', 'What was a time he surprised you with his tenderness or generosity toward someone who was hurting?', 'What does that story tell everyone about the size of his heart?', 3, TRUE, 'Help & Sacrifice'),
('son', 'What difficult challenge or hardship did you watch him face with bravery?', 'What did he teach you about courage while fighting that battle?', 4, TRUE, 'Pain & Resilience');

-- ============================================================================
-- 5. DAUGHTER
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('daughter', 'What was a moment your daughter showed a fierce, radiant kindness that took your breath away?', 'How did she have a way of seeing the best in people even when they couldn''t see it themselves?', 1, TRUE, 'Witnessing in Action'),
('daughter', 'What is a memory of pure joy and laughter with her that plays in your mind like a favorite song?', 'What made her smile and laugh so completely infectious to everyone around her?', 2, TRUE, 'Joy & Laughter'),
('daughter', 'Describe a time she supported you or someone else with wisdom far beyond her years.', 'Where did she get that quiet strength and insight?', 3, TRUE, 'Help & Sacrifice'),
('daughter', 'What mountain did she climb or adversity did she face with unwavering grace?', 'What will you forever admire about how she handled that chapter of her life?', 4, TRUE, 'Pain & Resilience');

-- ============================================================================
-- 6. CHILDHOOD FRIEND
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('childhood_friend', 'What was a secret adventure, hideout, or scheme from growing up that your parents never found out about?', 'What was the moment during that adventure where you both laughed until your stomachs hurt?', 1, TRUE, 'Joy & Laughter'),
('childhood_friend', 'Describe the moment on the playground, schoolyard, or neighborhood street when they had your back against the odds.', 'How did that childhood loyalty lay the foundation for the person they grew into?', 2, TRUE, 'Help & Sacrifice'),
('childhood_friend', 'What was the hardest thing you both endured while growing up together, and how did your friendship survive it?', 'When you look back on those early years, what core truth about their spirit never changed?', 3, TRUE, 'Pain & Resilience');

-- ============================================================================
-- 7. WORK COLLEAGUE & PROFESSIONAL FRIEND
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('work_colleague_friend', 'What was it like to witness them in the trenches when stakes were high and deadlines were crashing?', 'How did their calmness, humor, or brilliant mind steer everyone through the chaos?', 1, TRUE, 'Witnessing in Action'),
('work_colleague_friend', 'Describe a time they used their influence or stood up behind closed doors to advocate for you or a teammate.', 'What did that action teach you about real professional integrity and leadership?', 2, TRUE, 'Help & Sacrifice'),
('work_colleague_friend', 'What was the most disastrous work mishap or high-stress day that you two turned into legendary office laughter?', 'What made working with them feel less like a job and more like a shared mission?', 3, TRUE, 'Joy & Laughter');

-- ============================================================================
-- 8. MENTEE OR STUDENT
-- ============================================================================
INSERT INTO topics (relationship_type, question_text, follow_up_prompt, sort_order, active, pillar) VALUES
('mentee_student', 'What was a specific moment they saw greatness in you when you were full of self-doubt?', 'What exact words did they say that changed the way you looked at your own future?', 1, TRUE, 'Help & Sacrifice'),
('mentee_student', 'Describe a time they corrected you with tough love, grace, and total belief in your potential.', 'How did that lesson save you or elevate your path down the road?', 2, TRUE, 'Pain & Resilience'),
('mentee_student', 'What standard of excellence or quiet kindness of theirs do you now teach to the next generation in their honor?', 'What do you want their family to know about their ripple effect across the world?', 3, TRUE, 'Witnessing in Action');
