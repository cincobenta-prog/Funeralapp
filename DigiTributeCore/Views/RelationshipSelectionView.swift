//
//  RelationshipSelectionView.swift
//  DigiTributeCore
//
//  Atoms-inspired tactile relationship selector for Digital Tribute.
//  Organizes relationships into Family, Friends, and Associates & Admirers.
//

import SwiftUI

public struct RelationshipSelectionView: View {
    @Binding public var selectedRelationship: RelationshipType?
    public let onProceed: (RelationshipType) -> Void

    @State private var selectedCategory: RelationshipCategory = .family

    public init(
        selectedRelationship: Binding<RelationshipType?>,
        onProceed: @escaping (RelationshipType) -> Void
    ) {
        self._selectedRelationship = selectedRelationship
        self.onProceed = onProceed
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("How were you connected?")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)

                Text("Select your relationship to reveal personalized prompts that capture the true impact of their life.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Category Segmented Bar (Atoms-style)
            HStack(spacing: 8) {
                ForEach(RelationshipCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 13))
                            Text(cat.rawValue)
                                .font(.system(size: 13.5, weight: .medium))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(selectedCategory == cat ? Color.accentColor : Color.secondary.opacity(0.08))
                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            // Relationship Cards Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
                    ForEach(filteredRelationships) { rel in
                        relationshipCard(for: rel)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
        .padding(.top, 12)
    }

    private var filteredRelationships: [RelationshipType] {
        RelationshipType.allCases.filter { $0.category == selectedCategory }
    }

    private func relationshipCard(for rel: RelationshipType) -> some View {
        let isSelected = selectedRelationship == rel

        return Button {
            selectedRelationship = rel
            onProceed(rel)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(rel.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                }

                Text(rel.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(isSelected ? 0.15 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
