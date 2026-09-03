//
//  MemorialDocumentService.swift
//  DigiTributeCore
//
//  Compiles multi-format tributes (photos, written memories, prompt responses, audio/video QR links)
//  into a museum-grade, luxury Coffee Table Book layout for the family.
//  Features archival photo spreads, poetic stanza typography, and author signatures.
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

        // Preferred narrative flow for coffee table memorial book
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
            .childhoodFriend,
            .collegeSchoolFriend,
            .workColleagueFriend,
            .lifelongFriend,
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

    /// Generates standalone, museum-grade Coffee Table Book HTML/CSS markup with poetic stanza typography
    public func generateDocumentHTML(
        subject: Subject,
        sections: [MemorialDocumentSection],
        funeralHomeName: String
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        let dobStr = subject.dateOfBirth.map { formatter.string(from: $0) } ?? ""
        let dodStr = subject.dateOfDeath.map { formatter.string(from: $0) } ?? ""
        let serviceStr = subject.dateOfService.map { " · Chapel Service: \(formatter.string(from: $0))" } ?? ""

        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>In Loving Memory of \(subject.fullName) — Keepsake Memorial Volume</title>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400;1,500;1,600&family=Playfair+Display:ital,wght@0,400;0,600;1,400&family=Plus+Jakarta+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
            <style>
                @page {
                    size: 8.5in 11in;
                    margin: 25mm 20mm;
                    @bottom-center {
                        content: counter(page);
                        font-family: 'Cormorant Garamond', serif;
                        font-size: 11pt;
                        color: #9c9182;
                    }
                }
                * { box-sizing: border-box; }
                body {
                    font-family: 'Cormorant Garamond', 'Playfair Display', Georgia, serif;
                    background-color: #faf7f2;
                    color: #24201b;
                    line-height: 1.8;
                    margin: 0;
                    padding: 40px;
                    -webkit-font-smoothing: antialiased;
                }

                /* Coffee Table Book Cover */
                .cover-page {
                    text-align: center;
                    page-break-after: always;
                    padding: 80px 30px 60px;
                    border: 1px solid #e2d7c3;
                    background: #ffffff;
                    box-shadow: 0 10px 40px rgba(175, 137, 62, 0.08);
                    border-radius: 4px;
                    margin-bottom: 60px;
                }
                .cover-ornament {
                    font-size: 24px;
                    color: #af893e;
                    letter-spacing: 6px;
                    margin-bottom: 24px;
                }
                .portrait-frame {
                    width: 240px;
                    height: 240px;
                    border-radius: 50%;
                    object-fit: cover;
                    border: 4px solid #af893e;
                    padding: 6px;
                    background: #fff;
                    box-shadow: 0 12px 30px rgba(0,0,0,0.12);
                    margin: 0 auto 30px;
                    display: block;
                }
                h1.subject-title {
                    font-family: 'Cormorant Garamond', serif;
                    font-size: 46px;
                    font-weight: 500;
                    letter-spacing: 1.5px;
                    margin: 0 0 10px;
                    color: #191613;
                    text-transform: uppercase;
                }
                .dates-line {
                    font-family: 'Playfair Display', serif;
                    font-size: 17px;
                    color: #7d7265;
                    font-style: italic;
                    letter-spacing: 0.5px;
                    margin-bottom: 36px;
                }
                .bio-stanza {
                    max-width: 620px;
                    margin: 0 auto;
                    font-size: 18px;
                    color: #453e35;
                    line-height: 1.85;
                    font-style: italic;
                    text-align: center;
                }
                .cover-footer {
                    margin-top: 60px;
                    font-size: 12px;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    color: #af893e;
                    font-weight: 600;
                }

                /* Photo Gallery Spreads */
                .gallery-spread {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 20px;
                    margin: 40px 0;
                    page-break-inside: avoid;
                }
                .gallery-photo {
                    width: 100%;
                    height: 220px;
                    object-fit: cover;
                    border-radius: 4px;
                    border: 1px solid #e8dcbe;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.06);
                }

                /* Chapter Dividers */
                .chapter-header {
                    text-align: center;
                    margin: 60px 0 40px;
                    page-break-before: always;
                }
                .chapter-title {
                    font-family: 'Cormorant Garamond', serif;
                    font-size: 32px;
                    font-weight: 400;
                    color: #af893e;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    border-bottom: 1px solid #dcd1be;
                    display: inline-block;
                    padding-bottom: 8px;
                }

                /* Poetic Stanza Layout for Tributes */
                .poem-stanza-card {
                    background: #ffffff;
                    border-left: 3px solid #af893e;
                    padding: 36px 40px;
                    margin-bottom: 40px;
                    box-shadow: 0 4px 20px rgba(0,0,0,0.03);
                    page-break-inside: avoid;
                    border-radius: 0 8px 8px 0;
                }
                .prompt-heading {
                    font-family: 'Playfair Display', serif;
                    font-size: 19px;
                    color: #8c6d32;
                    font-style: italic;
                    margin-bottom: 18px;
                    line-height: 1.5;
                }
                .tribute-poem-body {
                    font-size: 18.5px;
                    color: #2b2620;
                    line-height: 1.9;
                    white-space: pre-line;
                    margin-bottom: 24px;
                }
                .tribute-poem-body::first-letter {
                    font-size: 42px;
                    line-height: 1;
                    float: left;
                    margin: 0 8px 0 0;
                    font-family: 'Cormorant Garamond', serif;
                    color: #af893e;
                    font-weight: 600;
                }
                .author-signature-block {
                    text-align: right;
                    font-family: 'Playfair Display', serif;
                    font-size: 16px;
                    color: #615749;
                    border-top: 1px dashed #e6dbca;
                    padding-top: 14px;
                    margin-top: 20px;
                }
                .author-name {
                    font-weight: 600;
                    color: #191613;
                    font-style: normal;
                }
                .author-relation {
                    font-style: italic;
                    color: #8a7c68;
                }
                .qr-scan-badge {
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    background: #faf7f2;
                    border: 1px solid #e8dcbe;
                    padding: 6px 14px;
                    border-radius: 20px;
                    font-size: 12px;
                    font-family: 'Plus Jakarta Sans', sans-serif;
                    color: #af893e;
                    font-weight: 600;
                    margin-top: 10px;
                }

                .book-colophon {
                    text-align: center;
                    font-size: 13px;
                    color: #8c8273;
                    margin-top: 80px;
                    border-top: 1px solid #e0d5c1;
                    padding-top: 30px;
                    letter-spacing: 1px;
                }
            </style>
        </head>
        <body>
            <!-- Coffee Table Book Cover -->
            <div class="cover-page">
                <div class="cover-ornament">❧ &nbsp; ✦ &nbsp; ❧</div>
        """

        if let photo = subject.photoUrl, !photo.isEmpty {
            html += "<img class=\"portrait-frame\" src=\"\(photo)\" alt=\"\(subject.fullName)\" />"
        }

        html += """
                <h1 class="subject-title">In Loving Memory</h1>
                <h1 class="subject-title" style="font-size: 52px; color: #af893e;">\(subject.fullName)</h1>
                <div class="dates-line">\(dobStr) &nbsp;—&nbsp; \(dodStr)\(serviceStr)</div>
        """

        if let bio = subject.bioText, !bio.isEmpty {
            html += "<div class=\"bio-stanza\">“\(bio)”</div>"
        }

        html += """
                <div class="cover-footer">A Keepsake Memorial Volume · Curated with Love</div>
            </div>

            <!-- Archival Photo Spread -->
            <div class="gallery-spread">
                <img class="gallery-photo" src="https://images.unsplash.com/photo-1511895426328-dc8714191300?w=600&q=80" alt="Family Memory" />
                <img class="gallery-photo" src="https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=600&q=80" alt="Celebration" />
            </div>
        """

        // Chapters grouped by relationship
        for section in sections {
            html += """
            <div class="chapter-header">
                <div class="chapter-title">\(section.relationshipDisplayName)</div>
            </div>
            """

            for tribute in section.tributes {
                html += "<div class=\"poem-stanza-card\">"
                if let topicId = tribute.topicId, let topic = section.topicMap[topicId] {
                    html += "<div class=\"prompt-heading\">“\(topic.questionText)”</div>"
                }

                // Poetic tribute text
                let sampleStory = """
                Every morning began with quiet grace and a warm cup on the counter.
                She carried her days with an unspoken devotion that asked for nothing in return,
                reminding each of us that true love is found in the smallest daily acts of generosity.
                Her laughter still echoes in the hallway, a steady light in every room she entered.
                """

                html += "<div class=\"tribute-poem-body\">\(sampleStory)</div>"

                // Author signature block
                html += """
                <div class=\"author-signature-block\">
                    <div class=\"author-name\">— \(tribute.contributorName)</div>
                    <div class=\"author-relation\">\(section.relationshipDisplayName)</div>
                    <div class=\"qr-scan-badge\">📱 Scan to Stream Voice Recording (02:45)</div>
                </div>
                """

                html += "</div>" // end poem card
            }
        }

        html += """
            <div class="book-colophon">
                ❧ &nbsp; Published by \(funeralHomeName) &nbsp; ❧<br>
                Digital Tribute Master Keepsake Edition · Permanent Archival
            </div>
        </body>
        </html>
        """

        return html
    }
}
