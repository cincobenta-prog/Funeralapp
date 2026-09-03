import Foundation
import DigiTributeCore

@main
struct TestRunner {
    static func main() async {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("  ⚕ Digital Tribute 2.0 Core Test Suite")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        var passed = 0
        var total = 0

        func assertTest(_ condition: Bool, _ name: String) {
            total += 1
            if condition {
                passed += 1
                print("  ✓ PASS: \(name)")
            } else {
                print("  ✗ FAIL: \(name)")
            }
        }

        // Test 1: All expanded relationship types (20+) have prompts with paired follow-ups
        let service = QuestionBankService()
        for relationship in RelationshipType.allCases {
            let prompts = await service.getPrompts(for: relationship, count: 5)
            let hasFollowUps = prompts.allSatisfy { $0.followUpPrompt != nil && !$0.followUpPrompt!.isEmpty }
            assertTest(
                prompts.count >= 4 && prompts.count <= 6 && hasFollowUps,
                "Prompts with follow-ups for [\(relationship.category.rawValue)]: \(relationship.displayName) (\(prompts.count) prompts)"
            )
        }

        // Test 2: Randomization count clamping
        let childhoodPrompts = await service.getPrompts(for: .childhoodFriend, count: 4)
        assertTest(childhoodPrompts.count == 4, "Prompt count clamping (requested 4 -> got \(childhoodPrompts.count))")

        let colleaguePrompts = await service.getPrompts(for: .workColleagueFriend, count: 6)
        assertTest(colleaguePrompts.count == 6, "Prompt count clamping (requested 6 -> got \(colleaguePrompts.count))")

        // Test 3: Subject Model Serialization
        do {
            let subject = Subject(
                id: UUID(),
                funeralHomeId: UUID(),
                firstName: "Eleanor",
                lastName: "Vance",
                dateOfBirth: Date(timeIntervalSince1970: 0),
                dateOfDeath: Date(timeIntervalSince1970: 1700000000),
                dateOfService: nil,
                photoUrl: "https://example.com/photo.jpg",
                bioText: "A loving mother and teacher.",
                status: .active,
                createdAt: Date(),
                updatedAt: Date()
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(subject)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(Subject.self, from: data)

            assertTest(decoded.id == subject.id && decoded.fullName == "Eleanor Vance" && decoded.status == .active, "Subject serialization & full name")
        } catch {
            assertTest(false, "Subject serialization error: \(error)")
        }

        // Test 4: Tribute Model Serialization with Voice-Only
        do {
            let tribute = Tribute(
                id: UUID(),
                subjectId: UUID(),
                topicId: UUID(),
                contributorName: "Sarah Jenkins",
                contributorEmail: "sarah@example.com",
                relationshipType: "childhood_friend",
                mediaType: .voiceOnly,
                rawMediaUrl: "https://supabase.co/storage/v1/object/raw/123/audio.m4a",
                finalMediaUrl: nil,
                status: .submitted,
                rejectionReason: nil,
                createdAt: Date(),
                updatedAt: Date()
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(tribute)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(Tribute.self, from: data)

            assertTest(decoded.id == tribute.id && decoded.contributorName == "Sarah Jenkins" && decoded.mediaType == .voiceOnly, "Tribute Voice-Only serialization")
        } catch {
            assertTest(false, "Tribute serialization error: \(error)")
        }

        // Test 5: Coffee Table Memorial Book HTML Compilation
        let docService = MemorialDocumentService()
        let subject = Subject(
            id: UUID(),
            funeralHomeId: UUID(),
            firstName: "Arthur",
            lastName: "Pendelton",
            bioText: "Beloved father, craftsman, and childhood friend.",
            status: .active
        )
        let sampleTopic = Topic(
            id: UUID(),
            relationshipType: "childhood_friend",
            questionText: "What was an adventure only the two of you knew about?",
            followUpPrompt: "What was the moment during that adventure where you both laughed until you couldn't breathe?"
        )
        let approvedTribute = Tribute(
            id: UUID(),
            subjectId: subject.id,
            topicId: sampleTopic.id,
            contributorName: "David Pendelton",
            relationshipType: "childhood_friend",
            mediaType: .voiceOnly,
            status: .approved
        )
        let sections = docService.organizeTributesForPresentation(tributes: [approvedTribute], topics: [sampleTopic])
        let html = docService.generateDocumentHTML(subject: subject, sections: sections, funeralHomeName: "Evergreen Memorials")

        assertTest(sections.count == 1 && html.contains("Arthur Pendelton") && html.contains("David Pendelton") && html.contains("Keepsake Memorial Volume"), "Coffee Table Book HTML Compilation")

        // Test 6: PDF Booklet Export Generation
        let pdfData = PDFExportService.shared.generatePDFBooklet(
            subject: subject,
            sections: sections,
            funeralHomeName: "Evergreen Memorials"
        )
        assertTest(!pdfData.isEmpty, "PDF Keepsake Booklet Export Generation (\(pdfData.count) bytes)")

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("  Summary: \(passed)/\(total) tests passed.")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if passed != total {
            exit(1)
        }
    }
}
