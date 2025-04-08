//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

/// A view for creating a new tag with a name and color, allowing users to assign it to an `Item`.
struct NewTagView: View {
    // MARK: - Environment Properties
    
    /// Dismisses the view when the user cancels or saves.
    @Environment(\.dismiss) private var dismiss
    
    /// The SwiftData model context for saving the new tag.
    @Environment(\.modelContext) private var context
    
    // MARK: - Properties
    
    /// The `Item` to which the new tag will be optionally added, bound for two-way updates.
    @Bindable var item: Item
    
    /// The category of the item, used for consistent theming throughout the view.
    let itemCategory: Category
    
    // MARK: - State
    
    /// The name of the new tag, entered by the user.
    @State private var tagName: String = ""
    
    /// The color of the new tag, selected via the color picker, defaults to gray.
    @State private var tagColor: Color = .gray
    
    // MARK: - Styling Configuration
    
    /// Static styling constants for consistency across the view.
    struct Style {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 7
        static let backgroundOpacity: Double = 0.01
        static let reducedOpacity: Double = backgroundOpacity * 0.30
        static let bodyFont = Font.system(.body, design: .serif)
        static let headlineFont = Font.system(.headline, design: .serif)
    }
    
    // MARK: - Initialization
    
    /// Initializes the view with an item and its category.
    /// - Parameters:
    ///   - item: The `Item` to which the tag may be added.
    ///   - itemCategory: The `Category` of the item for theming.
    init(item: Item, itemCategory: Category) {
        self._item = Bindable(item)
        self.itemCategory = itemCategory
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                sectionContent
            }
            .background(itemCategory.color.opacity(Style.reducedOpacity))
            .scrollContentBackground(.hidden)
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelButton
                saveButton
            }
            .tint(itemCategory.color)
        }
    }
    
    // MARK: - View Components
    
    /// The main content of the form section for tag details.
    private var sectionContent: some View {
        Section(
            header: Text("Tag Details")
                .foregroundStyle(itemCategory.color)
                .font(Style.headlineFont)
                .accessibilityAddTraits(.isHeader)
        ) {
            TextField("Tag Name", text: $tagName)
                .font(Style.bodyFont)
                .foregroundStyle(.mediumGrey)
                .submitLabel(.done)
                .accessibilityLabel("Tag Name")
                .accessibilityHint("Enter a name for the new tag")
            
            ColorPicker("Tag Color", selection: $tagColor)
                .font(Style.bodyFont)
                .foregroundStyle(.mediumGrey)
                .accessibilityLabel("Tag Color")
                .accessibilityHint("Select a color for the new tag")
        }
    }
    
    /// The cancel button in the toolbar.
    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
            .font(Style.bodyFont)
            .foregroundStyle(itemCategory.color)
            .accessibilityLabel("Cancel creating new tag")
            .accessibilityHint("Dismisses the view without saving")
        }
    }
    
    /// The save button in the toolbar, disabled if the tag name is empty.
    private var saveButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                saveTag()
                dismiss()
            }
            .buttonBorderShape(.roundedRectangle)
            .font(Style.bodyFont)
            .foregroundStyle(itemCategory.color)
            .disabled(tagName.isEmpty)
            .accessibilityLabel("Save new tag")
            .accessibilityHint(tagName.isEmpty ? "Enter a tag name to enable saving" : "Saves the tag and dismisses the view")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Saves the new tag to the model context and associates it with the item.
    private func saveTag() {
        let hexColor = tagColor.toHex() ?? "FF0000" // Fallback to red if conversion fails
        let newTag = Tag(name: tagName, tagColor: hexColor)
        context.insert(newTag)
        
        // Add the tag to the item's tags array, initializing it if nil
        if item.tags != nil {
            item.tags?.append(newTag)
        } else {
            item.tags = [newTag]
        }
        
        do {
            try context.save()
            HapticsManager.notification(type: .success) // Provide haptic feedback on success
        } catch {
            print("Failed to save tag: \(error.localizedDescription)")
            HapticsManager.notification(type: .error) // Haptic feedback on failure
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Converts the color to a hexadecimal string representation.
    /// - Returns: A hex string (e.g., "FF5733") or nil if conversion fails.
    func toHex() -> String? {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }

}

// MARK: - Preview

