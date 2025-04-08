//
//  Tag.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData



/// A model class representing a Tag entity that can be associated with Items in the app.
/// Tags are identifiable by name and color, and conform to SwiftData's @Model for persistence.
@Model
class Tag {
    // MARK: - Properties
    
    /// The name of the tag, used as a primary identifier
    var name: String
    
    /// The color of the tag stored as a hexadecimal string (e.g., "FF0000" for red)
    var tagColor: String
    
    /// Optional relationship to Items that this tag is applied to
    @Relationship(inverse: \Item.tags)
    var items: [Item]?
    
    // MARK: - Initialization
    
    /// Initializes a new Tag with a name and color
    /// - Parameters:
    ///   - name: The name of the tag (defaults to an empty string)
    ///   - tagColor: The hexadecimal color code for the tag (defaults to "FF0000" for red)
    init(name: String = "", tagColor: String = "FF0000") {
        self.name = name
        self.tagColor = tagColor
    }
    
    // MARK: - Computed Properties
    
    /// Returns the tag's color as a SwiftUI Color based on the hexadecimal tagColor
    @Transient
    var hexColor: Color {
        Color(hex: self.tagColor) // Assumes a Color(hex:) initializer exists
    }
}

// MARK: - Hashable Conformance

/// Extension to make Tag conform to Hashable for use in sets and dictionaries
extension Tag: Hashable {
    /// Determines equality between two Tag instances based on name and tagColor
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name == rhs.name && lhs.tagColor == rhs.tagColor
    }
    
    /// Hashes the Tag instance using its name and tagColor for uniqueness
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(tagColor)
    }
}

// MARK: - Color Extension (for hexColor)

/// Extension to SwiftUI's Color to support initialization from hex strings
extension Color {
    /// Initializes a Color from a hexadecimal string
    /// - Parameter hex: A hex color code (e.g., "FF0000" or "#FF0000")
    /// - Returns: A Color instance, defaulting to gray if parsing fails
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128) // Default to gray if invalid
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
