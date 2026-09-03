//
//  MemorialDocumentViewer.swift
//  DigiTributeCore
//
//  SwiftUI component presenting the compiled Memorial Document / Keepsake book to the family,
//  with PDF Export support.
//

import SwiftUI

public struct MemorialDocumentViewer: View {
    public let subject: Subject
    public let sections: [MemorialDocumentSection]
    public let funeralHomeName: String

    @State private var isExportingPDF: Bool = false
    @State private var exportedPDFUrl: URL?

    public init(subject: Subject, sections: [MemorialDocumentSection], funeralHomeName: String) {
        self.subject = subject
        self.sections = sections
        self.funeralHomeName = funeralHomeName
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Actions Bar
                HStack {
                    Spacer()
                    Button {
                        exportPDF()
                    } label: {
                        Label("Export PDF Keepsake Booklet", systemImage: "arrow.down.doc.fill")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.accentColor)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Cover Page Card
                coverCard

                // Tribute Sections Grouped by Relationship
                ForEach(sections, id: \.relationshipDisplayName) { section in
                    sectionView(for: section)
                }

                // Footer
                Text("Compiled with love for the family · \(funeralHomeName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 24)
            }
        }
    }

    private var coverCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.secondary)

            Text(subject.fullName)
                .font(.title)
                .foregroundColor(.primary)

            if let dob = subject.dateOfBirth, let dod = subject.dateOfDeath {
                Text("\(dob.formatted(date: .abbreviated, time: .omitted)) — \(dod.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }

            if let bio = subject.bioText, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.06)))
        .padding(.horizontal)
    }

    private func sectionView(for section: MemorialDocumentSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(section.relationshipDisplayName)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            ForEach(section.tributes) { tribute in
                tributeCard(for: tribute, topicMap: section.topicMap)
            }
        }
        .padding(.horizontal)
    }

    private func tributeCard(for tribute: Tribute, topicMap: [UUID: Topic]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let topicId = tribute.topicId, let topic = topicMap[topicId] {
                Text("“\(topic.questionText)”")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }

            HStack {
                Spacer()
                Text("— \(tribute.contributorName)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
    }

    private func exportPDF() {
        let pdfData = PDFExportService.shared.generatePDFBooklet(
            subject: subject,
            sections: sections,
            funeralHomeName: funeralHomeName
        )
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("\(subject.fullName) - Memorial Keepsake.pdf")
        try? pdfData.write(to: tempUrl)
        self.exportedPDFUrl = tempUrl
    }
}
