//
//  QuestionBankService.swift
//  DigiTributeCore
//
//  Manages relationship-specific prompts & paired conversational follow-ups for Digital Tribute across:
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

    /// Returns 4 to 6 randomized prompts with conversational follow-up questions for a selected relationship type.
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

    // MARK: - Built-in Fallback Prompts with Conversational Follow-Up Questions
    public static func localFallbackTopics(for relationship: RelationshipType) -> [Topic] {
        let questions: [(text: String, followUp: String, pillar: ImpactPillar)]

        switch relationship {
        // --- 1. FAMILY ---
        case .father:
            questions = [
                ("What was an unspoken lesson your father taught you just by how he worked with his hands and lived his daily life?", "When was the last time you caught yourself doing things the exact same way, and what went through your mind?", .witnessingInAction),
                ("Describe a moment when you were hurting and your father showed up without making a fuss.", "What did his quiet presence tell you about what it really means to protect and care for someone?", .helpSacrifice),
                ("What is a piece of fatherly advice or catchphrase you used to roll your eyes at, but now find yourself quoting to others?", "How has carrying that advice shaped your own path in life?", .joy),
                ("What was a heavy burden or heartbreak you saw him carry with quiet dignity?", "What did watching him endure that storm teach you about human resilience?", .painResilience),
                ("What made his eyes light up with unmistakable pride whenever he spoke about his children?", "If you could tell him one last thing about the man he was, what would you say?", .witnessingInAction)
            ]

        case .mother:
            questions = [
                ("What is a scent, sound, or ritual from your mother's kitchen that will always bring her right back to you?", "What was the unspoken love or care she poured into those moments that made you feel completely safe?", .joy),
                ("Describe a sacrifice she quietly made for you that you didn't fully understand until you became an adult.", "When did the realization hit you of just how much love was behind that decision?", .helpSacrifice),
                ("What was a time your mother held you together when your world was falling apart?", "What words or touch of hers gave you the strength to stand back up?", .painResilience),
                ("What was something fiercely independent or hilarious about her that only her inner circle knew?", "What memory captures that radiant fire best of all?", .joy),
                ("What value or tradition of hers do you most hope lives on for generations?", "How do you plan to keep that flame burning in her honor?", .witnessingInAction)
            ]

        case .spousePartner:
            questions = [
                ("What was the exact moment or ordinary day when you realized, 'This is the person I want to build a life with'?", "What was it about how they treated you that made you completely certain?", .joy),
                ("What was a quiet, private ritual of love they did every single day that you already miss so deeply?", "How did that steady daily devotion anchor your home across the decades?", .helpSacrifice),
                ("Describe the darkest valley you walked through together and how they held your hand through the storm.", "What did their unwavering loyalty in that season reveal about their soul?", .painResilience),
                ("What was your private shorthand, inside joke, or unspoken look across a crowded room?", "What memory of laughing together in the middle of the night brings warmth to your chest?", .joy),
                ("If you could whisper one final promise into their ear for eternity, what would you promise them?", "How will their love continue to guide your footsteps forward?", .witnessingInAction)
            ]

        case .brother:
            questions = [
                ("What was a childhood scheme, treehouse secret, or adventure with him that only the two of you knew about?", "What was the moment during that adventure where you both laughed until you couldn't breathe?", .joy),
                ("Describe a time your brother had your back when everyone else walked away.", "How did his loyalty give you the courage to stand your ground?", .helpSacrifice),
                ("What was a difficult season you watched him navigate as he grew into adulthood?", "What did seeing him endure that battle teach you about his inner strength?", .painResilience),
                ("What was a quirky habit or funny rivalry only the two of you shared?", "How did your bond evolve over the years as you both got older?", .joy),
                ("What do you want people to remember about who he was as a man beyond just being 'someone's brother'?", "What will you miss most about hearing his voice?", .witnessingInAction)
            ]

        case .sister:
            questions = [
                ("What was a secret confidence or late-night conversation with her that you never shared with anyone else?", "What did her advice in that moment reveal about how deeply she understood you?", .joy),
                ("Describe a time your sister showed up with fierce support when you were brokenhearted.", "What did she do or say that reminded you who you were?", .helpSacrifice),
                ("What was a hardship you watched her face with grace and determination?", "How did her resilience inspire you during your own struggles?", .painResilience),
                ("What was an unforgettable, hilarious moment where her true spirit and laugh took over the room?", "Why will that memory always bring a smile to your face?", .joy),
                ("What do you want the next generation of girls in the family to know about her courage and heart?", "What part of her spirit lives on in you?", .witnessingInAction)
            ]

        case .son:
            questions = [
                ("What was a moment your son stood up for what was right in a way that took your breath away with pride?", "What did that moment tell you about the man he had become?", .witnessingInAction),
                ("What was an adventure or passion of his that he threw his whole soul into?", "How did his enthusiasm light up everyone around him?", .joy),
                ("What was a time he surprised you with his tenderness toward someone who was hurting?", "What does that story tell everyone about the size of his heart?", .helpSacrifice),
                ("What difficult challenge did you watch him face with bravery?", "What did he teach you about courage while fighting that battle?", .painResilience),
                ("What do you want to ensure is never forgotten about his unique mark on the world?", "If you could hold his hand one more time, what would you say?", .witnessingInAction)
            ]

        case .daughter:
            questions = [
                ("What was a moment your daughter showed a fierce, radiant kindness that made you realize how special she was?", "How did she have a way of seeing the best in people even when they couldn't see it in themselves?", .witnessingInAction),
                ("What is a memory of pure joy and laughter with her that plays in your mind like a favorite song?", "What made her laugh so completely infectious to everyone in the room?", .joy),
                ("Describe a time she supported you or someone else with wisdom far beyond her years.", "Where did she get that quiet strength and empathy?", .helpSacrifice),
                ("What mountain did she climb or adversity did she face with unwavering grace?", "What will you forever admire about how she handled that chapter of her life?", .painResilience),
                ("What will you forever carry in your heart about the bond you shared with her?", "What was her greatest gift to your life?", .witnessingInAction)
            ]

        case .grandfather:
            questions = [
                ("What was a piece of grandfatherly wisdom or phrase he passed down that has guided your life?", "When was a time you leaned on his advice during a major crossroads?", .helpSacrifice),
                ("Describe a memory of working with him in the garage, garden, or workshop.", "What did watching him work with his hands teach you about patience and craft?", .witnessingInAction),
                ("What was a historical storm or family hardship he weathered with steady calm?", "How did his steady presence reassure the whole family during troubled waters?", .painResilience),
                ("What was a funny, legendary grandfather story that everyone in the family loves to recount?", "What made his laugh and storytelling unmistakable?", .joy),
                ("What do you want your own children and grandchildren to understand about his legacy?", "How did he leave the family tree stronger than he found it?", .witnessingInAction)
            ]

        case .grandmother:
            questions = [
                ("What was a dish, phrase, or gentle touch of hers that made you feel completely loved and safe?", "What was the secret to how she made every grandchild feel like the most special person in the room?", .joy),
                ("Describe a time she held the family together during a time of sorrow or loss.", "Where did she find the grace and strength to keep everyone united?", .painResilience),
                ("What was a family story, heirloom, or recipe she passed down to your hands?", "How do you plan to pass that treasure to future generations?", .witnessingInAction),
                ("What was an unforgettable moment where her quick wit or humor surprised everyone?", "What did that moment tell you about who she was inside?", .joy),
                ("What was the greatest life lesson she gave you about love, faith, or family?", "What would you thank her for today if she were standing beside you?", .helpSacrifice)
            ]

        case .extendedFamily:
            questions = [
                ("What made holiday gatherings, family reunions, or visits with them so unforgettable?", "What unique energy or laughter did they bring into the family circle?", .joy),
                ("Describe a time they supported you directly when you were going through a difficult transition.", "What did their kindness mean to you in that season?", .helpSacrifice),
                ("What is a legendary family story about them that the younger generation needs to hear?", "Why does that story capture their personality so well?", .joy),
                ("How did you see them show up for the family when someone was sick or grieving?", "What did their devotion model for the rest of the cousins and relatives?", .painResilience),
                ("What will feel most different about family milestones without their presence?", "How will you honor their memory at the next gathering?", .witnessingInAction)
            ]

        case .inLaw:
            questions = [
                ("How did they welcome you into the family fold and make you feel like you truly belonged?", "What was a specific gesture of hospitality or warmth that put you at ease from day one?", .helpSacrifice),
                ("What was a moment of unexpected laughter or deep understanding between you two?", "How did your relationship grow from in-laws into genuine friends?", .joy),
                ("What did they teach you about keeping family bonded across different traditions?", "What did you admire most about their role in the family?", .witnessingInAction),
                ("How did they stand by the family during difficult seasons, illnesses, or losses?", "What did their quiet steadfastness mean to everyone around them?", .painResilience),
                ("What will you miss most about their seat at the holiday table?", "What do you want others to know about the heart behind their actions?", .joy)
            ]

        case .chosenFamily:
            questions = [
                ("How did you two choose each other as family, and what made that bond unbreakable?", "What was the moment you knew you were family for life, no matter what?", .witnessingInAction),
                ("Describe a painful season when they stood in the gap for you like blood family couldn't.", "How did their unconditional presence save you during that time?", .painResilience),
                ("What was a moment of pure, unrestrained celebration or joy you experienced together?", "What made that memory so magical?", .joy),
                ("What unspoken sacrifice did they make for you without ever asking for recognition?", "What did their devotion teach you about real love?", .helpSacrifice),
                ("What promise to them will you carry in your heart for the rest of your days?", "How has having them in your corner permanently changed who you are?", .witnessingInAction)
            ]

        // --- 2. EXPANDED FRIENDSHIP CATEGORIES ---
        case .childhoodFriend:
            questions = [
                ("What was a secret adventure, hideout, or scheme from growing up that only the two of you knew about?", "What was the moment during that adventure where you both laughed until your stomachs hurt?", .joy),
                ("Describe the moment on the playground, schoolyard, or street when they had your back against the odds.", "How did that childhood loyalty lay the foundation for who they became as an adult?", .helpSacrifice),
                ("What was the hardest thing you both endured while growing up together, and how did your friendship survive it?", "When you look back on those early years, what core truth about their spirit never changed?", .painResilience),
                ("What did you two talk about when dreaming about the future as kids?", "How did you see those early dreams take shape in their real life?", .witnessingInAction),
                ("What do you want their family and children to know about the young kid they were before the world met them?", "What was the purest part of their personality?", .joy)
            ]

        case .collegeSchoolFriend:
            questions = [
                ("What was a defining late-night dorm conversation about life, dreams, or fears you shared in school?", "What was something profound they said during those years that still resonates with you?", .witnessingInAction),
                ("Describe a moment during young adulthood when they helped pull you through an emotional or academic crisis.", "How did their friendship keep you grounded when everything felt uncertain?", .painResilience),
                ("What was an unforgettable road trip, celebration, or campus milestone you conquered together?", "What hilarious story from that trip will you tell for the rest of your life?", .joy),
                ("How did you see their ambition, intellect, or passion ignite during those formative years?", "What was their unmistakable talent even then?", .witnessingInAction),
                ("How did their presence during your school years shape the trajectory of who you became as an adult?", "What did their friendship give you that no degree ever could?", .helpSacrifice)
            ]

        case .workColleagueFriend:
            questions = [
                ("What was it like to witness them in the trenches when stakes were high and deadlines were crashing?", "How did their calmness, humor, or brilliant mind steer everyone through the storm?", .witnessingInAction),
                ("Describe a time they used their influence or stood up behind closed doors to advocate for you or a teammate.", "What did that action teach you about real professional integrity and leadership?", .helpSacrifice),
                ("What was the most disastrous work mishap or high-stress day that you two turned into legendary laughter?", "What made working with them feel less like a job and more like a shared adventure?", .joy),
                ("What did they model about dignity, fairness, and work ethic in a tough environment?", "What principle of theirs do you now bring to your own workplace?", .witnessingInAction),
                ("How did they support colleagues through burnout, personal loss, or company crises?", "What was their unspoken superpower in the workplace that everyone relied on?", .painResilience),
                ("What piece of professional or life wisdom from them will you carry into every job you ever hold?", "How do you plan to mentor others the way they mentored you?", .helpSacrifice)
            ]

        case .lifelongFriend:
            questions = [
                ("What season of life tested your friendship, and how did their loyalty shine through?", "How did you two always manage to pick right back up where you left off, no matter how much time had passed?", .painResilience),
                ("Describe a time they showed up on your doorstep without asking right when your world was falling apart.", "What did they do or say that made the darkness feel bearable?", .helpSacrifice),
                ("What was the most golden, joyful chapter of your friendship across all the decades?", "What made that era so special between you two?", .joy),
                ("What did watching them walk through life's highs and lows teach you about human resilience?", "What was a battle you saw them fight with quiet grace?", .painResilience),
                ("If you could sit with them for one more quiet afternoon on a front porch, what would you say to them?", "What is your final thank-you for their lifelong devotion?", .witnessingInAction)
            ]

        case .travelHobbyFriend:
            questions = [
                ("What was an epic journey, expedition, or shared passion where they were in their absolute element?", "What was a moment on that trip where you looked at them and thought, 'This is pure life'?", .joy),
                ("What was a moment when things went completely sideways on an adventure, and how did their calm save the day?", "What made traveling or creating with them unlike anyone else in the world?", .painResilience),
                ("What did watching them pursue their craft, sport, or hobby teach you about living with passion?", "What standard of mastery or devotion did they bring to what they loved?", .witnessingInAction),
                ("What was a hilarious mishap on the road that you still recount to everyone you meet?", "What made their sense of adventure so contagious?", .joy),
                ("What landscape, trail, mountain, or place in the world will forever echo with their spirit?", "Where will you go whenever you want to feel close to them again?", .witnessingInAction)
            ]

        // --- 3. ASSOCIATES, MENTEES & ADMIRERS ---
        case .menteeStudent:
            questions = [
                ("What was a specific moment they saw greatness in you when you were full of self-doubt?", "What exact words did they say that changed the way you looked at your own potential?", .helpSacrifice),
                ("Describe a time they corrected you with tough love, grace, and total belief in your future.", "How did that lesson save you or elevate your path down the road?", .painResilience),
                ("What standard of excellence or quiet kindness of theirs do you now pass down to others you teach?", "What do you want their family to understand about their ripple effect across the world?", .witnessingInAction),
                ("What was a moment you saw them demonstrate quiet humility when no bosses or cameras were watching?", "What did that reveal about who they were at their core?", .witnessingInAction),
                ("If you could show them what you have achieved today, what would you thank them for starting in you?", "How will you carry their torch forward?", .helpSacrifice)
            ]

        case .neighbor:
            questions = [
                ("What was a simple, daily way their presence made your street or neighborhood feel safer and warmer?", "What was a driveway wave, morning garden check, or porch greeting of theirs you will miss every day?", .witnessingInAction),
                ("Describe a time during a storm, power outage, or emergency when they were the first to knock on your door.", "How did their neighborly instinct show what community is truly supposed to be?", .helpSacrifice),
                ("What was a funny or endearing neighborly interaction you shared over the fence across the years?", "What made them such a beloved fixture on your block?", .joy),
                ("What will feel most noticeably empty about your community now that their porch light is off?", "What did they teach you about what it really means to love the people living next door?", .painResilience),
                ("What is one memory of them on your street that will stay with you forever?", "How did their life make your neighborhood a true home?", .witnessingInAction)
            ]

        case .communityFaithMember:
            questions = [
                ("What was a moment you watched them serve others quietly without ever seeking applause or recognition?", "What did their selfless devotion teach the rest of the congregation or community?", .helpSacrifice),
                ("How did their faith, conviction, or moral compass shine when times were dark or difficult?", "Describe a time their words or prayers brought comfort to someone in deep distress.", .painResilience),
                ("What was a joyful community celebration, potluck, or event where their energy was the heartbeat of the room?", "What made their presence so uplifting to everyone around them?", .joy),
                ("What did watching their steadfast integrity teach you about living a life of true purpose?", "How did they leave our shared community fundamentally better than they found it?", .witnessingInAction),
                ("What scripture, prayer, or motto of theirs will echo in your mind whenever you think of them?", "What is their enduring legacy in your community?", .witnessingInAction)
            ]

        case .admirerAcquaintance:
            questions = [
                ("Even observing them from a distance, what was something about how they carried themselves that commanded your deep respect?", "What was a single brief interaction with them that left a lasting, positive imprint on your life?", .witnessingInAction),
                ("What was an act of public generosity, courage, or excellence you witnessed them perform?", "How did seeing that act inspire you to be a better person in your own life?", .helpSacrifice),
                ("How did the way they spoke about their family, craft, or values set a gold standard for those around them?", "What made their reputation so stellar among those who knew of them?", .witnessingInAction),
                ("What was something about their resilience in the face of public or personal trials that inspired you?", "What lesson does their life offer to anyone striving to live with honor and impact?", .painResilience),
                ("What will you remember most about the spirit and energy they brought into every room they entered?", "What is the single word that best captures their life's example?", .joy)
            ]
        }

        return questions.enumerated().map { index, q in
            Topic(
                id: UUID(),
                relationshipType: relationship.rawValue,
                questionText: q.text,
                followUpPrompt: q.followUp,
                sortOrder: index + 1,
                active: true,
                pillar: q.pillar,
                createdAt: nil
            )
        }
    }
}
