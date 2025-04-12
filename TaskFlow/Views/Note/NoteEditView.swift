//
//  NoteEditView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/5/25.
//


//
//  NoteEditView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/5/25.
//

import SwiftUI
import SwiftData

/// A view for editing an existing note within TaskFlow, mirroring NoteFormView's layout.
struct NoteEditView: View {
    // MARK: - Environment Properties
    
    /// Dismiss action from the environment to close the sheet.
    @Environment(\.dismiss) private var dismiss
    
    /// Color scheme from the environment to adapt to light/dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Input Properties
    
    /// The note object to edit, bound for live updates.
    @Binding var note: Note
    
    /// The category of the item this note belongs to, used for styling.
    let itemCategory: Category
    
    /// Closure to handle saving the updated note back to the parent view.
    let onSave: (Note) -> Void
    
    // MARK: - State Properties
    
    /// The title of the note, limited to 40 characters.
    @State private var noteTitle: String
    
    /// The main body text of the note.
    @State private var text: String
    
    /// Optional page number for the note.
    @State private var page: String
    
    /// Flag to show the save confirmation toast.
    @State private var showToast: Bool = false
    
    /// Focus state to manage keyboard visibility across text fields.
    @FocusState private var isFocused: Bool
    
    // MARK: - Initialization
    
