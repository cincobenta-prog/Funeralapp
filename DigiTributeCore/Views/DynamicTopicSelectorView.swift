//
//  DynamicTopicSelectorView.swift
//  DigiTributeCore
//
//  Dynamic topic prompt selector for Digital Tribute.
//  Presents 4 to 6 randomized relationship-specific prompts with emotional impact pillar badges.
//

import SwiftUI

public struct DynamicTopicSelectorView: View {
    public let relationship: RelationshipType
    public let onSelectTopic: (Topic?) -> Void
    public let onBack: () -> Void

    @State private var prompts: [Topic] = []
    @State private var selectedTopic: Topic? = nil
    @State private var isFreeform: Bool = false

    public init(
        relationship: RelationshipType,
        onSelectTopic: @escaping (Topic?) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.relationship = relationship
        self.onSelectTopic = onSelectTopic
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Header with Back Button
            HStack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Change Relationship")
                    }
                    .font(.footnote.weight(.medium))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal)

            // Relationship Title Banner
            VStack(spacing: 6) {
                Text(relationship.displayName)
                    .font(.title2.weight(.bold))

                Text("Choose a prompt that lets others understand their impact through joy, pain, sacrifice, or witnessing them in action.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Prompts Scroll List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(prompts) { topic in
                        promptCard(for: topic)
                    }

                    // Freeform Pebble Card
                    freeformCard
                }
                .padding(.horizontal)
            }

            // Action Footer (Shuffle & Proceed)
            VStack(spacing: 12) {
                Button {
                    Task { await loadPrompts() }
                } label: {
                    Label("Shuffle for New Prompts", systemImage: "arrow.triangle.2.circlepath")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(Color.accentColor)
                }
                .buttonStyle(.plain)

                Button {
                    if isFreeform {
                        onSelectTopic(nil)
                    } else if let topic = selectedTopic {
                        onSelectTopic(topic)
                    }
                } label: {
                    Text("Continue to Record Memory")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentColor)
                .disabled(selectedTopic == nil && !isFreeform)
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
        }
        .task {
            await loadPrompts()
        }
    }

    private func promptCard(for topic: Topic) -> some View {
        let isSelected = selectedTopic?.id == topic.id

        return Button {
            selectedTopic = topic
            isFreeform = false
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                if let pillar = topic.pillar {
                    HStack(spacing: 4) {
                        Image(systemName: pillar.icon)
                            .font(.system(size: 11))
                        Text(pillar.rawValue)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundColor(pillarColor(for: pillar))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(pillarColor(for: pillar).opacity(0.12))
                    .clipShape(Capsule())
                }

                Text("“\(topic.questionText)”")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(isSelected ? 0.15 : 0.06)))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var freeformCard: some View {
        Button {
            selectedTopic = nil
            isFreeform = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isFreeform ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isFreeform ? Color.accentColor : .gray)

                Text("I want to speak freely without a prompt")
                    .font(.body.italic())
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(isFreeform ? 0.15 : 0.06)))
        }
        .buttonStyle(.plain)
    }

    private func pillarColor(for pillar: ImpactPillar) -> Color {
        switch pillar {
        case .joy: return .orange
        case .painResilience: return .indigo
        case .helpSacrifice: return .teal
        case .witnessingInAction: return .purple
        }
    }

    private func loadPrompts() async {
        let loaded = await QuestionBankService.shared.getPrompts(for: relationship, count: 5)
        await MainActor.run {
            self.prompts = loaded
            self.selectedTopic = loaded.first
            self.isFreeform = false
        }
    }
}
