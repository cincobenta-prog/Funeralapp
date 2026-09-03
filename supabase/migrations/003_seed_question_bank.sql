-- Digi-Tribute: Complete Question Bank Seed Migration
-- Populates the 13 core relationship categories with all 78 curated prompts.

INSERT INTO topics (relationship_type, question_text, sort_order, active) VALUES
-- ==========================================
-- 1. Father
-- ==========================================
('father', 'What''s a piece of advice from him that you still find yourself repeating?', 1, TRUE),
('father', 'Describe a moment he showed up for you when it mattered most.', 2, TRUE),
('father', 'What did he teach you, without ever saying it out loud, just by how he lived?', 3, TRUE),
('father', 'What''s a story about him that always makes you laugh?', 4, TRUE),
('father', 'How did he show love, even if he wasn''t the type to say it?', 5, TRUE),
('father', 'What do you hope his grandchildren, or future generations, know about him?', 6, TRUE),

-- ==========================================
-- 2. Mother
-- ==========================================
('mother', 'What''s something she said to you that you''ll never forget?', 1, TRUE),
('mother', 'Describe a time she sacrificed something for you that you didn''t fully understand until later.', 2, TRUE),
('mother', 'What tradition or habit of hers have you carried into your own life?', 3, TRUE),
('mother', 'What''s a story that captures exactly who she was?', 4, TRUE),
('mother', 'How did she make the people around her feel?', 5, TRUE),
('mother', 'What do you want her grandchildren, or the next generation, to know about her?', 6, TRUE),

-- ==========================================
-- 3. Brother
-- ==========================================
('brother', 'What''s a memory from childhood with him that still makes you smile?', 1, TRUE),
('brother', 'What did he teach you that no one else could have?', 2, TRUE),
('brother', 'Describe a moment he had your back.', 3, TRUE),
('brother', 'What was something only the two of you found funny?', 4, TRUE),
('brother', 'How did your relationship change as you both got older?', 5, TRUE),
('brother', 'What do you want people to know about him beyond being "someone''s brother"?', 6, TRUE),

-- ==========================================
-- 4. Sister
-- ==========================================
('sister', 'What''s a memory from childhood with her that still makes you smile?', 1, TRUE),
('sister', 'What did she teach you that no one else could have?', 2, TRUE),
('sister', 'Describe a moment she had your back.', 3, TRUE),
('sister', 'What was something only the two of you found funny?', 4, TRUE),
('sister', 'How did your relationship change as you both got older?', 5, TRUE),
('sister', 'What do you want people to know about her beyond being "someone''s sister"?', 6, TRUE),

-- ==========================================
-- 5. Spouse or Partner
-- ==========================================
('spouse_partner', 'What''s the real story of how you two got together?', 1, TRUE),
('spouse_partner', 'What''s something they did every day that you didn''t appreciate enough until now?', 2, TRUE),
('spouse_partner', 'Describe a moment you knew this was the person you wanted to build a life with.', 3, TRUE),
('spouse_partner', 'What''s an inside joke or private language only the two of you understood?', 4, TRUE),
('spouse_partner', 'How did they change who you are?', 5, TRUE),
('spouse_partner', 'What do you want anyone who loved them to know about the person behind the marriage?', 6, TRUE),

-- ==========================================
-- 6. Son
-- ==========================================
('son', 'What''s a moment he made you proud in a way that surprised you?', 1, TRUE),
('son', 'What did he teach you, even though you were supposed to be the one teaching him?', 2, TRUE),
('son', 'Describe who he was becoming, in his own words if you can capture them.', 3, TRUE),
('son', 'What''s a memory that captures his personality perfectly?', 4, TRUE),
('son', 'What do you wish more people had gotten to see in him?', 5, TRUE),
('son', 'What do you want to make sure is never forgotten about him?', 6, TRUE),