    /// Initializes the view with the bound note’s current values.
    init(note: Binding<Note>, itemCategory: Category, onSave: @escaping (Note) -> Void) {
        self._note = note
        self.itemCategory = itemCategory
        self.onSave = onSave
        self._noteTitle = State(initialValue: note.wrappedValue.noteTitle ?? "Notes:")
        self._text = State(initialValue: note.wrappedValue.text)
        self._page = State(initialValue: note.wrappedValue.page ?? "")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    // Title input field
                    TextField("Title", text: $noteTitle)
                        .font(.title.bold()) // Bold title for emphasis
                        .foregroundStyle(colorScheme == .dark ? .white : .black) // Adapts to light/dark mode
                        .submitLabel(.done) // Shows "Done" on keyboard
                        .textFieldStyle(.plain) // No border for clean look
                        .focused($isFocused) // Ties to keyboard dismiss
                        .accessibilityLabel("Note Title") // VoiceOver label
                        .accessibilityHint("Edit the note title, maximum 40 characters") // VoiceOver hint
                        .onChange(of: noteTitle) { _, newValue in
                            // Enforces 40-character limit on title
                            if newValue.count > 40 {
                                noteTitle = String(newValue.prefix(40))
                            }
                        }
                        .padding(.horizontal, 7) // Consistent padding
                    
                    // Main note content editor
                    CustomTextEditor(
                        remarks: $text,
                        placeholder: "  Write your note here...",
                        minHeight: 300 // Ensures sufficient space for content
                    )
                    .foregroundStyle(colorScheme == .dark ? .white : .black) // Adapts to light/dark mode
                    .focused($isFocused) // Ties to keyboard dismiss
                    .accessibilityLabel("Note Content") // VoiceOver label
                    .accessibilityHint("Edit your note content here") // VoiceOver hint
                    
                    // Page number input field
                    HStack(spacing: 2) {
                        Text("Page: ")
                            .font(.system(.body, design: .serif)) // Serif for readability
                            .foregroundStyle(colorScheme == .dark ? .white : .black) // Adapts to mode
                            .accessibilityLabel("Page Label") // VoiceOver label
                        
                        TextField("Page # (optional)", text: $page)
                            .font(.system(.body, design: .serif)) // Matches "Page:" style
                            .foregroundStyle(colorScheme == .dark ? .white : .black) // Adapts to mode
                            .submitLabel(.done) // Shows "Done" on keyboard
                            .frame(width: 200) // Fixed width for consistency
                            .textFieldStyle(.plain) // No border for clean look
                            .focused($isFocused) // Ties to keyboard dismiss
                            .accessibilityLabel("Page Number") // VoiceOver label
                            .accessibilityHint("Edit the optional page number") // VoiceOver hint
                        Spacer() // Pushes content left
                    }
                    .padding(.horizontal) // Consistent padding
                    
                    Spacer() // Fills remaining space
                }
                .padding(7) // Overall content padding
                .toolbar {
                    // Cancel button in navigation bar
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            HapticsManager.notification(type: .success) // Haptic feedback on tap
                            dismiss() // Closes the sheet
                        }
                        .font(.system(.callout, design: .serif)) // Serif for style
                        .foregroundStyle(itemCategory.color) // Category-specific color
                        .accessibilityLabel("Cancel") // VoiceOver label
                        .accessibilityHint("Tap to dismiss the note editor without saving") // VoiceOver hint
                    }
                    
                    // Title in navigation bar
                    ToolbarItem(placement: .principal) {
                        Text("Edit Note") // Changed to reflect editing context
                            .font(.system(.title3, design: .serif)) // Serif for elegance
                            .foregroundStyle(itemCategory.color.opacity(0.9)) // Subtle category tint
                            .fontWeight(.semibold) // Slightly bold for emphasis
                            .accessibilityLabel("Edit Note Title") // VoiceOver label
                    }
                    
                    // Keyboard toolbar with editing tools and dismiss button
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack(spacing: 20) {
                            // Bullet list tool
                            Button(action: {
                                text = addBulletList(to: text) // Adds bullets to text
                                HapticsManager.notification(type: .success) // Haptic feedback
                            }) {
                                Image(systemName: "list.bullet")
                                    .imageScale(.large) // Larger icon for visibility
                                    .foregroundStyle(itemCategory.color) // Category color
                                    .padding(7) // Padding for touch area
                                    .background(itemCategory.color.opacity(0.2)) // Subtle background
                                    .clipShape(Circle()) // Circular shape
                            }
                            .accessibilityLabel("Bullet List") // VoiceOver label
                            .accessibilityHint("Tap to add bullet points to your note") // VoiceOver hint
                            
                            // Text format tool (placeholder)
                            Button(action: {
                                // Future text formatting logic here
                                HapticsManager.notification(type: .success) // Haptic feedback
                            }) {
                                Image(systemName: "textformat")
                                    .imageScale(.large)
                                    .foregroundStyle(itemCategory.color)
                                    .padding(7)
                                    .background(itemCategory.color.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Text Format") // VoiceOver label
                            .accessibilityHint("Tap to format your note text (feature coming soon)") // VoiceOver hint
                            
                            // Table insertion tool
                            Button(action: {
                                text = addTable(to: text) // Adds a table to text
                                HapticsManager.notification(type: .success) // Haptic feedback
                            }) {
                                Image(systemName: "tablecells")
                                    .imageScale(.large)
                                    .foregroundStyle(itemCategory.color)
                                    .padding(7)
                                    .background(itemCategory.color.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Add Table") // VoiceOver label
                            .accessibilityHint("Tap to insert a table into your note") // VoiceOver hint
                            
                            // Attachment tool (placeholder)
                            Button(action: {
                                // Future attachment logic here
                                HapticsManager.notification(type: .success) // Haptic feedback
                            }) {
                                Image(systemName: "paperclip")
                                    .imageScale(.large)
                                    .foregroundStyle(itemCategory.color)
                                    .padding(7)
                                    .background(itemCategory.color.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Attachment") // VoiceOver label
                            .accessibilityHint("Tap to add a photo to your note (feature coming soon)") // VoiceOver hint
                        }
                        .padding(.horizontal, 7) // Padding for toolbar items
                        
                        Spacer() // Pushes dismiss button to right
                        
                        // Keyboard dismiss button
                        Button(action: {
                            isFocused = false // Hides keyboard
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.gray) // Neutral gray for dismiss
                        }
                        .accessibilityLabel("Dismiss Keyboard") // VoiceOver label
                        .accessibilityHint("Tap to hide the keyboard") // VoiceOver hint
                    }
                    
                    // Save button in navigation bar
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            // Updates and saves the note
                            note.noteTitle = noteTitle
                            note.text = text
                            note.page = page.isEmpty ? nil : page
                            onSave(note)
                            HapticsManager.notification(type: .success) // Haptic feedback
                            showToast = true // Shows save confirmation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                                dismiss() // Dismisses sheet after 2s
                            }
                        }
                        .font(.system(.callout, design: .serif)) // Serif for style
                        .foregroundStyle(.white) // White text
                        .buttonStyle(.borderedProminent) // Prominent button style
                        .tint(itemCategory.color) // Category-specific tint
                        .disabled(noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Enables if either title or text has content
                        .accessibilityLabel("Save") // VoiceOver label
                        .accessibilityHint("Tap to save your changes and dismiss the editor") // VoiceOver hint
                    }
                }
                .overlay {
                    // Save confirmation toast
                    if showToast {
                        VStack {
                            Spacer()
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.green) // Green checkmark for success
                                Text("\"\(noteTitle)\" has been successfully saved")
                                    .font(.system(size: 18, design: .rounded)) // Rounded font for iOS flair
                                    .foregroundStyle(.white) // White text
                            }
                            .padding() // Padding for toast
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.85)) // Dark background
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2) // Subtle shadow
                            )
                            .transition(.opacity) // Fade in/out animation
                            .accessibilityLabel("Save Confirmation") // VoiceOver label
                            .accessibilityHint("Note titled \(noteTitle) has been saved") // VoiceOver hint
                            Spacer().frame(height: 50) // Spacing from bottom
                        }
                    }
                }
            }
            .presentationDetents([.large]) // Full-screen sheet presentation
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports dynamic text up to xxxLarge
        }
    }
    
    // MARK: - Private Functions
    
    /// Adds bullet points to the note text.
    private func addBulletList(to text: String) -> String {
        let lines = text.split(separator: "\n").filter { !$0.isEmpty }
        return lines.map { "- \(String($0))" }.joined(separator: "\n")
    }
    
    /// Adds a simple Markdown table to the note text.
    private func addTable(to text: String) -> String {
        let table = """
        | Header 1 | Header 2 |
        |----------|----------|
        | Row 1    | Data     |
        | Row 2    | Data     |
        """
        return text.isEmpty ? table : "\(text)\n\n\(table)"
    }
}

// MARK: - Preview

#Preview {
    NoteEditView(
        note: .constant(Note(text: "Sample note content here.", page: "42", noteTitle: "Sample Title")),
        itemCategory: .bills,
        onSave: { _ in }
    )
}
