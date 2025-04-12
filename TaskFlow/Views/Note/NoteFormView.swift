//
//  NoteFormView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

import SwiftUI
import SwiftData

/// A view for creating and saving a new note within TaskFlow.
struct NoteFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    let itemCategory: Category
    let onSave: (Note) -> Void
    
    @State private var noteTitle: String = ""
    @State private var text: String = ""
    @State private var page: String = ""
    @State private var showToast: Bool = false
    
    private let creationDate: Date = .now
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    TextField("Title", text: $noteTitle)
                    
                    CustomTextEditor(
                        remarks: $text,
                        placeholder: "Write your note here...",
                        minHeight: 300
                    )
                    
                    HStack(spacing: 2) {
                        Text("Page:")
                        TextField("Page # (optional)", text: $page)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(7)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            let newNote = Note(
                                text: text, page: page.isEmpty ? nil : page, noteTitle: noteTitle
                            )
                            newNote.creationDate = creationDate
                            onSave(newNote)
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                                dismiss()
                            }
                        }
                        .disabled(noteTitle.isEmpty && text.isEmpty)
                    }
                }
                .overlay {
                    if showToast {
                        VStack {
                            Spacer()
                            Text("\"\(noteTitle)\" saved")
                            Spacer().frame(height: 50)
                        }
                    }
                }
            }
        }
    }
    
    private func addBulletList(to text: String) -> String {
        let lines = text.split(separator: "\n").filter { !$0.isEmpty }
        return lines.map { "- \(String($0))" }.joined(separator: "\n")
    }
    
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

#Preview {
    NoteFormView(
        itemCategory: .work,
        onSave: { _ in }
    )
}
