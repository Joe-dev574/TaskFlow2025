//
//  NoteRowView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

//
//  NoteRowView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

//
//  NoteRowView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

import SwiftUI

/// A view displaying a single note in a list with a logo, title, page, date, and body.
struct NoteRowView: View {
    // MARK: - Properties
    
    /// The note object to display, bound for live updates.
    @Bindable var note: Note
    
    // MARK: - Environment
    
    /// Color scheme for light/dark mode adaptation.
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Logo at the top
            TextOnlyLogoView()
                .frame(maxWidth: .infinity, alignment: .center) // Centered logo
                .scaleEffect(0.8) // Slightly smaller for row fit
                .accessibilityHidden(true) // Decorative, no VoiceOver needed
            
            // Title in bold
            Text(note.noteTitle ?? "Note:  ")
                .font(.system(.headline, design: .serif, weight: .bold)) // Bold serif title
                .foregroundStyle(colorScheme == .dark ? .white : .black) // Mode-adapted contrast
                .accessibilityLabel("Note Title: \(note.noteTitle ?? "Note")") // VoiceOver label
            
            // Page number (if provided)
            if let page = note.page {
                Text("Page: \(page)")
                    .font(.system(.subheadline, design: .serif)) // Smaller serif
                    .foregroundStyle(.gray) // Secondary color
                    .accessibilityLabel("Page Number: \(page)") // VoiceOver label
            }
            
            // Creation date in secondary color
            Text(note.creationDate, style: .date)
                .font(.system(.subheadline, design: .serif)) // Smaller serif
                .foregroundStyle(.gray) // Secondary color
                .accessibilityLabel("Created: \(note.creationDate, style: .date)") // VoiceOver label
            
            // Spacer between metadata and body
            Spacer().frame(height: 4)
            
            // Note body text
            Text(note.text)
                .font(.system(.body, design: .serif)) // Body serif
                .foregroundStyle(colorScheme == .dark ? .white : .mediumGrey) // Contrast fix
                .accessibilityLabel("Note Content: \(note.text)") // VoiceOver label
        }
        .padding(8) // Inner padding for content
        .background(Color("LightGrey").opacity(0.02)) // Subtle background, matches ItemEditView
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Rounded corners
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1) // Light border
        )
        .shadow(color: .gray.opacity(colorScheme == .dark ? 0.6 : 0.4), radius: 4, x: 1, y: 2) // Shadow under note
        .accessibilityElement(children: .combine) // Combines children for VoiceOver
        .accessibilityHint("Double-tap to edit this note") // VoiceOver hint
    }
}

