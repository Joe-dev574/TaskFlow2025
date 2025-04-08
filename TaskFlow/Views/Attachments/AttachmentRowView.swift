//
//  AttachmentRowView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/6/25.
//


import SwiftUI

struct AttachmentRowView: View {
    // MARK: - Properties
    let attachment: Attachment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Section Styling
    private struct SectionStyle {
        static let backgroundOpacity: Double = 0.01 // Defined here to avoid dependency
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let uiImage = UIImage(data: attachment.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }
            Text(attachment.fileName)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(colorScheme == .dark ? .white : .mediumGrey)
            Text(attachment.creationDate, style: .date)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.gray)
        }
        .padding(8)
        .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    // Mock Attachment for preview
    let mockData = UIImage(systemName: "photo")!.jpegData(compressionQuality: 1.0)!
    let mockAttachment = Attachment(data: mockData, fileName: "preview_photo.jpg")
    
    return AttachmentRowView(attachment: mockAttachment)
        .padding()
        .background(Color(.systemBackground)) // Optional: adds context for light/dark mode
}
