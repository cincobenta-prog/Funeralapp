//
//  QuestionBankService.swift
//  DigiTributeCore
//
//  Manages relationship-specific prompts for Digital Tribute across:
//  1. Family Members
//  2. Expanded Types of Friends (Childhood, College, Work, Lifelong, Travel/Hobby)
//  3. Associates, Mentees & Admirers (Student, Neighbor, Faith/Community, Admirer)
//  Anchored in 4 core impact pillars: Joy, Pain & Resilience, Help & Sacrifice, and Witnessing Them in Action.
//

import Foundation

public actor QuestionBankService {
    public static let shared = QuestionBankService()

    private var cachedTopics: [String: [Topic]] = [:]

    public init() {}

    /// Returns 4 to 6 randomized prompts for a selected relationship type.
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

    // MARK: - Built-in Fallback Prompts for All Expanded Relationships
    public static func localFallbackTopics(for relationship: RelationshipType) -> [Topic] {
        let questions: [(text: String, pillar: ImpactPillar)]

        switch relationship {
        // --- 1. FAMILY ---
        case .father:
            questions = [
                ("What's a piece of advice from him that you still find yourself repeating?", .helpSacrifice),
                ("Describe a moment he showed up for you when it mattered most.", .helpSacrifice),
                ("What did he teach you, without ever saying it out loud, just by how he lived?", .witnessingInAction),
                ("What's a story about him that always makes you laugh?", .joy),
                ("How did he show love or weather hard seasons, even if he wasn't the type to speak about it?", .painResilience),
                ("What do you hope his grandchildren or future generations know about his character?", .witnessingInAction)
            ]
        case .mother:
            questions = [
                ("What's something she said to you that you'll never forget?", .helpSacrifice),
                ("Describe a time she sacrificed something for you that you didn't fully understand until later.", .helpSacrifice),
                ("What tradition, joyful habit, or recipe of hers have you carried into your own life?", .joy),
                ("What's a story that captures exactly who she was under pressure or in grief?", .painResilience),
                ("How did she make the people around her feel valued and safe?", .witnessingInAction),
                ("What do you want her grandchildren or the next generation to know about her heart?", .witnessingInAction)
            ]
        case .spousePartner:
            questions = [
                ("What's the real story of how you two got together, and the moment you knew?", .joy),
                ("What's something they did every day that was a quiet act of devotion?", .helpSacrifice),
                ("Describe a season of deep trial or pain where you held each other up.", .painResilience),
                ("What's an inside joke or private language only the two of you understood?", .joy),
                ("How did watching them live their life change who you became?", .witnessingInAction),
                ("What do you want anyone who loved them to understand about the soul behind the marriage?", .witnessingInAction)
            ]
        case .brother:
            questions = [
                ("What's a memory from childhood with him that still makes you smile or burst into laughter?", .joy),
                ("Describe a moment he had your back when everyone else walked away.", .helpSacrifice),
                ("What was something only the two of you found funny?", .joy),
                ("How did you see him face adversity or pain as he grew older?", .painResilience),
                ("What did he teach you about loyalty that no one else could have?", .witnessingInAction),
                ("What do you want people to know about him beyond being 'someone's brother'?", .witnessingInAction)
            ]
        case .sister:
            questions = [
                ("What's a memory from childhood with her that still makes you smile or laugh?", .joy),
                ("Describe a moment she showed up with unwavering support when you were struggling.", .helpSacrifice),
                ("What was something only the two of you shared or found funny?", .joy),
                ("How did you see her handle difficult seasons or personal hardship with grace?", .painResilience),
                ("What did she teach you about resilience and strength?", .witnessingInAction),
                ("What do you want people to know about her unique spirit beyond family titles?", .witnessingInAction)
            ]
        case .son:
            questions = [
                ("What's a moment he made you proud in a way that took your breath away?", .joy),
                ("What did he teach you, even though you were supposed to be the one teaching him?", .witnessingInAction),
                ("Describe who he was becoming and the passions that drove him.", .witnessingInAction),
                ("What's a memory that captures his infectious joy and personality perfectly?", .joy),
                ("Describe a battle he fought or challenge he faced with bravery.", .painResilience),
                ("What do you want to make sure is never forgotten about his impact on your life?", .helpSacrifice)
            ]
        case .daughter:
            questions = [
                ("What's a moment she made you proud in a way that took your breath away?", .joy),
                ("What did she teach you, even though you were supposed to be the one teaching her?", .witnessingInAction),
                ("Describe who she was becoming and the fierce passions that drove her.", .witnessingInAction),
                ("What's a memory that captures her radiant joy and personality perfectly?", .joy),
                ("Describe a difficult mountain she climbed with grace and determination.", .painResilience),
                ("What do you want to make sure is forever remembered about her spirit?", .helpSacrifice)
            ]
        case .grandfather:
            questions = [
                ("What's a piece of grandfatherly wisdom or phrase from him that's stuck with you for life?", .helpSacrifice),
                ("Describe a specific memory of quiet time spent just the two of you.", .joy),
                ("What skill, trade, or family history did he pass down with his hands?", .witnessingInAction),
                ("How did he endure hard times and model steady resilience for the whole family?", .painResilience),
                ("What made his laugh, presence, or storytelling unmistakable?", .joy),
                ("What do you want great-grandchildren who never met him to understand about his legacy?", .witnessingInAction)
            ]
        case .grandmother:
            questions = [
                ("What's something she used to say or do that wrapped everyone in comfort?", .helpSacrifice),
                ("Describe a specific memory of time spent in her presence or kitchen.", .joy),
                ("What tradition, recipe, or unspoken wisdom did she pass down to you?", .witnessingInAction),
                ("How did she hold the family together during seasons of sorrow or change?", .painResilience),
                ("What was an unforgettable, hilarious moment where her true personality shone?", .joy),
                ("What do you want future generations to know about the strength of her love?", .witnessingInAction)
            ]
        case .extendedFamily:
            questions = [
                ("What was your specific bond with them, and what made holiday gatherings with them unforgettable?", .joy),
                ("Describe a time they supported you directly when you were going through a rough patch.", .helpSacrifice),
                ("What's a hilarious or legendary family story about them the rest of the world might not know?", .joy),
                ("How did you see them show up for the family when someone was sick or hurting?", .painResilience),
                ("What did watching them live their life model for you as you grew up?", .witnessingInAction),
                ("What do you want the younger generations to cherish about their contribution to the family tree?", .witnessingInAction)
            ]
        case .inLaw:
            questions = [
                ("How did they welcome you into the family fold with warmth from the very beginning?", .helpSacrifice),
                ("What was an unexpected moment of understanding or laughter between you two?", .joy),
                ("What did they teach you about keeping a family bonded across different backgrounds?", .witnessingInAction),
                ("How did they stand by the family during hospital stays, loss, or tough seasons?", .painResilience),
                ("What funny quirk or catchphrase of theirs became beloved across the extended family?", .joy),
                ("What will you miss most about their presence at family milestones?", .witnessingInAction)
            ]
        case .chosenFamily:
            questions = [
                ("How did you two choose each other as family, and what made that bond unbreakable?", .witnessingInAction),
                ("Describe a painful season when they stood in the gap for you like blood family couldn't.", .painResilience),
                ("What was a moment of pure, unrestrained joy and celebration you experienced together?", .joy),
                ("What unspoken sacrifice did they make for you without ever asking for credit?", .helpSacrifice),
                ("What did their devotion teach you about real, unconditional love?", .witnessingInAction),
                ("What promise to them will you carry in your heart for the rest of your days?", .helpSacrifice)
            ]

        // --- 2. EXPANDED FRIENDSHIP TYPES ---
        case .childhoodFriend:
            questions = [
                ("What was an unforgettable adventure or secret from growing up that only the two of you knew about?", .joy),
                ("What was a moment in your early years when they defended you or had your back?", .helpSacrifice),
                ("What did you two laugh about so hard that it brought you to tears?", .joy),
                ("How did you see their core integrity and loyalty stay steady from childhood into adulthood?", .witnessingInAction),
                ("Describe how you two supported each other through the awkward or painful growing-up years.", .painResilience),
                ("What do you want their family to know about the young kid they were before the world met them?", .witnessingInAction)
            ]
        case .collegeSchoolFriend:
            questions = [
                ("What was a defining late-night conversation about life, dreams, or fears you shared in school?", .witnessingInAction),
                ("Describe a moment during young adulthood when they helped pull you through an emotional or academic crisis.", .painResilience),
                ("What was an unforgettable road trip, celebration, or milestone you conquered together?", .joy),
                ("How did you see their intellect, passion, or ambition ignite during those formative years?", .witnessingInAction),
                ("What was a time their generosity or friendship saved your week?", .helpSacrifice),
                ("How did their presence during your school years shape the trajectory of who you became?", .witnessingInAction)
            ]
        case .workColleagueFriend:
            questions = [
                ("What was it like to witness them in action when stakes were high and pressure was on?", .witnessingInAction),
                ("Describe a time they advocated for you, mentored you, or took heat on your behalf.", .helpSacrifice),
                ("What was a stressful or disastrous work situation that you two turned into laughter?", .joy),
                ("What did they model about dignity, fairness, and work ethic in a tough environment?", .witnessingInAction),
                ("How did they support you or colleagues through burnout, personal loss, or company crises?", .painResilience),
                ("What piece of professional or life wisdom from them will you carry into every job you ever have?", .helpSacrifice)
            ]
        case .lifelongFriend:
            questions = [
                ("What season of life tested your friendship, and how did their loyalty shine through?", .painResilience),
                ("Describe a time they showed up on your doorstep without asking right when your world was falling apart.", .helpSacrifice),
                ("What was the most golden, joyful chapter of your friendship, and what made it so special?", .joy),
                ("What did watching them walk through life's highs and lows teach you about human resilience?", .painResilience),
                ("What did they teach you about yourself that no one else was loving enough to point out?", .witnessingInAction),
                ("If you could sit with them for one more quiet afternoon, what would you say to them?", .helpSacrifice)
            ]
        case .travelHobbyFriend:
            questions = [
                ("What was an epic journey, expedition, or shared hobby where they were in their absolute element?", .joy),
                ("What was a moment when things went completely sideways on an adventure, and how did their calm save the day?", .painResilience),
                ("What did watching them pursue their craft, sport, or passion teach you about living fully?", .witnessingInAction),
                ("What was a hilarious mishap on the road that you still recount to everyone you meet?", .joy),
                ("What act of spontaneous generosity did they perform for a stranger or teammate?", .helpSacrifice),
                ("What mountain, trail, water, or place in the world will forever echo with their spirit?", .witnessingInAction)
            ]

        // --- 3. ASSOCIATES, MENTEES & ADMIRERS ---
        case .menteeStudent:
            questions = [
                ("What was a specific moment they believed in your potential before you believed in yourself?", .helpSacrifice),
                ("What was the most transformative piece of constructive truth they gave you?", .helpSacrifice),
                ("Describe how they handled it when you made a major mistake or stumbled.", .painResilience),
                ("What was a moment you saw them demonstrate quiet humility when no cameras or bosses were watching?", .witnessingInAction),
                ("What habit or standard of excellence from them do you now pass down to others you teach?", .witnessingInAction),
                ("What do you want their family to understand about their enduring legacy through the people they elevated?", .helpSacrifice)
            ]
        case .neighbor:
            questions = [
                ("What was a simple, daily way their presence made your street or neighborhood feel warmer and safer?", .witnessingInAction),
                ("Describe a time during a storm, power outage, or emergency when they were the first to check in on you.", .helpSacrifice),
                ("What was a small driveway, garden, or sidewalk interaction that brightened your whole day?", .joy),
                ("How did they support the neighborhood through tough times or losses?", .painResilience),
                ("What quirky, endearing, or generous neighborhood habit of theirs will everyone miss?", .joy),
                ("What did they teach you about what it really means to love the people next door?", .witnessingInAction)
            ]
        case .communityFaithMember:
            questions = [
                ("What was a moment you watched them serve others quietly without ever seeking applause?", .helpSacrifice),
                ("How did their faith, conviction, or moral compass shine when times were difficult or controversial?", .painResilience),
                ("Describe a time their words, prayer, or presence brought comfort to someone in despair.", .painResilience),
                ("What was a joyful community celebration or event where their energy was the heartbeat of the room?", .joy),
                ("What did watching their devotion teach the rest of the community about living with purpose?", .witnessingInAction),
                ("How did their life make our shared community fundamentally better than they found it?", .witnessingInAction)
            ]
        case .admirerAcquaintance:
            questions = [
                ("Even observing them from a distance, what was something about how they carried themselves that commanded respect?", .witnessingInAction),
                ("Describe a single brief interaction with them that left a lasting, positive imprint on your life.", .helpSacrifice),
                ("What was an act of generosity, courage, or public excellence you witnessed them do?", .witnessingInAction),
                ("How did the way they spoke about their family or values inspire you to be a better person?", .helpSacrifice),
                ("What was something about their resilience in the face of public or personal trials that inspired you?", .painResilience),
                ("What lesson does their life offer to anyone striving to live with honor and impact?", .witnessingInAction)
            ]
        }

        return questions.enumerated().map { index, q in
            Topic(
                id: UUID(),
                relationshipType: relationship.rawValue,
                questionText: q.text,
                sortOrder: index + 1,
                active: true,
                pillar: q.pillar,
                createdAt: nil
            )
        }
    }
}
