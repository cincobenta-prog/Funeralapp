-- Digital Tribute: Expanded Relationship Taxonomy & Deep Impact Question Bank
-- Covers Family, Friends (Childhood, College, Work, Lifelong), and Associates/Admirers
-- Questions structured around 4 emotional pillars: Joy, Pain & Resilience, Help & Sacrifice, Witnessing Them in Action.

INSERT INTO topics (relationship_type, question_text, sort_order, active) VALUES

-- ============================================================================
-- 1. FAMILY CATEGORIES
-- ============================================================================

-- In-Law
('in_law', 'How did they welcome you into the family when you first joined?', 1, TRUE),
('in_law', 'What was a moment of unexpected warmth or understanding between you two?', 2, TRUE),
('in_law', 'What did they teach you about keeping a family bonded through tough seasons?', 3, TRUE),
('in_law', 'What funny or endearing quirk of theirs became a staple family joke?', 4, TRUE),
('in_law', 'How did their presence change the tone of holiday gatherings?', 5, TRUE),
('in_law', 'What do you hope future generations remember about their role in the family?', 6, TRUE),

-- Chosen Family
('chosen_family', 'How did you two choose each other as family, and what made that bond unbreakable?', 1, TRUE),
('chosen_family', 'Describe a painful time when they stood in the gap for you like blood family couldn''t.', 2, TRUE),
('chosen_family', 'What unspoken promise did you share that they always kept?', 3, TRUE),
('chosen_family', 'What is a moment of pure, unrestrained joy you experienced together?', 4, TRUE),
('chosen_family', 'What did they teach you about unconditional acceptance?', 5, TRUE),
('chosen_family', 'What will you carry forward into your own chosen family because of them?', 6, TRUE),

-- ============================================================================
-- 2. EXPANDED FRIENDSHIP CATEGORIES
-- ============================================================================

-- Childhood Friend
('childhood_friend', 'What was an adventure or secret from growing up that only the two of you knew about?', 1, TRUE),
('childhood_friend', 'What was a moment they defended you on the playground or in childhood that you never forgot?', 2, TRUE),
('childhood_friend', 'How did their childhood home, parents, or environment shape who they grew up to be?', 3, TRUE),
('childhood_friend', 'What was something you two laughed about so hard you couldn''t breathe?', 4, TRUE),
('childhood_friend', 'How did you see the core of who they were as a child remain true in adulthood?', 5, TRUE),
('childhood_friend', 'What do you want their family to know about the young kid they were before the world met them?', 6, TRUE),

-- College / School Friend
('college_school_friend', 'What was a defining late-night conversation you had about what you both wanted out of life?', 1, TRUE),
('college_school_friend', 'Describe a moment during school or young adulthood when they helped you survive a crisis.', 2, TRUE),
('college_school_friend', 'What was an unforgettable celebration, road trip, or milestone you conquered together?', 3, TRUE),
('college_school_friend', 'How did you see their ambition, intellect, or passion ignite during those formative years?', 4, TRUE),
('college_school_friend', 'What inside joke or campus tradition will always belong to them?', 5, TRUE),
('college_school_friend', 'How did their friendship shape the trajectory of who you became as an adult?', 6, TRUE),

-- Work / Professional Colleague & Friend
('work_colleague_friend', 'What was it like to witness them in action when stakes were high and pressure was on?', 1, TRUE),
('work_colleague_friend', 'Describe a time they took heat or advocated for you behind closed doors.', 2, TRUE),
('work_colleague_friend', 'What did they model about integrity, work ethic, and treating people with dignity on the job?', 3, TRUE),
('work_colleague_friend', 'What was a disastrous work situation that you two turned into laughter over coffee or drinks?', 4, TRUE),
('work_colleague_friend', 'What piece of career or life wisdom from them still guides your daily decisions?', 5, TRUE),
('work_colleague_friend', 'What was their unspoken superpower in the workplace that everyone relied upon?', 6, TRUE),

