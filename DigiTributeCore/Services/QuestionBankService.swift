//
//  QuestionBankService.swift
//  DigiTributeCore
//
//  Manages relationship-specific prompts for Digi-Tribute.
//  Implements randomized selection (4 to 6 prompts) and freeform memory workflows.
//

import Foundation

public actor QuestionBankService {
    public static let shared = QuestionBankService()

    private var cachedTopics: [String: [Topic]] = [:]

    public init() {}

    /// Returns 4 to 6 randomized prompts for a selected relationship type.
    /// Ensures a warm, varied, and non-repetitive prompt experience.
    public func getPrompts(
        for relationship: RelationshipType,
        count: Int = 5,
        availableTopics: [Topic]? = nil
    ) -> [Topic] {
        let pool: [Topic]
        if let provided = availableTopics, !provided.isEmpty {
            pool = provided.filter { $0.relationshipType == relationship.rawValue && $0.active }
        } else if let cached = cachedTopics[relationship.rawValue], !cached.isEmpty {
            pool = cached
        } else {
            pool = Self.localFallbackTopics(for: relationship)
        }

        // Randomize and take desired count (clamped between 4 and 6)
        let targetCount = min(max(count, 4), 6)
        return Array(pool.shuffled().prefix(targetCount))
    }

    /// Caches loaded topics grouped by relationship type
    public func cacheTopics(_ topics: [Topic]) {
        var grouped: [String: [Topic]] = [:]
        for topic in topics where topic.active {
            grouped[topic.relationshipType, default: []].append(topic)
        }
        self.cachedTopics = grouped
    }

    // MARK: - Built-in Fallback Prompts (Offline Safety)
    public static func localFallbackTopics(for relationship: RelationshipType) -> [Topic] {
        let questions: [String]
        switch relationship {
        case .father:
            questions = [
                "What's a piece of advice from him that you still find yourself repeating?",
                "Describe a moment he showed up for you when it mattered most.",
                "What did he teach you, without ever saying it out loud, just by how he lived?",
                "What's a story about him that always makes you laugh?",
                "How did he show love, even if he wasn't the type to say it?",
                "What do you hope his grandchildren, or future generations, know about him?"
            ]
        case .mother:
            questions = [
                "What's something she said to you that you'll never forget?",
                "Describe a time she sacrificed something for you that you didn't fully understand until later.",
                "What tradition or habit of hers have you carried into your own life?",
                "What's a story that captures exactly who she was?",
                "How did she make the people around her feel?",
                "What do you want her grandchildren, or the next generation, to know about her?"
            ]
        case .brother:
            questions = [
                "What's a memory from childhood with him that still makes you smile?",
                "What did he teach you that no one else could have?",
                "Describe a moment he had your back.",
                "What was something only the two of you found funny?",
                "How did your relationship change as you both got older?",
                "What do you want people to know about him beyond being \"someone's brother\"?"
            ]
        case .sister:
            questions = [
                "What's a memory from childhood with her that still makes you smile?",
                "What did she teach you that no one else could have?",
                "Describe a moment she had your back.",
                "What was something only the two of you found funny?",
                "How did your relationship change as you both got older?",
                "What do you want people to know about her beyond being \"someone's sister\"?"
            ]
        case .spousePartner:
            questions = [
                "What's the real story of how you two got together?",
                "What's something they did every day that you didn't appreciate enough until now?",
                "Describe a moment you knew this was the person you wanted to build a life with.",
                "What's an inside joke or private language only the two of you understood?",
                "How did they change who you are?",
                "What do you want anyone who loved them to know about the person behind the marriage?"
            ]
        case .son:
            questions = [
                "What's a moment he made you proud in a way that surprised you?",
                "What did he teach you, even though you were supposed to be the one teaching him?",
                "Describe who he was becoming, in his own words if you can capture them.",
                "What's a memory that captures his personality perfectly?",
                "What do you wish more people had gotten to see in him?",
                "What do you want to make sure is never forgotten about him?"
            ]
        case .daughter:
            questions = [
                "What's a moment she made you proud in a way that surprised you?",
                "What did she teach you, even though you were supposed to be the one teaching her?",
                "Describe who she was becoming, in his own words if you can capture them.",
                "What's a memory that captures her personality perfectly?",
                "What do you wish more people had gotten to see in her?",
                "What do you want to make sure is never forgotten about her?"
            ]
        case .grandfather:
            questions = [
                "What's something he used to say that's stuck with you for life?",
                "Describe a specific memory of time spent just the two of you.",
                "What skill, story, or piece of family history did he pass down?",
                "What made him different from anyone else in the family?",
                "How did he show up for the family, even in small ways?",
                "What do you want great-grandchildren who never met him to understand about who he was?"
            ]
        case .grandmother:
            questions = [
                "What's something she used to say that's stuck with you for life?",
                "Describe a specific memory of time spent just the two of you.",
                "What skill, recipe, story, or piece of family history did she pass down?",
                "What made her different from anyone else in the family?",
                "How did she show up for the family, even in small ways?",
                "What do you want great-grandchildren who never met her to understand about who she was?"
            ]
        case .friend:
            questions = [
                "How did you two actually meet, and what made the friendship stick?",
                "What's a moment they showed up for you that you'll never forget?",
                "What's an inside joke, nickname, or ritual only your friend group understood?",
                "What did they teach you about being a friend?",
                "Describe them in a way that would make someone who never met them wish they had.",
                "What's the story you'll tell about them for the rest of your life?"
            ]
        case .extendedFamily:
            questions = [
                "What's your specific relationship to them, and what made it unique?",
                "Describe a family gathering or tradition where they were unforgettable.",
                "What did they teach you or model for you growing up?",
                "What's a story about them the rest of the family might not know?",
                "How did they show up for you specifically, not just the family as a whole?",
                "What do you want younger family members to know about them?"
            ]
        case .mentorColleague:
            questions = [
                "What did they teach you that went beyond the job or the classroom?",
                "Describe a specific moment they believed in you before you believed in yourself.",
                "What's something they said that changed how you approach your work or your life?",
                "How did they treat people, especially when no one was watching?",
                "What's a story that captures who they were as a professional and as a person?",
                "What do you want the people they worked with to remember about them?"
            ]
        case .communityOther:
            questions = [
                "How did you know them, and what role did they play in your life?",
                "Describe a specific moment they made an impact on you or someone you know.",
                "What's a story about them that shows who they really were?",
                "How did they show up for the community around them?",
                "What do you want people who didn't know them well to understand?",
                "What's one thing you hope is never forgotten about them?"
            ]
        }

        return questions.enumerated().map { index, text in
            Topic(
                id: UUID(),
                relationshipType: relationship.rawValue,
                questionText: text,
                sortOrder: index + 1,
                active: true,
                createdAt: nil
            )
        }
    }
}
