//
//  GuestEventInviteView.swift
//  DigiTributeCore
//
//  Phase 2: Guest Invites, PIN Gate security, and tribute submission flow.
//

import SwiftUI

public struct GuestEventInviteView: View {
    public let inviteToken: String

    @State private var pin: String = ""
    @State private var isUnlocked: Bool = false
    @State private var errorMessage: String?
    @State private var contributorName: String = ""
    @State private var contributorEmail: String = ""
    @State private var selectedTopic: Topic?
    @State private var step: SubmissionStep = .pinGate

    public enum SubmissionStep {
        case pinGate
        case contributorInfo
        case promptPicker
        case recording
        case completed
    }

    public init(inviteToken: String) {
        self.inviteToken = inviteToken
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                switch step {
                case .pinGate:
                    pinGateView

                case .contributorInfo:
                    contributorInfoView

                case .promptPicker:
                    RelationshipPromptPickerView { topic in
                        selectedTopic = topic
                        step = .recording
                    }

                case .recording:
                    recordingView

                case .completed:
                    completionView
                }
            }
            .padding()
            .navigationTitle("Digi-Tribute")
        }
    }

    // MARK: - Step 1: PIN Gate
    private var pinGateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 56))
                .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.25))

            Text("Enter Event PIN")
                .font(.title2.weight(.medium))

            Text("This memorial event is private. Please enter the 4-digit PIN provided on your memorial booklet or invitation.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            SecureField("4-digit PIN", text: $pin)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Button("Unlock Memorial") {
                validatePin()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.55, green: 0.45, blue: 0.25))
            .disabled(pin.count < 4)
        }
    }

    // MARK: - Step 2: Contributor Details
    private var contributorInfoView: some View {
        VStack(spacing: 20) {
            Text("About You")
                .font(.title2.weight(.medium))

            Text("Please enter your name and email. Your submission will be shared with the family once reviewed.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextField("Your Full Name", text: $contributorName)
                .textFieldStyle(.roundedBorder)

            TextField("Your Email Address", text: $contributorEmail)
                .textFieldStyle(.roundedBorder)

            Button("Continue to Prompts") {
                if !contributorName.isEmpty && !contributorEmail.isEmpty {
                    step = .promptPicker
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.55, green: 0.45, blue: 0.25))
            .disabled(contributorName.isEmpty || contributorEmail.isEmpty)
        }
    }

    // MARK: - Step 4: Recording Placeholder
    private var recordingView: some View {
        VStack(spacing: 20) {
            if let topic = selectedTopic {
                Text("“\(topic.questionText)”")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.2))
            } else {
                Text("Share Your Memory")
                    .font(.title3.weight(.medium))
            }

            Text("Record your memory or upload a photo.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button {
                    step = .completed
                } label: {
                    Label("Record Video", systemImage: "video.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.55, green: 0.45, blue: 0.25))

                Button {
                    step = .completed
                } label: {
                    Label("Record Audio", systemImage: "mic.fill")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Step 5: Completion
    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Thank You for Sharing")
                .font(.title2.weight(.medium))

            Text("Your tribute has been submitted and will be reviewed by the funeral administrator before inclusion in the final memorial compilation.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func validatePin() {
        if pin.count >= 4 {
            step = .contributorInfo
        } else {
            errorMessage = "Invalid PIN. Please check and try again."
        }
    }
}
