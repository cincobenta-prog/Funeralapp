import Testing
import Foundation
@testable import DigiTributeCore

@Suite("Digi-Tribute Core Tests")
struct DigiTributeCoreTests {

    @Test("All 13 relationship types have 4 to 6 randomized prompts")
    func allRelationshipTypesHavePrompts() async {
        let service = QuestionBankService()
        for relationship in RelationshipType.allCases {
            let prompts = await service.getPrompts(for: relationship, count: 5)
            #expect(prompts.count >= 4, "Should return at least 4 prompts for \(relationship.rawValue)")
            #expect(prompts.count <= 6, "Should return at most 6 prompts for \(relationship.rawValue)")
            #expect(!prompts.isEmpty, "Prompts should not be empty for \(relationship.rawValue)")
        }
    }

    @Test("Prompt randomization logic honors target counts")
    func promptRandomization() async {
        let service = QuestionBankService()
        let fatherPrompts = await service.getPrompts(for: .father, count: 4)
        let motherPrompts = await service.getPrompts(for: .mother, count: 6)

        #expect(fatherPrompts.count == 4)
        #expect(motherPrompts.count == 6)
    }

    @Test("Subject model serialization and full name formatting")
    func subjectModelSerialization() throws {
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

        #expect(decoded.id == subject.id)
        #expect(decoded.firstName == "Eleanor")
        #expect(decoded.lastName == "Vance")
        #expect(decoded.fullName == "Eleanor Vance")
        #expect(decoded.status == .active)
    }

    @Test("Tribute model serialization")
    func tributeModelSerialization() throws {
        let tribute = Tribute(
            id: UUID(),
            subjectId: UUID(),
            topicId: UUID(),
            contributorName: "Sarah Jenkins",
            contributorEmail: "sarah@example.com",
            relationshipType: "daughter",
            mediaType: .video,
            rawMediaUrl: "https://supabase.co/storage/v1/object/raw/123/video.mp4",
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

        #expect(decoded.id == tribute.id)
        #expect(decoded.contributorName == "Sarah Jenkins")
        #expect(decoded.mediaType == .video)
        #expect(decoded.status == .submitted)
    }
}
