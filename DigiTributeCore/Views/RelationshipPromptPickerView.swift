//
//  RelationshipPromptPickerView.swift
//  DigiTributeCore
//
//  SwiftUI component presenting the warm, non-clinical relationship prompt picker.
//  Randomly surfaces 4 to 6 prompts with option for freeform recording.
//

import SwiftUI

public struct RelationshipPromptPickerView: View {
    @State private var selectedRelationship: RelationshipType = .lifelongFriend
    @State private var prompts: [Topic] = []
    @State private var selectedPrompt: Topic? = nil
    @State private var isFreeform: Bool = false

    public let onSelectPrompt: (Topic?) -> Void

    public init(onSelectPrompt: @escaping (Topic?) -> Void) {
        self.onSelectPrompt = onSelectPrompt
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Share a Memory")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary)

                Text("How were you connected?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Relationship Picker
            Picker("Relationship", selection: $selectedRelationship) {
                ForEach(RelationshipType.allCases) { rel in
                    Text(rel.displayName).tag(rel)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)
            .onChange(of: selectedRelationship) { newRel in
                Task {
                    await loadPrompts(for: newRel)
                }
            }

            // Prompts List (4-6 randomized questions)
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(prompts) { topic in
                        promptRow(for: topic)
                    }

                    // Freeform Option
                    freeformRow
                }
                .padding(.horizontal)
            }

            // Shuffle Button
            Button {
                Task {
                    await loadPrompts(for: selectedRelationship)
                }
            } label: {
                Label("Show different questions", systemImage: "arrow.triangle.2.circlepath")
                    .font(.footnote)
                    .foregroundColor(Color.accentColor)
            }
            .padding(.bottom, 8)
        }
        .task {
            await loadPrompts(for: selectedRelationship)
        }
    }

    private func promptRow(for topic: Topic) -> some View {
        let isSelected = selectedPrompt?.id == topic.id
        return Button {
            selectedPrompt = topic
            isFreeform = false
            onSelectPrompt(topic)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .padding(.top, 2)

                Text(topic.questionText)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(isSelected ? 0.15 : 0.08)))
        }
        .buttonStyle(.plain)
    }

    private var freeformRow: some View {
        Button {
            selectedPrompt = nil
            isFreeform = true
            onSelectPrompt(nil)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isFreeform ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isFreeform ? .blue : .gray)

                Text("I want to speak freely without a prompt")
                    .font(.body.italic())
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(isFreeform ? 0.15 : 0.08)))
        }
        .buttonStyle(.plain)
    }

    private func loadPrompts(for relationship: RelationshipType) async {
        let loaded = await QuestionBankService.shared.getPrompts(for: relationship, count: 5)
        await MainActor.run {
            self.prompts = loaded
            self.selectedPrompt = nil
            self.isFreeform = false
        }
    }
}
