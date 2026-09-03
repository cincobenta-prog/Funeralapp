//
//  AdminDashboardView.swift
//  DigiTributeCore
//
//  Funeral Home Admin Dashboard for Digi-Tribute.
//  Manages memorial subjects, credit balances, and the moderation queue.
//

import SwiftUI

public struct AdminDashboardView: View {
    @State private var funeralHome: FuneralHome?
    @State private var subjects: [Subject] = []
    @State private var pendingTributes: [Tribute] = []
    @State private var selectedSubject: Subject?
    @State private var rejectionReason: String = ""
    @State private var showingRejectDialog: Bool = false
    @State private var tributeToReject: Tribute?

    public init() {}

    public var body: some View {
        NavigationSplitView {
            // Sidebar: Subjects List & Home Stats
            List(selection: $selectedSubject) {
                Section("Funeral Home") {
                    if let home = funeralHome {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(home.name).font(.headline)
                            Text("Credits remaining: \(home.subjectCreditsRemaining)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Loading account...").font(.caption).foregroundColor(.secondary)
                    }
                }

                Section("Memorial Subjects") {
                    ForEach(subjects) { subject in
                        NavigationLink(value: subject) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(subject.fullName)
                                    .font(.body.weight(.medium))
                                Text(subject.status.rawValue.capitalized)
                                    .font(.caption2)
                                    .foregroundColor(subject.status == .active ? .green : .secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Digi-Tribute")
        } detail: {
            // Detail: Moderation Queue & Compilation Status
            if let subject = selectedSubject {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subject.fullName)
                                .font(.title.weight(.semibold))
                            if let dob = subject.dateOfBirth, let dod = subject.dateOfDeath {
                                Text("\(dob.formatted(date: .abbreviated, time: .omitted)) — \(dod.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding()

                    // Moderation Queue
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Incoming Submissions for Moderation")
                            .font(.headline)

                        if pendingTributes.isEmpty {
                            Text("No pending submissions awaiting review.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 20)
                        } else {
                            List(pendingTributes) { tribute in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tribute.contributorName)
                                            .font(.body.weight(.medium))
                                        Text("\(tribute.relationshipType.capitalized) · \(tribute.mediaType.rawValue.capitalized)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()

                                    Button("Approve") {
                                        Task { await approveTribute(tribute) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)

                                    Button("Reject") {
                                        tributeToReject = tribute
                                        showingRejectDialog = true
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            } else {
                Text("Select a subject to view submissions")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingRejectDialog) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Decline Submission").font(.headline)
                    Text("Please provide a logged reason for declining this tribute.")
                        .font(.caption).foregroundColor(.secondary)

                    TextField("Reason for rejection...", text: $rejectionReason)
                        .textFieldStyle(.roundedBorder)
                        .padding()

                    HStack(spacing: 16) {
                        Button("Cancel") {
                            showingRejectDialog = false
                            rejectionReason = ""
                        }
                        Button("Confirm Decline") {
                            if let trib = tributeToReject {
                                Task { await rejectTribute(trib, reason: rejectionReason) }
                            }
                            showingRejectDialog = false
                            rejectionReason = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
                .padding()
            }
        }
    }

    private func approveTribute(_ tribute: Tribute) async {
        try? await SupabaseClientService.shared.updateTributeStatus(id: tribute.id, status: .approved)
        pendingTributes.removeAll { $0.id == tribute.id }
    }

    private func rejectTribute(_ tribute: Tribute, reason: String) async {
        try? await SupabaseClientService.shared.updateTributeStatus(id: tribute.id, status: .rejected, rejectionReason: reason)
        pendingTributes.removeAll { $0.id == tribute.id }
    }
}
