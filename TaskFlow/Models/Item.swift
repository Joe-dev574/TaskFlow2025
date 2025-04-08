//
//  Item.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

/// A model class representing an Item entity that conforms to SwiftData's @Model macro
/// This class defines the structure for items that can be stored and managed in the app
@Model
final class Item {
    // MARK: - Properties
    
    /// The title of the item, required field
    var title: String
    
    /// Additional notes or comments about the item
    var remarks: String
    
    /// Date when the item was created
    var dateAdded: Date
    
    /// Date when work on the item began
    var dateStarted: Date
    
    /// Deadline or due date for the item
    var dateDue: Date
    
    /// Date when the item was completed
    var dateCompleted: Date
    
    /// Category classification stored as raw String value from Category enum
    var category: String
    
    /// Status of the item stored as raw Int value from Status enum
    var status: Status.RawValue
    
    /// Tint color identifier for UI representation
    var tintColor: String
    
    /// Relationship to Tag objects, optional
    // @Relationship(inverse: \Tag.items) // Uncomment if Tag model has inverse relationship
    var tags: [Tag]?
    
    /// Relationship to ItemTask objects with cascade delete rule
    /// When an Item is deleted, all associated ItemTasks are also deleted
    @Relationship(deleteRule: .cascade)
    var itemTasks: [ItemTask]?
    
    /// Relationship to Note objects with cascade delete rule
    /// When an Item is deleted, all associated Notes are also deleted
    @Relationship(deleteRule: .cascade)
    var notes: [Note]?
    
    /// Relationship to Attachment objects with cascade delete rule
    /// When an Item is deleted, all associated Attachments are also deleted
    @Relationship(deleteRule: .cascade)
    var attachments: [Attachment]?
    
    // MARK: - Initialization
    
    /// Initializes a new Item with default values
    init(
        title: String = "",
        remarks: String = "",
        dateAdded: Date = .now,
        dateDue: Date = .now,
        dateStarted: Date = .now,
        dateCompleted: Date = .now,
        status: Status = .Active,
        category: Category = .events,
        tintColor: TintColor, // Assumes TintColor is a struct/enum with a `color` property
        tags: [Tag]? = nil,
        itemTasks: [ItemTask]? = nil,
        notes: [Note]? = nil, // Added notes parameter
        attachments: [Attachment]? = nil // Already present, now assigned
    ) {
        self.title = title
        self.remarks = remarks
        self.dateAdded = dateAdded
        self.dateDue = dateDue
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.category = category.rawValue
        self.status = status.rawValue
        self.tintColor = tintColor.color
        self.tags = tags
        self.itemTasks = itemTasks
        self.notes = notes // Assigned notes
        self.attachments = attachments // Assigned attachments
    }
    
    // MARK: - Computed Properties
    
    /// Returns an icon based on the item's status
    var icon: Image {
        switch Status(rawValue: status) ?? .Active { // Fallback to .Active if invalid
        case .Upcoming:
            Image(systemName: "calendar.badge.clock")
        case .Active:
            Image(systemName: "app.badge.clock")
        case .Hold:
            Image(systemName: "calendar.badge.exclamationmark")
        case .Plan:
            Image(systemName: "calendar")
        }
    }
    
    /// Extracts Color value from tintColor string
    @Transient
    var color: Color {
        tints.first(where: { $0.color == tintColor })?.value ?? Color.gray // Fallback to gray if undefined
    }
    
    /// Retrieves the TintColor object matching the tintColor string
    @Transient
    var tint: TintColor? {
        tints.first(where: { $0.color == tintColor })
    }
    
    /// Converts raw category string back to Category enum
    @Transient
    var rawCategory: Category? {
        Category.allCases.first(where: { category == $0.rawValue })
    }
    
    // MARK: - Helper Methods
    
    /// Determines if the item is completed based on completion date
    func isCompleted() -> Bool {
        dateCompleted <= .now
    }
    
    /// Calculates remaining days until due date
    /// Returns nil if due date has passed or calculation fails
    func daysUntilDue() -> Int? {
        let days = Calendar.current.dateComponents([.day], from: .now, to: dateDue).day
        return days != nil && days! >= 0 ? days : nil
    }
    
    // MARK: - Status Enum
    
    /// Enum representing the possible statuses of an Item
    enum Status: Int, Codable, Identifiable, CaseIterable {
        case Plan, Upcoming, Active, Hold
        var id: Self { self }
        
        /// Localized description for each status
        var descr: LocalizedStringResource {
            switch self {
            case .Plan: "Plan"
            case .Upcoming: "Upcoming"
            case .Active: "Active"
            case .Hold: "Hold"
            }
        }
    }
}

// MARK: - Extensions

/// Conformance to Identifiable (ID provided by @Model)
extension Item: Identifiable {}

/// Date extension for convenience methods
extension Date {
    /// Creates a date by adding hours to current time
    static func updateHour(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: value, to: .now) ?? .now
    }
    
    // Added for consistency with TaskRowView
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }
}
