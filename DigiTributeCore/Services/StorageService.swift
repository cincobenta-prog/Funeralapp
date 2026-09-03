//
//  StorageService.swift
//  DigiTributeCore
//
//  Scoped file upload/download service for Supabase Storage buckets ('tributes-raw' and 'tributes-final').
//

import Foundation

public final class StorageService: Sendable {
    public static let shared = StorageService()

    private let endpoint: URL
    private let apiKey: String

    public init(
        endpoint: URL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://your-project.supabase.co")!,
        apiKey: String = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "anon-key"
    ) {
        self.endpoint = endpoint
        self.apiKey = apiKey
    }

    /// Uploads raw contributor footage/audio/photo to the 'tributes-raw' bucket.
    /// Path layout: {funeral_home_id}/{subject_id}/{tribute_id}.{fileExtension}
    public func uploadRawTributeMedia(
        funeralHomeId: UUID,
        subjectId: UUID,
        tributeId: UUID,
        data: Data,
        mimeType: String,
        fileExtension: String,
        authToken: String? = nil
    ) async throws -> String {
        let objectPath = "\(funeralHomeId.uuidString.lowercased())/\(subjectId.uuidString.lowercased())/\(tributeId.uuidString.lowercased()).\(fileExtension)"
        return try await upload(
            bucket: "tributes-raw",
            path: objectPath,
            data: data,
            mimeType: mimeType,
            authToken: authToken
        )
    }

    /// Uploads compiled master memorial video to the 'tributes-final' bucket.
    /// Path layout: {funeral_home_id}/{subject_id}/{videoId}.mp4
    public func uploadFinalCompiledVideo(
        funeralHomeId: UUID,
        subjectId: UUID,
        videoId: UUID,
        data: Data,
        authToken: String? = nil
    ) async throws -> String {
        let objectPath = "\(funeralHomeId.uuidString.lowercased())/\(subjectId.uuidString.lowercased())/\(videoId.uuidString.lowercased()).mp4"
        return try await upload(
            bucket: "tributes-final",
            path: objectPath,
            data: data,
            mimeType: "video/mp4",
            authToken: authToken
        )
    }

    // MARK: - Internal Storage Upload Request
    private func upload(
        bucket: String,
        path: String,
        data: Data,
        mimeType: String,
        authToken: String?
    ) async throws -> String {
        var base = endpoint.absoluteString
        if base.hasSuffix("/") { base.removeLast() }
        let url = URL(string: "\(base)/storage/v1/object/\(bucket)/\(path)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "x-upsert")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: respData, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw NSError(domain: "SupabaseStorageError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: errorMsg
            ])
        }

        return "\(base)/storage/v1/object/public/\(bucket)/\(path)"
    }
}
