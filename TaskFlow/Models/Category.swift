//
//  Category.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

/// Represents different life domains and priority categories with associated styling
enum Category: String, CaseIterable {
    // MARK: - Life Domain Cases
    
    case today = "Today"    // Tasks for the current day
    case work = "Work"      // Professional or job-related tasks
    case family = "Family"  // Family-related responsibilities
    case health = "Health"  // Health and wellness tasks
    case learn = "Learn"    // Learning or educational goals
    case bills = "Money"    // Financial obligations or bills
    case events = "Events"  // Scheduled or recurring events
    
    // MARK: - Computed Properties
    
    /// Returns a color associated with each category for visual distinction
    var color: Color {
        switch self {
        case .today:
            return .color1
        case .work:
            return .color2
        case .family:
            return .color3
        case .health:
            return .color4
        case .events:
            return .primary
        case .learn:
            return .color6
        case .bills:
            return .color7
        }
    }
    
    /// Returns a system symbol image for each category
    var symbolImage: String {
        switch self {
        case .today:
            return "alarm" // Represents time-sensitive daily tasks
        case .work:
            return "briefcase" // Symbolizes professional duties
        case .family:
            return "figure.2.and.child.holdinghands" // Depicts family connection
        case .health:
            return "heart" // Indicates health focus
        case .learn:
            return "book" // Represents education or knowledge
        case .bills:
            return "banknote" // Symbolizes financial tasks
        case .events:
            return "repeat" // Indicates recurring or scheduled events
        }
    }
    
    // MARK: - Accessibility Support
    
    /// Provides a localized description for accessibility purposes
    var accessibilityLabel: String {
        switch self {
        case .today:
            return "Today"
        case .work:
            return "Work"
        case .family:
            return "Family"
        case .health:
            return "Health"
        case .learn:
            return "Learn"
        case .bills:
            return "Money"
        case .events:
            return "Events"
        }
    }
    
    /// Provides additional context for accessibility, e.g., for VoiceOver hints
    var accessibilityHint: String {
        switch self {
        case .today:
            return "Category for tasks due today"
        case .work:
            return "Category for work-related tasks"
        case .family:
            return "Category for family-related tasks"
        case .health:
            return "Category for health and wellness tasks"
        case .learn:
            return "Category for learning and education tasks"
        case .bills:
            return "Category for financial obligations"
        case .events:
            return "Category for scheduled or recurring events"
        }
    }
}
