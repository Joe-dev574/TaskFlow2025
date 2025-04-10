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
    @Environment(\.colorScheme) var colorScheme
    let itemCategory: Category
    let onSave: (Note) -> Void
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var page: String = ""
    @State private var isPresentingShare: Bool = false
    @State private var isSaved: Bool = false // Track save state
    private let creationDate: Date = .now
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Button(action: { isPresentingShare = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                            .foregroundStyle(itemCategory.color)
                            .padding(7)
                            .background(itemCategory.color.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $isPresentingShare) {
                        ActivityView(title: title, text: text, creationDate: creationDate)
                    }
                    Spacer() // Room for later tools
                }
                .padding(.horizontal)
                
                HStack(spacing: 10) {
                    TextField("Title", text: $title)
                        .font(.title.bold())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .submitLabel(.done)
                        .accessibilityLabel("Note Title")
                        .accessibilityHint("Enter the note title")
                    
                    HStack(spacing: 2) {
                        Text("Page: ")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        TextField("Page # (optional)", text: $page)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .submitLabel(.done)
                            .frame(width: 80)
                            .padding(.trailing, 10)
                            .accessibilityLabel("Page Number")
                            .accessibilityHint("Enter an optional page number")
                    }
                }
                .padding(.horizontal)
                
                CustomTextEditor(
                    remarks: $text,
                    placeholder: "Write your note here...",
                    minHeight: 200
                )
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .accessibilityLabel("Note Content")
                .accessibilityHint("Enter your note content")
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        if isSaved {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .foregroundStyle(itemCategory.color)
                                .padding(7)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(Circle())
                        } else {
                            Text("Cancel")
                                .font(.system(.callout, design: .serif))
                                .foregroundStyle(itemCategory.color)
                        }
                    }
                    .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .principal) {
                    TextOnlyLogoView()
                        .frame(height: 30)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newNote = Note(
                            text: text,
                            page: page.isEmpty ? nil : page
                        )
                        newNote.creationDate = creationDate
                        onSave(newNote)
                        HapticsManager.notification(type: .success)
                        isSaved = true // Switch Cancel to "X"
                    }
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    .tint(itemCategory.color)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Save")
                }
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let title: String
    let text: String
    let creationDate: Date
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let formattedText = text.split(separator: "\n").map { String($0) }.joined(separator: "\n")
        let shareContent = "Note from TaskFlow\nTitle: \(title)\nCreated: \(creationDate.formatted(.dateTime))\n\n\(formattedText)"
        return UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NoteFormView(
        itemCategory: .work,
        onSave: { _ in }
    )
}
