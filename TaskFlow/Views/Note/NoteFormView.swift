//
//  NoteFormView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

import SwiftUI
import SwiftData

struct NoteFormView: View {
    @Environment(\.dismiss) private var dismiss
    let itemCategory: Category
    let onSave: (Note) -> Void
    
    @State private var text: String = "" // Main content, matches Note
    private let creationDate: Date = .now // Auto-set
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                CustomTextEditor(
                    remarks: $text,
                    placeholder: "Write your note here...",
                    minHeight: 200 // Big notepad area
                )
                .foregroundStyle(.primary)
                .accessibilityLabel("Note Content")
                .accessibilityHint("Enter your note content")
                
                Spacer() // Clean layout
            }
            .padding()
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(itemCategory.color)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newNote = Note(
                            text: text,
                            page: nil // No page, as requested
                        )
                        newNote.creationDate = creationDate // Auto-set
                        onSave(newNote)
                        HapticsManager.notification(type: .success)
                        dismiss()
                    }
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    .tint(itemCategory.color)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NoteFormView(
        itemCategory: .work,
        onSave: { _ in }
    )
}
