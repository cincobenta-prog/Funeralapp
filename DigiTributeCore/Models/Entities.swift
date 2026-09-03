//
//  Entities.swift
//  DigiTributeCore
//
//  Native Swift models matching the Supabase PostgreSQL schema for Digi-Tribute.
//

import Foundation

// MARK: - Relationship Type Enum
public enum RelationshipType: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case father = "father"
    case mother = "mother"
    case brother = "brother"
    case sister = "sister"
    case spousePartner = "spouse_partner"
    case son = "son"
    case daughter = "daughter"
    case grandfather = "grandfather"
    case grandmother = "grandmother"
    case friend = "friend"
    case extendedFamily = "extended_family"
    case mentorColleague = "mentor_colleague"
    case communityOther = "community_other"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .father: return "Father"
        case .mother: return "Mother"
        case .brother: return "Brother"
        case .sister: return "Sister"
        case .spousePartner: return "Spouse or Partner"
        case .son: return "Son"
        case .daughter: return "Daughter"
        case .grandfather: return "Grandfather"
        case .grandmother: return "Grandmother"
        case .friend: return "Friend"
        case .extendedFamily: return "Extended Family (Aunt, Uncle, Cousin)"
        case .mentorColleague: return "Mentor, Teacher, or Colleague"
        case .communityOther: return "Community or Other"
        }
    }
}

// MARK: - Enums
public enum SubjectStatus: String, Codable, Sendable, Hashable {
    case active = "active"
    case archived = "archived"
    case completed = "completed"
}

public enum TributeMediaType: String, Codable, Sendable, Hashable {
    case video = "video"
    case audio = "audio"
    case photo = "photo"
}

public enum TributeStatus: String, Codable, Sendable, Hashable {
    case submitted = "submitted"
    case inReview = "in_review"
    case approved = "approved"
    case rejected = "rejected"
}

public enum CompiledVideoStatus: String, Codable, Sendable, Hashable {
    case draft = "draft"
    case editing = "editing"
    case familyReview = "family_review"
    case published = "published"
}

public enum MemorialDocumentStatus: String, Codable, Sendable, Hashable {
    case draft = "draft"
    case generating = "generating"
    case ready = "ready"
    case published = "published"
}

// MARK: - Funeral Home
public struct FuneralHome: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let authUserId: UUID?
    public var name: String
    public var contactEmail: String
    public var packageTier: String
    public var subjectCreditsRemaining: Int
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        authUserId: UUID? = nil,
        name: String,
        contactEmail: String,
        packageTier: String = "standard",
        subjectCreditsRemaining: Int = 10,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.authUserId = authUserId
        self.name = name
        self.contactEmail = contactEmail
        self.packageTier = packageTier
        self.subjectCreditsRemaining = subjectCreditsRemaining
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case authUserId = "auth_user_id"
        case name
        case contactEmail = "contact_email"
        case packageTier = "package_tier"
        case subjectCreditsRemaining = "subject_credits_remaining"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Memorial Subject
public struct Subject: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let funeralHomeId: UUID
    public var firstName: String
    public var lastName: String
    public var dateOfBirth: Date?
    public var dateOfDeath: Date?
    public var dateOfService: Date?
    public var photoUrl: String?
    public var bioText: String?
    public var status: SubjectStatus
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        funeralHomeId: UUID,
        firstName: String,
        lastName: String,
        dateOfBirth: Date? = nil,
        dateOfDeath: Date? = nil,
        dateOfService: Date? = nil,
        photoUrl: String? = nil,
        bioText: String? = nil,
        status: SubjectStatus = .active,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.funeralHomeId = funeralHomeId
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.dateOfDeath = dateOfDeath
        self.dateOfService = dateOfService
        self.photoUrl = photoUrl
        self.bioText = bioText
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case funeralHomeId = "funeral_home_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case dateOfDeath = "date_of_death"
        case dateOfService = "date_of_service"
        case photoUrl = "photo_url"
        case bioText = "bio_text"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Topic / Prompt
