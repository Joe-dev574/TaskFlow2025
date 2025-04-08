//
//  CustomTextEditor.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct CustomTextEditor: View {
    // MARK: - Properties
    
    /// Two-way binding to the text content being edited
    @Binding var remarks: String
    
    /// Placeholder text displayed when the editor is empty
    let placeholder: String
    
    /// Minimum height of the text editor to ensure visibility
    let minHeight: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder text shown when remarks is empty
            if remarks.isEmpty {
                Text(placeholder)
                    .fontDesign(.serif)
                    .fontWeight(.regular)
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)    // Matches TextEditor’s top padding
                    .padding(.leading, 4) // Slight left alignment
                    .accessibilityHidden(true) // Placeholder isn’t interactive
            }
            
            // Main text editor component
            TextEditor(text: $remarks)
                .scrollContentBackground(.hidden) // Removes default background
                //.background(.background.opacity(0.4)) // Uncomment if desired
                .fontDesign(.serif)
                .fontWeight(.regular)
                .font(.system(size: 18))
                .frame(minHeight: minHeight)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4) // Inner padding for text
                .padding(.horizontal, 8) // Extra outer padding
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2) // Replaced .overlayStroke with .gray
                )
                .accessibilityLabel("Text Editor")
                .accessibilityHint(remarks.isEmpty ? "   Enter text here" : "   Edit your text")
                .accessibilityValue(remarks.isEmpty ? "Empty" : remarks)
        }
    }
}

// MARK: - Preview

/// Preview provider for CustomTextEditor with sample data
#Preview {
    VStack {
        CustomTextEditor(
            remarks: .constant(""),
            placeholder: "Enter your text here...",
            minHeight: 100
        )
        CustomTextEditor(
            remarks: .constant("Sample text"),
            placeholder: "Enter your text here...",
            minHeight: 100
        )
    }
    .padding()
}