-- ==========================================
-- 7. Daughter
-- ==========================================
('daughter', 'What''s a moment she made you proud in a way that surprised you?', 1, TRUE),
('daughter', 'What did she teach you, even though you were supposed to be the one teaching her?', 2, TRUE),
('daughter', 'Describe who she was becoming, in her own words if you can capture them.', 3, TRUE),
('daughter', 'What''s a memory that captures her personality perfectly?', 4, TRUE),
('daughter', 'What do you wish more people had gotten to see in her?', 5, TRUE),
('daughter', 'What do you want to make sure is never forgotten about her?', 6, TRUE),

-- ==========================================
-- 8. Grandfather
-- ==========================================
('grandfather', 'What''s something he used to say that''s stuck with you for life?', 1, TRUE),
('grandfather', 'Describe a specific memory of time spent just the two of you.', 2, TRUE),
('grandfather', 'What skill, story, or piece of family history did he pass down?', 3, TRUE),
('grandfather', 'What made him different from anyone else in the family?', 4, TRUE),
('grandfather', 'How did he show up for the family, even in small ways?', 5, TRUE),
('grandfather', 'What do you want great-grandchildren who never met him to understand about who he was?', 6, TRUE),

-- ==========================================
-- 9. Grandmother
-- ==========================================
('grandmother', 'What''s something she used to say that''s stuck with you for life?', 1, TRUE),
('grandmother', 'Describe a specific memory of time spent just the two of you.', 2, TRUE),
('grandmother', 'What skill, recipe, story, or piece of family history did she pass down?', 3, TRUE),
('grandmother', 'What made her different from anyone else in the family?', 4, TRUE),
('grandmother', 'How did she show up for the family, even in small ways?', 5, TRUE),
('grandmother', 'What do you want great-grandchildren who never met her to understand about who she was?', 6, TRUE),

-- ==========================================
-- 10. Friend
-- ==========================================
('friend', 'How did you two actually meet, and what made the friendship stick?', 1, TRUE),
('friend', 'What''s a moment they showed up for you that you''ll never forget?', 2, TRUE),
('friend', 'What''s an inside joke, nickname, or ritual only your friend group understood?', 3, TRUE),
('friend', 'What did they teach you about being a friend?', 4, TRUE),
('friend', 'Describe them in a way that would make someone who never met them wish they had.', 5, TRUE),
('friend', 'What''s the story you''ll tell about them for the rest of your life?', 6, TRUE),

-- ==========================================
-- 11. Extended Family (Aunt, Uncle, Cousin)
-- ==========================================
('extended_family', 'What''s your specific relationship to them, and what made it unique?', 1, TRUE),
('extended_family', 'Describe a family gathering or tradition where they were unforgettable.', 2, TRUE),
('extended_family', 'What did they teach you or model for you growing up?', 3, TRUE),
('extended_family', 'What''s a story about them the rest of the family might not know?', 4, TRUE),
('extended_family', 'How did they show up for you specifically, not just the family as a whole?', 5, TRUE),
('extended_family', 'What do you want younger family members to know about them?', 6, TRUE),

-- ==========================================
-- 12. Mentor, Teacher, or Colleague
-- ==========================================
('mentor_colleague', 'What did they teach you that went beyond the job or the classroom?', 1, TRUE),
('mentor_colleague', 'Describe a specific moment they believed in you before you believed in yourself.', 2, TRUE),
('mentor_colleague', 'What''s something they said that changed how you approach your work or your life?', 3, TRUE),
('mentor_colleague', 'How did they treat people, especially when no one was watching?', 4, TRUE),
('mentor_colleague', 'What''s a story that captures who they were as a professional and as a person?', 5, TRUE),
('mentor_colleague', 'What do you want the people they worked with to remember about them?', 6, TRUE),

-- ==========================================
-- 13. Community or Other
-- ==========================================
('community_other', 'How did you know them, and what role did they play in your life?', 1, TRUE),
('community_other', 'Describe a specific moment they made an impact on you or someone you know.', 2, TRUE),
('community_other', 'What''s a story about them that shows who they really were?', 3, TRUE),
('community_other', 'How did they show up for the community around them?', 4, TRUE),
('community_other', 'What do you want people who didn''t know them well to understand?', 5, TRUE),
('community_other', 'What''s one thing you hope is never forgotten about them?', 6, TRUE);
