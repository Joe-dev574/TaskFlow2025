//
//  Attachments.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/6/25.
//

import Foundation
import SwiftData

/// A model class representing an Attachment entity that conforms to SwiftData's @Model macro
/// This class defines the structure for attachments (e.g., images, files) associated with an Item
@Model
final class Attachment: Equatable {
    // MARK: - Properties
    
    /// Binary data representing the attachment content (e.g., image or file data)
    var data: Data
    
    /// Name of the attachment file (e.g., "photo_123.jpg")
    var fileName: String
    
    /// Date when the attachment was created
    var creationDate: Date
    
    /// Relationship to the parent Item, with nullify delete rule
    /// When an Item is deleted, this attachment remains but loses its reference to the Item
    @Relationship(deleteRule: .nullify, inverse: \Item.attachments)
    var item: Item?
    
    // MARK: - Initialization
    
    /// Initializes a new Attachment with the specified properties
    init(
        data: Data,
        fileName: String,
        creationDate: Date = .now
    ) {
        self.data = data
        self.fileName = fileName
        self.creationDate = creationDate
    }
    
    // MARK: - Equatable Conformance
    
    /// Compares two Attachment instances for equality
    static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        lhs.data == rhs.data &&
        lhs.fileName == rhs.fileName &&
        lhs.creationDate == rhs.creationDate
    }
    
    // MARK: - Helper Methods
    
    /// Returns a human-readable file size (e.g., "1.2 MB")
    var fileSizeDescription: String {
        let byteCount = data.count
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(byteCount))
    }
}

// MARK: - Extensions

/// Conformance to Identifiable (ID provided by @Model)
extension Attachment: Identifiable {}
