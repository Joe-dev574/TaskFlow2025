//
//  NoteEditView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/5/25.
//


import SwiftUI
import SwiftData

struct NoteEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var note: Note
    let itemCategory: Category
    let onSave: (Note) -> Void
    
    @State private var title: String
    @State private var text: String
    @State private var page: String
    @State private var isPresentingShare: Bool = false
    
    init(note: Binding<Note>, itemCategory: Category, onSave: @escaping (Note) -> Void) {
        self._note = note
        self.itemCategory = itemCategory
        self.onSave = onSave
        self._title = State(initialValue: note.wrappedValue.text.split(separator: "\n").first.map(String.init) ?? "")
        self._text = State(initialValue: note.wrappedValue.text)
        self._page = State(initialValue: note.wrappedValue.page ?? "")
    }
    
    var body: some View {
      
            
            HStack(spacing: 10) {
                TextField("Title", text: $title)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(.primary)
                    .submitLabel(.done)
                    .accessibilityLabel("Note Title")
                    .accessibilityHint("Edit the note title")
                
                TextField("Page# (optional)", text: $page)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(.primary)
                    .submitLabel(.done)
                    .frame(width: 100)
                    .accessibilityLabel("Page Number")
                    .accessibilityHint("Edit the page number")
            }
          
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(.callout, design: .serif))
                .foregroundStyle(itemCategory.color)
            }
            ToolbarItem(placement: .principal) {
                TextOnlyLogoView()
                    .frame(height: 30)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    note.text = text
                    note.page = page.isEmpty ? nil : page
                    onSave(note)
                    HapticsManager.notification(type: .success)
                    dismiss()
                }
                .font(.system(.callout, design: .serif))
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
   
}

#Preview {
    NoteEditView(
        note: .constant(Note(text: "Sample Note", page: "42")),
        itemCategory: .bills,
        onSave: { _ in }
    )
}
