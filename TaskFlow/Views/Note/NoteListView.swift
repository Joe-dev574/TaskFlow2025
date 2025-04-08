//
//  NoteListView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

import SwiftUI
import SwiftData



struct NotesListView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Binding var notes: [Note]
    let itemCategory: Category
    @Binding var isBlurred: Bool
    
    @State private var showingAddNoteSheet: Bool = false
    @State private var noteListHeight: CGFloat = 0
    
    // MARK: - Computed Properties
    var noteCount: Int {
        notes.count
    }
    
    // MARK: - Section Styling
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 16
        static let backgroundOpacity: Double = 0.01
        static let reducedOpacity: Double = backgroundOpacity * 0.30
    }
    
    // MARK: - Initialization
    init(notes: Binding<[Note]>, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._notes = notes
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    // MARK: - Preference Key for Height Measurement
    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Notes")
                        .foregroundStyle(itemCategory.color)
                        .font(.system(size: 22, design: .serif))
                        .fontWeight(.bold)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .accessibilityLabel("Notes Header")
                        .accessibilityHint("List of notes for this item")
                    Spacer()
                    Button(action: {
                        showingAddNoteSheet = true
                        isBlurred = true
                        HapticsManager.notification(type: .success)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(itemCategory.color)
                            .padding(7)
                            .background(itemCategory.color.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Add Note")
                    .accessibilityHint("Tap to add a new note to this item")
                }
                
                if notes.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("Note bin is empty", systemImage: "note.text")
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(.gray)
                        },
                        description: {
                            Text("Add a new note by tapping the plus (+) button above.")
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(.gray)
                        }
                    )
                    .accessibilityLabel("No notes available")
                    .accessibilityHint("Tap the Add Note button to create a new note")
                } else {
                    List {
                        ForEach(notes.indices, id: \.self) { index in
                            NavigationLink(
                                destination: NoteEditView(
                                    note: Binding(
                                        get: { notes[index] },
                                        set: { notes[index] = $0 }
                                    ),
                                    itemCategory: itemCategory,
                                    onSave: { updatedNote in
                                        notes[index] = updatedNote
                                        saveContext()
                                    }
                                )
                            ) {
                                NoteRowView(note: notes[index])
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteNote(notes[index])
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .font(.system(.body, design: .serif))
                                }
                                .accessibilityLabel("Delete Note")
                                .accessibilityHint("Swipe right and tap to delete this note")
                            }
                        }
                    }
                    .padding(4)
                    .listStyle(.plain)
                    .frame(minHeight: 250, maxHeight: 1000)
                    .accessibilityLabel("Note List")
                    .accessibilityHint("Contains a list of notes for this item")
                }
            }
            .navigationTitle("Notes")
            .sheet(isPresented: $showingAddNoteSheet, onDismiss: {
                isBlurred = false
            }) {
                NoteFormView(
                    itemCategory: itemCategory,
                    onSave: { newNote in
                        notes.append(newNote)
                        modelContext.insert(newNote)
                        saveContext()
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - Methods
    private func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0 === note }) {
            notes.remove(at: index)
        }
        modelContext.delete(note)
        saveContext()
    }
    
    private func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
                print("NotesListView: Context saved successfully")
            } else {
                print("NotesListView: No changes to save in context")
            }
        } catch {
            print("NotesListView: Failed to save context: \(error.localizedDescription)")
        }
    }
}
