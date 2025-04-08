//
//  ThemeManager.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

/// Manages app-wide theme settings, including dark mode and theme color.
/// Persists settings to UserDefaults and notifies views via @Published properties for real-time updates.
class ThemeManager: ObservableObject {
    // MARK: - Properties
    
    /// Indicates whether dark mode is enabled, persisted to UserDefaults
    /// Updates UserDefaults whenever the value changes
    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode") {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            print("ThemeManager: isDarkMode updated to \(isDarkMode)")
        }
    }
    
    /// Stores the theme color as a hexadecimal string, persisted to UserDefaults
    /// Defaults to blue ("#0000FF") if no value is found
    @Published var themeColorData: String = UserDefaults.standard.string(forKey: "themeColor") ?? Color.blue.toHex() ?? "#0000FF" {
        didSet {
            UserDefaults.standard.set(themeColorData, forKey: "themeColor")
            print("ThemeManager: themeColorData updated to \(themeColorData)")
        }
    }
    
    // MARK: - Computed Properties
    
    /// Provides the theme color as a SwiftUI Color based on the hex string in themeColorData
    /// Allows setting the color, which updates themeColorData
    var themeColor: Color {
        get { Color(hex: themeColorData) }
        set { themeColorData = newValue.toHex() ?? "#0000FF" }
    }
    
    // MARK: - Initialization
    
    /// Initializes the ThemeManager with persisted values from UserDefaults
    init() {
        // No additional setup needed; @Published properties handle initialization
    }
}

