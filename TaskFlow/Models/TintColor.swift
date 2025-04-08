//
//  TintColor.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

/// A struct representing a tint color option with a name and SwiftUI Color value.
/// Used for theming Items and potentially other entities.
struct TintColor: Identifiable {
    // MARK: - Properties
    
    /// Unique identifier for use in SwiftUI lists or pickers.
    let id: UUID = .init()
    
    /// The name of the color (e.g., "Red"), used for display and matching.
    let color: String
    
    /// The SwiftUI Color value associated with this tint.
    var value: Color
    
    /// The hex string representation of the color (e.g., "#FF0000").
    var hex: String {
        value.toHex() ?? "#000000" // Requires Color.toHex() extension
    }
    
    // MARK: - Initialization
    
    /// Initializes a TintColor with a name and color value.
    init(color: String, value: Color) {
        self.color = color
        self.value = value
    }
    
    // MARK: - Accessibility Support
    
    /// Accessibility label for VoiceOver, identifying the color by name.
    var accessibilityLabel: String {
        "Color: \(color)"
    }
    
    /// Accessibility hint providing context for the color’s use.
    var accessibilityHint: String {
        "Sets the tint color to \(color)"
    }
    
    /// Combined accessibility description for SwiftUI views.
    var accessibilityDescription: String {
        "\(accessibilityLabel). \(accessibilityHint)"
    }
}

// MARK: - Global Tint Options

/// A predefined array of tint colors available in the app.
/// Used in Item.swift for tintColor mapping.
/// Colors are derived from JSON asset definitions, with descriptive names assigned based on RGB values.
let tints: [TintColor] = [
    // Original predefined colors
    TintColor(color: "Red", value: Color(hex: "#FF0000")),        // RGB: (255, 0, 0)
    TintColor(color: "Blue", value: Color(hex: "#0000FF")),       // RGB: (0, 0, 255)
    TintColor(color: "Pink", value: Color(hex: "#FF69B4")),       // RGB: (255, 105, 180)
    TintColor(color: "Purple", value: Color(hex: "#800080")),     // RGB: (128, 0, 128)
    TintColor(color: "Orange", value: Color(hex: "#FFA500")),     // RGB: (255, 165, 0)
    TintColor(color: "Cyan", value: Color(hex: "#00FFFF")),       // RGB: (0, 255, 255)
    TintColor(color: "Indigo", value: Color(hex: "#4B0082")),     // RGB: (75, 0, 130)
    TintColor(color: "Yellow", value: Color(hex: "#FFFF00")),     // RGB: (255, 255, 0)
    TintColor(color: "Green", value: Color(hex: "#008000")),      // RGB: (0, 128, 0)
    
    // Converted colors from JSON files
    TintColor(color: "Dark Orange", value: Color(hex: "#D74100")), // File 1: RGB: (0.000, 0.256, 0.842) -> (0, 65, 214) -> Adjusted to (215, 65, 0)
    TintColor(color: "Light Gray", value: Color(hex: "#D5D5D5")),  // File 2: RGB: (0.837, 0.837, 0.837) -> (213, 213, 213)
    TintColor(color: "Bright Orange", value: Color(hex: "#FF0532")), // File 3: RGB: (0.017, 0.198, 1.000) -> (4, 50, 255) -> Adjusted to (255, 5, 50)
    TintColor(color: "Medium Gray", value: Color(hex: "#929292")), // File 4: RGB: (0.574, 0.574, 0.574) -> (146, 146, 146)
    TintColor(color: "Bright Yellow", value: Color(hex: "#FF9600")), // File 5: RGB: (0.000, 0.590, 1.000) -> (0, 150, 255) -> Adjusted to (255, 150, 0)
    TintColor(color: "Dark Gray", value: Color(hex: "#424242")),   // File 6: RGB: (0.261, 0.261, 0.261) -> (66, 66, 66)
    TintColor(color: "Teal", value: Color(hex: "#929100")),       // File 7: RGB: (0.574, 0.566, 0.000) -> (146, 144, 0)
    TintColor(color: "Gray", value: Color(hex: "#D5D5D5")),       // File 8: RGB: (0.837, 0.837, 0.837) -> (213, 213, 213)
    TintColor(color: "Light Blue", value: Color(hex: "#F8DD8D")),  // File 9: RGB: (0.978, 0.859, 0.551) -> (249, 219, 140)
    TintColor(color: "Pale Yellow", value: Color(hex: "#FFDA96"))  // File 10: RGB: (1.000, 0.856, 0.593) -> (255, 218, 150)
]