public struct Topic: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: UUID
    public let relationshipType: String
    public let questionText: String
    public let sortOrder: Int
    public let active: Bool
    public let createdAt: Date?

    public init(
        id: UUID = UUID(),
        relationshipType: String,
        questionText: String,
        sortOrder: Int = 1,
        active: Bool = true,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.relationshipType = relationshipType
        self.questionText = questionText
        self.sortOrder = sortOrder
        self.active = active
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case relationshipType = "relationship_type"
        case questionText = "question_text"
        case sortOrder = "sort_order"
        case active
        case createdAt = "created_at"
    }
}

// MARK: - Tribute
public struct Tribute: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let subjectId: UUID
    public var topicId: UUID?
    public var contributorName: String
    public var contributorEmail: String?
    public var relationshipType: String
    public var mediaType: TributeMediaType
    public var rawMediaUrl: String?
    public var finalMediaUrl: String?
    public var status: TributeStatus
    public var rejectionReason: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        subjectId: UUID,
        topicId: UUID? = nil,
        contributorName: String,
        contributorEmail: String? = nil,
        relationshipType: String,
        mediaType: TributeMediaType,
        rawMediaUrl: String? = nil,
        finalMediaUrl: String? = nil,
        status: TributeStatus = .submitted,
        rejectionReason: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.subjectId = subjectId
        self.topicId = topicId
        self.contributorName = contributorName
        self.contributorEmail = contributorEmail
        self.relationshipType = relationshipType
        self.mediaType = mediaType
        self.rawMediaUrl = rawMediaUrl
        self.finalMediaUrl = finalMediaUrl
        self.status = status
        self.rejectionReason = rejectionReason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case subjectId = "subject_id"
        case topicId = "topic_id"
        case contributorName = "contributor_name"
        case contributorEmail = "contributor_email"
        case relationshipType = "relationship_type"
        case mediaType = "media_type"
        case rawMediaUrl = "raw_media_url"
        case finalMediaUrl = "final_media_url"
        case status
        case rejectionReason = "rejection_reason"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Compiled Video
public struct CompiledVideo: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let subjectId: UUID
    public var finalVideoUrl: String?
    public var editedBy: String?
    public var status: CompiledVideoStatus
    public var publishedAt: Date?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        subjectId: UUID,
        finalVideoUrl: String? = nil,
        editedBy: String? = nil,
        status: CompiledVideoStatus = .draft,
        publishedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.subjectId = subjectId
        self.finalVideoUrl = finalVideoUrl
        self.editedBy = editedBy
        self.status = status
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case subjectId = "subject_id"
        case finalVideoUrl = "final_video_url"
        case editedBy = "edited_by"
        case status
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Memorial Document (Unified Presentation Keepsake)
public struct MemorialDocument: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let subjectId: UUID
    public var title: String
    public var pdfUrl: String?
    public var webPresentationUrl: String?
    public var pageCount: Int
    public var themeName: String
    public var status: MemorialDocumentStatus
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        subjectId: UUID,
        title: String,
        pdfUrl: String? = nil,
        webPresentationUrl: String? = nil,
        pageCount: Int = 0,
        themeName: String = "classic_elegance",
        status: MemorialDocumentStatus = .draft,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.subjectId = subjectId
        self.title = title
        self.pdfUrl = pdfUrl
        self.webPresentationUrl = webPresentationUrl
        self.pageCount = pageCount
        self.themeName = themeName
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case subjectId = "subject_id"
        case title
        case pdfUrl = "pdf_url"
        case webPresentationUrl = "web_presentation_url"
        case pageCount = "page_count"
        case themeName = "theme_name"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Event (Phase 2 Guest Invites)
public struct Event: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let subjectId: UUID
    public let inviteToken: String
    public let pinHash: String
    public var expiresAt: Date?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        subjectId: UUID,
        inviteToken: String,
        pinHash: String,
        expiresAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.subjectId = subjectId
        self.inviteToken = inviteToken
        self.pinHash = pinHash
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case subjectId = "subject_id"
        case inviteToken = "invite_token"
        case pinHash = "pin_hash"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}
