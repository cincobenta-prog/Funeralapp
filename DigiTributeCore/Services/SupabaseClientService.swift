//
//  SupabaseClientService.swift
//  DigiTributeCore
//
//  Async/await client protocol and implementation for Supabase-backed operations in Digi-Tribute.
//

import Foundation

public protocol DigiTributeServiceProtocol: Sendable {
    // MARK: - Subjects
    func fetchSubjects() async throws -> [Subject]
    func createSubject(_ subject: Subject) async throws -> Subject
    func updateSubjectStatus(id: UUID, status: SubjectStatus) async throws

    // MARK: - Topics / Prompts
    func fetchActiveTopics() async throws -> [Topic]

    // MARK: - Tributes
    func fetchTributes(for subjectId: UUID) async throws -> [Tribute]
    func createTribute(_ tribute: Tribute) async throws -> Tribute
    func updateTributeStatus(id: UUID, status: TributeStatus, rejectionReason: String?) async throws

    // MARK: - Compiled Video
    func fetchCompiledVideo(for subjectId: UUID) async throws -> CompiledVideo?
    func updateCompiledVideoStatus(id: UUID, status: CompiledVideoStatus, finalVideoUrl: String?) async throws -> CompiledVideo

    // MARK: - Events (Phase 2)
    func createEvent(for subjectId: UUID, pinHash: String, expiresAt: Date?) async throws -> Event
    func validateEvent(token: String) async throws -> Event?
}

public final class SupabaseClientService: DigiTributeServiceProtocol, @unchecked Sendable {
    public static let shared = SupabaseClientService()

    private let endpoint: URL
    private let apiKey: String
    private var authToken: String?

    public init(
        endpoint: URL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://your-project.supabase.co")!,
        apiKey: String = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "anon-key"
    ) {
        self.endpoint = endpoint
        self.apiKey = apiKey
    }

    public func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    // MARK: - Subjects Implementation
    public func fetchSubjects() async throws -> [Subject] {
        let request = makeRequest(path: "/rest/v1/subjects?select=*&order=created_at.desc")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try makeDecoder().decode([Subject].self, from: data)
    }

    public func createSubject(_ subject: Subject) async throws -> Subject {
        var request = makeRequest(path: "/rest/v1/subjects", method: "POST")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try makeEncoder().encode(subject)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let created = try makeDecoder().decode([Subject].self, from: data)
        guard let first = created.first else {
            throw URLError(.cannotParseResponse)
        }
        return first
    }

    public func updateSubjectStatus(id: UUID, status: SubjectStatus) async throws {
        var request = makeRequest(path: "/rest/v1/subjects?id=eq.\(id.uuidString)", method: "PATCH")
        let body = ["status": status.rawValue]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
    }

    // MARK: - Topics Implementation
    public func fetchActiveTopics() async throws -> [Topic] {
        let request = makeRequest(path: "/rest/v1/topics?active=eq.true&order=sort_order.asc")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try makeDecoder().decode([Topic].self, from: data)
    }

    // MARK: - Tributes Implementation
    public func fetchTributes(for subjectId: UUID) async throws -> [Tribute] {
        let request = makeRequest(path: "/rest/v1/tributes?subject_id=eq.\(subjectId.uuidString)&order=created_at.asc")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try makeDecoder().decode([Tribute].self, from: data)
    }

    public func createTribute(_ tribute: Tribute) async throws -> Tribute {
        var request = makeRequest(path: "/rest/v1/tributes", method: "POST")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try makeEncoder().encode(tribute)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let list = try makeDecoder().decode([Tribute].self, from: data)
        guard let first = list.first else {
            throw URLError(.cannotParseResponse)
        }
        return first
    }

    public func updateTributeStatus(id: UUID, status: TributeStatus, rejectionReason: String? = nil) async throws {
        var request = makeRequest(path: "/rest/v1/tributes?id=eq.\(id.uuidString)", method: "PATCH")
        var body: [String: Any] = ["status": status.rawValue]
        if let reason = rejectionReason {
            body["rejection_reason"] = reason
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
    }

    // MARK: - Compiled Video Implementation
    public func fetchCompiledVideo(for subjectId: UUID) async throws -> CompiledVideo? {
        let request = makeRequest(path: "/rest/v1/compiled_videos?subject_id=eq.\(subjectId.uuidString)&limit=1")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let list = try makeDecoder().decode([CompiledVideo].self, from: data)
        return list.first
    }

    public func updateCompiledVideoStatus(id: UUID, status: CompiledVideoStatus, finalVideoUrl: String? = nil) async throws -> CompiledVideo {
        var request = makeRequest(path: "/rest/v1/compiled_videos?id=eq.\(id.uuidString)", method: "PATCH")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        var body: [String: Any] = ["status": status.rawValue]
        if let url = finalVideoUrl {
            body["final_video_url"] = url
        }
        if status == .published {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            body["published_at"] = formatter.string(from: Date())
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let list = try makeDecoder().decode([CompiledVideo].self, from: data)
        guard let first = list.first else {
            throw URLError(.cannotParseResponse)
        }
        return first
    }

    // MARK: - Events (Phase 2)
    public func createEvent(for subjectId: UUID, pinHash: String, expiresAt: Date?) async throws -> Event {
        let token = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let event = Event(id: UUID(), subjectId: subjectId, inviteToken: token, pinHash: pinHash, expiresAt: expiresAt, createdAt: Date())
        var request = makeRequest(path: "/rest/v1/events", method: "POST")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try makeEncoder().encode(event)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let list = try makeDecoder().decode([Event].self, from: data)
        guard let first = list.first else {
            throw URLError(.cannotParseResponse)
        }
        return first
    }

    public func validateEvent(token: String) async throws -> Event? {
        let request = makeRequest(path: "/rest/v1/events?invite_token=eq.\(token)&limit=1")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let list = try makeDecoder().decode([Event].self, from: data)
        return list.first
    }

    // MARK: - Helpers
    private func makeRequest(path: String, method: String = "GET") -> URLRequest {
        var urlString = endpoint.absoluteString
        if urlString.hasSuffix("/") { urlString.removeLast() }
        var request = URLRequest(url: URL(string: "\(urlString)\(path)")!)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "HTTP error \(httpResponse.statusCode)"
            ])
        }
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateStr) { return date }
            
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateStr) { return date }

            let simpleDateFormatter = DateFormatter()
            simpleDateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = simpleDateFormatter.date(from: dateStr) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }
        return decoder
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
        return encoder
    }
}
