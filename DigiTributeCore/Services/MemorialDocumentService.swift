//
//  MemorialDocumentService.swift
//  DigiTributeCore
//
//  Compiles multi-format tributes (photos, written memories, prompt responses, audio/video QR links)
//  into a unified, printable and digital memorial document for the family.
//

import Foundation

public struct MemorialDocumentSection: Sendable {
    public let relationshipDisplayName: String
    public let tributes: [Tribute]
    public let topicMap: [UUID: Topic]

    public init(relationshipDisplayName: String, tributes: [Tribute], topicMap: [UUID: Topic] = [:]) {
        self.relationshipDisplayName = relationshipDisplayName
        self.tributes = tributes
        self.topicMap = topicMap
    }
}

public struct MemorialDocumentService: Sendable {
    public static let shared = MemorialDocumentService()

    public init() {}

    /// Groups approved tributes into structured memorial sections ordered by relationship intimacy
    public func organizeTributesForPresentation(
        tributes: [Tribute],
        topics: [Topic]
    ) -> [MemorialDocumentSection] {
        let approved = tributes.filter { $0.status == .approved }
        let topicLookup = Dictionary(uniqueKeysWithValues: topics.map { ($0.id, $0) })

        // Preferred narrative flow for memorial document
        let order: [RelationshipType] = [
            .spousePartner,
            .son,
            .daughter,
            .father,
            .mother,
            .brother,
            .sister,
            .grandfather,
            .grandmother,
            .extendedFamily,
            .inLaw,
            .chosenFamily,
            .lifelongFriend,
            .childhoodFriend,
            .collegeSchoolFriend,
            .workColleagueFriend,
            .travelHobbyFriend,
            .menteeStudent,
            .neighbor,
            .communityFaithMember,
            .admirerAcquaintance
        ]

        var sections: [MemorialDocumentSection] = []

        for type in order {
            let matched = approved.filter { $0.relationshipType == type.rawValue }
            if !matched.isEmpty {
                sections.append(
                    MemorialDocumentSection(
                        relationshipDisplayName: type.displayName,
                        tributes: matched,
                        topicMap: topicLookup
                    )
                )
            }
        }

        return sections
    }

    /// Generates standalone, print-ready HTML/CSS markup for the unified memorial keepsake document
    public func generateDocumentHTML(
        subject: Subject,
        sections: [MemorialDocumentSection],
        funeralHomeName: String
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let dobStr = subject.dateOfBirth.map { formatter.string(from: $0) } ?? ""
        let dodStr = subject.dateOfDeath.map { formatter.string(from: $0) } ?? ""
        let serviceStr = subject.dateOfService.map { " · Service: \(formatter.string(from: $0))" } ?? ""

        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>In Loving Memory of \(subject.fullName)</title>
            <style>
                @page { size: A4; margin: 20mm; }
                body {
                    font-family: 'Georgia', serif;
                    color: #2c2c2c;
                    line-height: 1.6;
                    margin: 0;
                    padding: 40px;
                    background-color: #faf9f6;
                }
                .cover {
                    text-align: center;
                    page-break-after: always;
                    padding: 80px 20px;
                }
                .portrait {
                    width: 220px;
                    height: 220px;
                    border-radius: 50%;
                    object-fit: cover;
                    border: 4px solid #d4af37;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                    margin-bottom: 24px;
                }
                h1.subject-name {
                    font-size: 36px;
                    font-weight: normal;
                    letter-spacing: 1px;
                    margin: 12px 0 6px;
                    color: #1a1a1a;
                }
                .dates {
                    font-size: 16px;
                    color: #666;
                    font-style: italic;
                    margin-bottom: 30px;
                }
                .bio {
                    max-width: 600px;
                    margin: 0 auto;
                    font-size: 16px;
                    color: #444;
                    text-align: justify;
                }
                .section-header {
                    font-size: 22px;
                    color: #8c733e;
                    border-bottom: 2px solid #e8e0cc;
                    padding-bottom: 8px;
                    margin-top: 40px;
                    margin-bottom: 20px;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }
                .tribute-card {
                    background: #ffffff;
                    border: 1px solid #e6e0d4;
                    border-radius: 8px;
                    padding: 20px;
                    margin-bottom: 20px;
                    box-shadow: 0 2px 6px rgba(0,0,0,0.03);
                }
                .prompt-text {
                    font-size: 15px;
                    color: #7a6843;
                    font-weight: bold;
                    margin-bottom: 8px;
                }
                .contributor-meta {
                    font-size: 14px;
                    color: #888;
                    margin-top: 12px;
                    text-align: right;
                }
                .footer {
                    text-align: center;
                    font-size: 12px;
                    color: #aaa;
                    margin-top: 40px;
                }
            </style>
        </head>
        <body>
            <div class="cover">
        """

        if let photo = subject.photoUrl, !photo.isEmpty {
            html += "<img class=\"portrait\" src=\"\(photo)\" alt=\"\(subject.fullName)\" />"
        }

        html += """
                <h1 class="subject-name">\(subject.fullName)</h1>
                <div class="dates">\(dobStr) — \(dodStr)\(serviceStr)</div>
        """

        if let bio = subject.bioText, !bio.isEmpty {
            html += "<div class=\"bio\">\(bio)</div>"
        }

        html += "</div>" // end cover

        // Sections
        for section in sections {
            html += "<div class=\"section-header\">\(section.relationshipDisplayName)</div>"
            for tribute in section.tributes {
                html += "<div class=\"tribute-card\">"
                if let topicId = tribute.topicId, let topic = section.topicMap[topicId] {
                    html += "<div class=\"prompt-text\">“\(topic.questionText)”</div>"
                }
                if let mediaUrl = tribute.finalMediaUrl ?? tribute.rawMediaUrl, tribute.mediaType == .photo {
                    html += "<div style=\"text-align:center; margin: 15px 0;\"><img src=\"\(mediaUrl)\" style=\"max-width:100%; border-radius:6px; max-height:350px;\" /></div>"
                }
                html += "<div class=\"contributor-meta\">— \(tribute.contributorName) (\(section.relationshipDisplayName))</div>"
                html += "</div>"
            }
        }

        html += """
            <div class="footer">
                Compiled with love for the family · \(funeralHomeName)
            </div>
        </body>
        </html>
        """

        return html
    }
}
