//
//  TagSelectionList.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI
import UIKit // Added for HapticsManager

/// A subview for displaying and selecting tags from the available list.
/// Used within TagView to manage Item tags in DailyGrind0.2.
struct TagSelectionList: View {
    // MARK: - Properties
    
    /// The Item whose tags are being managed
    @Bindable var item: Item
    
    /// Fetches all tags, sorted by name
    @Query(sort: \Tag.name) var tags: [Tag]
    
    /// Category for styling the view
    let itemCategory: Category
    
    /// Binding to trigger the NewTagView sheet
    @Binding var showNewTag: Bool
    
    // MARK: - Styling Configuration (Moved from TagView)
    
    struct Style {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 7
        static let backgroundOpacity: Double = 0.01
        static let reducedOpacity: Double = backgroundOpacity * 0.30
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            if tags.isEmpty {
                ContentUnavailableView {
                    Image(systemName: "tag")
                        .font(.largeTitle)
                        .foregroundStyle(.gray) // Replaced .lightGrey
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                } description: {
                    Text("No tags available. Create one to get started!")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.gray) // Replaced .lightGrey
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)
                .accessibilityLabel("No Tags Available")
                .accessibilityHint("No tags exist yet; create one to start")
                // Create Tag Button at Bottom Center
                Button(action: {
                    showNewTag = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create Tag")
                            .font(.system(.body, design: .serif))
                    }
                    .fontWeight(.bold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(itemCategory.color.opacity(0.3))
                    .foregroundStyle(itemCategory.color)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, Style.padding)
                .accessibilityLabel("Create New Tag")
                .accessibilityHint("Tap to create a new tag")
                .accessibilityAddTraits(.isButton)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(tags) { tag in
                            Button(action: {
                                toggleTag(tag)
                            }) {
                                HStack {
                                    Image(systemName: item.tags?.contains(tag) ?? false ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(itemCategory.color)
                                    Text(tag.name)
                                        .font(.system(.body, design: .serif))
                                        .foregroundStyle(.gray) // Replaced .mediumGrey
                                    Spacer()
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(tag.hexColor)
                                }
                                .padding(Style.padding)
                                .background(Color("LightGrey").opacity(Style.backgroundOpacity))
                                .clipShape(RoundedRectangle(cornerRadius: Style.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Style.cornerRadius)
                                        .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Tag: \(tag.name)")
                            .accessibilityHint(item.tags?.contains(tag) ?? false ? "Selected; tap to remove" : "Tap to add this tag")
                            .accessibilityAddTraits(.isButton)
                            .accessibilityAddTraits(item.tags?.contains(tag) ?? false ? .isSelected : [])
                        }
                        .padding(.horizontal, Style.padding)
                    }
                }
                
                // Create Tag Button at Bottom Center
                Button(action: {
                    showNewTag = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create Tag")
                            .font(.system(.body, design: .serif))
                    }
                    .fontWeight(.bold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(itemCategory.color.opacity(0.3))
                    .foregroundStyle(itemCategory.color)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, Style.padding)
                .accessibilityLabel("Create New Tag")
                .accessibilityHint("Tap to create a new tag")
                .accessibilityAddTraits(.isButton)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tag Selection List")
        .accessibilityHint("Select tags from the available list or create a new one")
    }
    
    // MARK: - Private Methods
    
    /// Toggles the tag’s presence in the item’s tags array
    private func toggleTag(_ tag: Tag) {
        if let currentTags = item.tags {
            if currentTags.contains(tag) {
                item.tags?.removeAll { $0 == tag }
            } else {
                item.tags?.append(tag)
            }
        } else {
            item.tags = [tag]
        }
        HapticsManager.notification(type: .success)
    }
}

// MARK: - Preview

