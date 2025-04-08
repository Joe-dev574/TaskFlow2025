//
//  TagListView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

/// A view that displays a list of tags associated with an `Item`, with options to add or remove tags.
public struct TagListView: View {
    // MARK: - Environment Properties
    
    /// Dismisses the view if needed (though unused here, retained for consistency).
    @Environment(\.dismiss) private var dismiss
    
    /// The SwiftData model context for managing tag operations.
    @Environment(\.modelContext) private var context
    
    /// Indicates whether reduced motion is enabled for accessibility.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    /// The `Item` whose tags are being displayed and managed, bound for two-way updates.
    @Bindable var item: Item
    
    /// A query fetching all tags, sorted by name.
    @Query(sort: \Tag.name) var tags: [Tag]
    
    /// The category of the item, used for theming.
    let itemCategory: Category
    
    // MARK: - State
    
    /// Controls the visibility of the tag creation sheet.
    @State private var showTags = false
    
    /// Binding to control the blur state of the parent view.
    @Binding var isBlurred: Bool
    
    // MARK: - Styling Configuration
    
    /// Static styling constants for consistency across the view.
    struct SectionStyle {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 7
        static let backgroundOpacity: Double = 0.01
        static let reducedOpacity: Double = backgroundOpacity * 0.30
        static let headerFont = Font.system(size: 20, weight: .bold, design: .serif)
        static let bodyFont = Font.system(.body, design: .serif)
        static let subheadlineFont = Font.system(.subheadline, design: .serif)
    }
    
    // MARK: - Initialization
    
    /// Initializes the view with an item, its category, and a binding for blur state.
    /// - Parameters:
    ///   - item: The `Item` whose tags are managed.
    ///   - itemCategory: The `Category` for theming.
    ///   - isBlurred: A binding to control the parent view's blur state.
    init(item: Item, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._item = Bindable(item)
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading) {
            headerView
            tagsContentView
        }
        .blur(radius: showTags && !reduceMotion ? 0.5 : 0) // Respect reduced motion
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
  //      .overlay(borderOverlay)
        .sheet(isPresented: $showTags, onDismiss: resetBlur) {
            TagView(item: item, itemCategory: itemCategory)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: showTags) { oldValue, newValue in
            logShowTagsChange(oldValue: oldValue, newValue: newValue)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(buildAccessibilityLabel())
    }
    
    // MARK: - View Components
    
    /// The header with the "Tags" title and add button.
    private var headerView: some View {
        HStack {
            Text("Tags")
                .foregroundStyle(itemCategory.color)
                .font(SectionStyle.headerFont)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            Button(action: addTagAction) {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(itemCategory.color)
            }
            .padding(4)
            .background(itemCategory.color.opacity(0.2))
            .clipShape(Circle())
            .accessibilityLabel("Add Tag")
            .accessibilityHint("Opens a sheet to add a new tag")
            .id(showTags ? "tagsHeaderOn" : "tagsHeaderOff") // Force re-render
        }
    }
    
    /// The content area displaying tags or a placeholder.
    private var tagsContentView: some View {
        Group {
            if item.tags?.isEmpty ?? true {
                ContentUnavailableView {
                    Image(systemName: "tag")
                        .font(.largeTitle)
                        .foregroundStyle(.lightGrey)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                        .accessibilityHidden(true) // Decorative
                } description: {
                    Text("Organize with tags! Tap the plus button to add your first one.")
                        .font(SectionStyle.bodyFont)
                        .foregroundStyle(.lightGrey)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)
                .accessibilityLabel("No tags available")
                .accessibilityHint("Tap the add tag button to create one")
            } else if let tags = item.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagItemView(
                                tag: tag,
                                onDelete: {
                                    removeTag(tag)
                                }
                            )
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 4)
                }
                .frame(height: 50)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tags: \(tags.map { $0.name }.joined(separator: ", "))")
            } else {
                Text("No tags added")
                    .foregroundStyle(.gray)
                    .font(SectionStyle.subheadlineFont)
                    .accessibilityLabel("No tags added")
            }
        }
    }
    
    /// The border overlay with a subtle stroke.
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
            .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
    }
    
    // MARK: - Actions
    
    /// Action triggered when the add tag button is tapped.
    private func addTagAction() {
        print("Add Tag tapped, showTags was: \(showTags)")
        HapticsManager.notification(type: .success)
        showTags.toggle()
        isBlurred = showTags // Sync blur with sheet state
    }
    
    /// Removes a tag from the item's tags array.
    /// - Parameter tag: The `Tag` to remove.
    private func removeTag(_ tag: Tag) {
        if let index = item.tags?.firstIndex(of: tag) {
            item.tags?.remove(at: index)
        }
    }
    
    /// Resets the blur state when the sheet is dismissed.
    private func resetBlur() {
        print("Sheet dismissed, showTags: \(showTags)")
        isBlurred = false
    }
    
    // MARK: - Helper Methods
    
    /// Logs changes to the `showTags` state for debugging.
    /// - Parameters:
    ///   - oldValue: The previous value of `showTags`.
    ///   - newValue: The new value of `showTags`.
    private func logShowTagsChange(oldValue: Bool, newValue: Bool) {
        print("showTags changed from \(oldValue) to \(newValue)")
    }
    
    /// Builds an accessibility label for the entire view.
    /// - Returns: A string describing the view's content.
    private func buildAccessibilityLabel() -> String {
        let tagsDescription = item.tags?.isEmpty ?? true ? "No tags" : "Tags: \(item.tags?.map { $0.name }.joined(separator: ", ") ?? "")"
        return "Tag list for item, \(tagsDescription)"
    }
}

