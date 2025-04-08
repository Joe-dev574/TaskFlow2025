//
//  NoteRowView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/30/25.
//

import SwiftUI

struct NoteRowView: View {
    @Bindable var note: Note
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(colorScheme == .dark ? .white : .mediumGrey) // Contrast fix
            if let page = note.page {
                Text("Page: \(page)")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(.gray)
            }
            Text(note.creationDate, style: .date)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.gray)
        }
        .padding(8)
        .background(Color("LightGrey").opacity(0.01)) // Matches ItemEditView
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
