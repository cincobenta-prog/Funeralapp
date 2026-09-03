//
//  GuestEventInviteView.swift
//  DigiTributeCore
//
//  Atoms-inspired stepped guest contribution flow for Digital Tribute.
//  1. Event PIN Gate -> 2. Granular Relationship Picker -> 3. Dynamic Topic Prompts -> 4. Voice/Video Recording Studio.
//

import SwiftUI

public struct GuestEventInviteView: View {
    public let inviteToken: String

    @State private var pin: String = ""
    @State private var errorMessage: String?
    @State private var selectedRelationship: RelationshipType?
    @State private var selectedTopic: Topic?
    @State private var currentStep: Step = .pinGate

    public enum Step {
        case pinGate
        case relationshipPicker
        case topicSelector
        case recordingStudio
        case completed
    }

    public init(inviteToken: String) {
        self.inviteToken = inviteToken
    }

    public var body: some View {
        NavigationStack {
            VStack {
                switch currentStep {
                case .pinGate:
                    pinGateView

                case .relationshipPicker:
                    RelationshipSelectionView(selectedRelationship: $selectedRelationship) { rel in
                        selectedRelationship = rel
                        withAnimation { currentStep = .topicSelector }
                    }

                case .topicSelector:
                    if let rel = selectedRelationship {
                        DynamicTopicSelectorView(relationship: rel) { topic in
                            selectedTopic = topic
                            withAnimation { currentStep = .recordingStudio }
                        } onBack: {
                            withAnimation { currentStep = .relationshipPicker }
                        }
                    }

                case .recordingStudio:
                    if let rel = selectedRelationship {
                        MediaRecordingStudioView(topic: selectedTopic, relationship: rel) { _ in
                            withAnimation { currentStep = .completed }
                        } onBack: {
                            withAnimation { currentStep = .topicSelector }
                        }
                    }

                case .completed:
                    completionView
                }
            }
            .padding()
            .navigationTitle("Digital Tribute")
        }
    }

    // MARK: - Step 1: PIN Gate
    private var pinGateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color.accentColor)

            VStack(spacing: 8) {
                Text("Private Memorial Event")
                    .font(.title2.weight(.bold))

                Text("Enter the 4-digit PIN found in your memorial booklet or invitation to begin.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            SecureField("4-digit PIN", text: $pin)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Button {
                validatePin()
            } label: {
                Text("Unlock Memorial")
                    .font(.headline)
                    .frame(maxWidth: 220)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentColor)
            .disabled(pin.count < 4)
        }
        .padding(.top, 40)
    }

    // MARK: - Step 5: Completion
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 68))
                .foregroundColor(.green)

            Text("Thank You for Sharing")
                .font(.title.weight(.bold))

            Text("Your memory has been submitted to the funeral administrator. Once approved, it will be integrated into the family's master memorial presentation booklet.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Contribute Another Memory") {
                selectedRelationship = nil
                selectedTopic = nil
                currentStep = .relationshipPicker
            }
            .buttonStyle(.bordered)
            .padding(.top, 12)
        }
        .padding(.top, 40)
    }

    private func validatePin() {
        if pin.count >= 4 {
            withAnimation { currentStep = .relationshipPicker }
        } else {
            errorMessage = "Please enter a valid 4-digit PIN."
        }
    }
}