-- Lifelong / Close Friend
('lifelong_friend', 'What season of life tested your friendship, and how did they prove their loyalty?', 1, TRUE),
('lifelong_friend', 'Describe a time you watched them face personal pain with quiet courage and grace.', 2, TRUE),
('lifelong_friend', 'What was a time they showed up on your doorstep right when your life was falling apart?', 3, TRUE),
('lifelong_friend', 'What was the most joyful chapter of your friendship, and what made it so golden?', 4, TRUE),
('lifelong_friend', 'What did they teach you about yourself that no one else was brave enough or loving enough to say?', 5, TRUE),
('lifelong_friend', 'If you could have one more afternoon on a front porch with them, what would you say?', 6, TRUE),

-- Travel / Hobby Friend
('travel_hobby_friend', 'What was a memorable journey, expedition, or shared passion where they were in their absolute element?', 1, TRUE),
('travel_hobby_friend', 'What was a moment when things went completely wrong on an adventure, and how did their demeanor save the day?', 2, TRUE),
('travel_hobby_friend', 'What did watching them pursue their craft, hobby, or sport teach you about living fully?', 3, TRUE),
('travel_hobby_friend', 'What was a hilarious or wild mishap on the road that you still recount to this day?', 4, TRUE),
('travel_hobby_friend', 'How did they bring beauty, curiosity, or wonder into the world around them?', 5, TRUE),
('travel_hobby_friend', 'What landscape, trail, or place in the world will forever remind you of their spirit?', 6, TRUE),

-- ============================================================================
-- 3. ASSOCIATES, MENTEES & ADMIRERS
-- ============================================================================

-- Mentee / Student
('mentee_student', 'What was a specific moment they saw potential in you before you could see it in yourself?', 1, TRUE),
('mentee_student', 'What was the hardest piece of constructive truth they gave you that changed your path for the better?', 2, TRUE),
('mentee_student', 'Describe how they treated you when you made a costly mistake.', 3, TRUE),
('mentee_student', 'What was a moment you saw them demonstrate quiet humility or kindness when nobody was looking?', 4, TRUE),
('mentee_student', 'What principle from them do you now pass down to younger people or students you mentor?', 5, TRUE),
('mentee_student', 'What do you want their loved ones to know about their legacy through the people they lifted up?', 6, TRUE),

-- Neighbor
('neighbor', 'What was a simple, daily way their presence made your street or neighborhood feel safer and warmer?', 1, TRUE),
('neighbor', 'Describe a time during a storm, emergency, or difficult season when they were the first to knock on your door.', 2, TRUE),
('neighbor', 'What was a small kindness—over the fence, in the driveway, or on the sidewalk—that stayed with you?', 3, TRUE),
('neighbor', 'What was a funny or endearing neighborly interaction you shared over the years?', 4, TRUE),
('neighbor', 'What will feel most empty about your community now that their porch light is off?', 5, TRUE),
('neighbor', 'What did they teach you about what it truly means to love your neighbor?', 6, TRUE),

-- Community / Faith Member
('community_faith_member', 'What was a moment you watched them serve others without ever seeking credit or attention?', 1, TRUE),
('community_faith_member', 'How did their faith, conviction, or moral compass shine when times were dark?', 2, TRUE),
('community_faith_member', 'Describe a time their words or prayers brought comfort to someone in deep distress.', 3, TRUE),
('community_faith_member', 'What was a joyful community tradition, potluck, or event where they were the heart and soul?', 4, TRUE),
('community_faith_member', 'What did their devotion teach the rest of the congregation or community?', 5, TRUE),
('community_faith_member', 'How did they leave our shared community better than they found it?', 6, TRUE),

-- Admirer / Acquaintance
('admirer_acquaintance', 'Even from a distance, what was something about how they carried themselves that commanded your deep respect?', 1, TRUE),
('admirer_acquaintance', 'Describe a single interaction with them that left a lasting imprint on your memory.', 2, TRUE),
('admirer_acquaintance', 'What was an act of generosity, excellence, or courage you witnessed them do in public?', 3, TRUE),
('admirer_acquaintance', 'How did the way they spoke about their family or work inspire you in your own life?', 4, TRUE),
('admirer_acquaintance', 'What will you remember most about the energy they brought into every room they walked into?', 5, TRUE),
('admirer_acquaintance', 'What lesson does their life offer to anyone striving to live with dignity and purpose?', 6, TRUE);
