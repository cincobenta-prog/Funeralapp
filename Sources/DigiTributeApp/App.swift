//
//  App.swift
//  DigiTributeApp
//
//  Native Application Entry Point for Digital Tribute (macOS & iOS).
//

import SwiftUI
import DigiTributeCore

@main
struct DigiTributeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(appState)
                .frame(minWidth: 920, minHeight: 680)
        }
    }
}

// MARK: - App State & Demo Store
final class AppState: ObservableObject {
    @Published var selectedNavTab: NavTab = .guestContribution
    @Published var currentSubject: Subject
    @Published var sampleTributes: [Tribute] = []
    @Published var sampleTopics: [Topic] = []
    @Published var documentSections: [MemorialDocumentSection] = []

    init() {
        let subjectId = UUID()
        let funeralHomeId = UUID()

        let subject = Subject(
            id: subjectId,
            funeralHomeId: funeralHomeId,
            firstName: "Eleanor",
            lastName: "Vance",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 1948, month: 3, day: 14)),
            dateOfDeath: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 22)),
            dateOfService: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 28)),
            photoUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&q=80",
            bioText: "A devoted teacher, gardener, and beloved matriarch whose warmth, wisdom, and generous spirit touched generations.",
            status: .active
        )
        self.currentSubject = subject

        let topic1 = Topic(
            id: UUID(),
            relationshipType: "spouse_partner",
            questionText: "What's something they did every day that was a quiet act of devotion?",
            pillar: .helpSacrifice
        )
        let topic2 = Topic(
            id: UUID(),
            relationshipType: "daughter",
            questionText: "What's a moment she made you proud in a way that took your breath away?",
            pillar: .joy
        )
        let topic3 = Topic(
            id: UUID(),
            relationshipType: "childhood_friend",
            questionText: "What was an unforgettable adventure from growing up that only the two of you knew about?",
            pillar: .joy
        )
        let topic4 = Topic(
            id: UUID(),
            relationshipType: "mentee_student",
            questionText: "What was a specific moment they believed in your potential before you could see it yourself?",
            pillar: .helpSacrifice
        )
        self.sampleTopics = [topic1, topic2, topic3, topic4]

        let tribute1 = Tribute(
            id: UUID(),
            subjectId: subjectId,
            topicId: topic1.id,
            contributorName: "Robert Vance",
            relationshipType: "spouse_partner",
            mediaType: .voiceOnly,
            status: .approved
        )
        let tribute2 = Tribute(
            id: UUID(),
            subjectId: subjectId,
            topicId: topic2.id,
            contributorName: "Claire Vance-Miller",
            relationshipType: "daughter",
            mediaType: .videoAndAudio,
            status: .approved
        )
        let tribute3 = Tribute(
            id: UUID(),
            subjectId: subjectId,
            topicId: topic3.id,
            contributorName: "Martha Hayes",
            relationshipType: "childhood_friend",
            mediaType: .voiceOnly,
            status: .approved
        )
        let tribute4 = Tribute(
            id: UUID(),
            subjectId: subjectId,
            topicId: topic4.id,
            contributorName: "Sarah Jenkins",
            relationshipType: "mentee_student",
            mediaType: .voiceOnly,
            status: .approved
        )
        self.sampleTributes = [tribute1, tribute2, tribute3, tribute4]

        let docService = MemorialDocumentService()
        self.documentSections = docService.organizeTributesForPresentation(tributes: self.sampleTributes, topics: self.sampleTopics)
    }
}

enum NavTab: String, CaseIterable, Identifiable {
    case guestContribution = "Share a Memory"
    case familyDocument = "Keepsake Memorial Book"
    case adminPortal = "Funeral Home Admin"
    case settings = "Cloud Settings & Sync"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .guestContribution: return "heart.text.square.fill"
        case .familyDocument: return "book.closed.fill"
        case .adminPortal: return "building.columns.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Main Content View
struct MainContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            List(NavTab.allCases, selection: $appState.selectedNavTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
            }
            .navigationTitle("Digital Tribute")
        } detail: {
            switch appState.selectedNavTab {
            case .guestContribution:
                GuestEventInviteView(inviteToken: "demo-event-token")

            case .familyDocument:
                MemorialDocumentViewer(
                    subject: appState.currentSubject,
                    sections: appState.documentSections,
                    funeralHomeName: "Evergreen Memorial Chapel"
                )

            case .adminPortal:
                AdminDashboardView()

            case .settings:
                SettingsView()
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("supabase_url") private var supabaseUrl = "https://your-project.supabase.co"
    @AppStorage("supabase_key") private var supabaseKey = "your-anon-key"

    var body: some View {
        Form {
            Section("Supabase Cloud Backend") {
                TextField("Supabase URL", text: $supabaseUrl)
                    .textFieldStyle(.roundedBorder)

                SecureField("Anon Public Key", text: $supabaseKey)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Data Retention & Archival") {
                HStack {
                    Text("Raw Footage Window")
                    Spacer()
                    Text("90 Days (Automated Purge)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Compiled Master Videos")
                    Spacer()
                    Text("Permanent Archival")
                        .foregroundColor(.green)
                }
            }

            Section("Question Bank") {
                HStack {
                    Text("Active Categories")
                    Spacer()
                    Text("20+ Relationships")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Core Impact Pillars")
                    Spacer()
                    Text("Joy, Pain, Sacrifice, In Action")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("Settings & Cloud Sync")
    }
}
