//
//  ItemTask.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

/// A model class representing a task item, managed by SwiftData.
/// Supports persistence, Codable conformance, and provides formatted date properties.
@Model
final class ItemTask: Codable {
    // MARK: - Properties
    
    /// The name of the task, guaranteed to be non-empty after initialization.
    /// Marked as unique, though this may restrict duplicate task names.
    @Attribute(.unique)
    var taskName: String = ""
    
    /// A detailed description of the task, can be empty.
    var taskDescription: String = ""
    
    /// Indicates whether the task is completed.
    var isCompleted: Bool
    
    /// The date when the task was created, set automatically on initialization.
    /// Marked as unique, which may limit tasks created at the same instant.
    @Attribute(.unique)
    var dateCreated = Date.now
    
    /// The due date for the task, defaults to now if not specified.
    var taskDueDate = Date.now
    
    /// Optional reference to a related Item object (parent entity).
    /// Nullified if the parent Item is deleted.
    @Relationship(deleteRule: .nullify, inverse: \Item.itemTasks)
    var item: Item?
    
    // MARK: - Initialization
    
    /// Initializes a new task item with the specified properties.
    init(
        taskName: String = "",
        taskDescription: String = "",
        isCompleted: Bool = false,
        dateCreated: Date = Date.now,
        taskDueDate: Date = Date.now,
        item: Item? = nil
    ) {
        let trimmedName = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taskName = trimmedName.isEmpty ? "Untitled Task" : taskName
        self.taskDescription = taskDescription
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.taskDueDate = taskDueDate
        self.item = item
    }
    
    // MARK: - Computed Properties
    
    /// Formatted date string for display (e.g., "Sep 15, 2023 at 2:30 PM").
    var formattedDateCreated: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateCreated)
    }
    
    /// Relative date string for user-friendly display (e.g., "Today", "Yesterday").
    var relativeDateCreated: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: dateCreated, relativeTo: Date())
    }
    
    /// A short summary of the task for display, combining name and completion status.
    var summary: String {
        let status = isCompleted ? "✅" : "⬜"
        return "\(status) \(taskName)"
    }
    
    // MARK: - Accessibility Support
    
    /// Accessibility label for VoiceOver, describing the task and its status.
    var accessibilityLabel: String {
        let status = isCompleted ? "Completed" : "Not completed"
        return "\(taskName), \(status)"
    }
    
    /// Accessibility hint providing additional context for the task.
    var accessibilityHint: String {
        if taskDescription.isEmpty {
            return "Due \(taskDueDate.formatted(.dateTime)), created \(relativeDateCreated)"
        } else {
            return "Description: \(taskDescription). Due \(taskDueDate.formatted(.dateTime)), created \(relativeDateCreated)"
        }
    }
    
    /// Combined accessibility description for convenience in SwiftUI views.
    var accessibilityDescription: String {
        "\(accessibilityLabel). \(accessibilityHint)"
    }
    
    // MARK: - Methods
    
    /// Toggles the completion status of the task.
    func toggleCompletion() {
        isCompleted.toggle()
    }
    
    /// Updates the task name, ensuring it’s never empty.
    func updateTaskName(_ newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taskName = trimmedName.isEmpty ? "Untitled Task" : newName
    }
    
    // MARK: - Codable Conformance
    
    enum CodingKeys: String, CodingKey {
        case taskName
        case taskDescription
        case isCompleted
        case dateCreated
        case taskDueDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(taskName, forKey: .taskName)
        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(taskDueDate, forKey: .taskDueDate)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedTaskName = try container.decode(String.self, forKey: .taskName)
        let trimmedName = decodedTaskName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taskName = trimmedName.isEmpty ? "Untitled Task" : decodedTaskName
        self.taskDescription = try container.decode(String.self, forKey: .taskDescription)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.taskDueDate = try container.decode(Date.self, forKey: .taskDueDate)
        self.item = nil // Relationships are not decoded; must be set separately
    }
}

// MARK: - Preview Extension

extension ItemTask {
    /// Sample tasks for SwiftUI previews.
    static var previewTasks: [ItemTask] {
        [
            ItemTask(
                taskName: "Buy Groceries",
                taskDescription: "Milk, eggs, bread, and butter",
                isCompleted: false,
                dateCreated: Date().addingTimeInterval(-86400), // Yesterday
                taskDueDate: Date().addingTimeInterval(86400) // Tomorrow
            ),
            ItemTask(
                taskName: "Finish Project",
                taskDescription: "Complete the SwiftUI implementation",
                isCompleted: true,
                dateCreated: Date().addingTimeInterval(-172800), // 2 days ago
                taskDueDate: Date()
            ),
            ItemTask(
                taskName: "Call Mom",
                taskDescription: "Check in and see how she's doing",
                isCompleted: false,
                dateCreated: Date(), // Today
                taskDueDate: Date().addingTimeInterval(3600) // 1 hour from now
            )
        ]
    }
    
    /// A single completed task for preview purposes.
    static var previewCompletedTask: ItemTask {
        ItemTask(
            taskName: "Write Report",
            taskDescription: "Submit the annual report to the team",
            isCompleted: true,
            dateCreated: Date().addingTimeInterval(-3600), // 1 hour ago
            taskDueDate: Date()
        )
    }
    
    /// A single incomplete task for preview purposes.
    static var previewIncompleteTask: ItemTask {
        ItemTask(
            taskName: "Schedule Meeting",
            taskDescription: "Set up a team sync for next week",
            isCompleted: false,
            dateCreated: Date(),
            taskDueDate: Date().addingTimeInterval(604800) // 1 week from now
        )
    }
}

// MARK: - SwiftUI Preview Provider

#if DEBUG
/// A preview provider demonstrating the ItemTask model in a SwiftUI view.
struct ItemTask_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section(header: Text("Sample Tasks")) {
                    ForEach(ItemTask.previewTasks) { task in
                        VStack(alignment: .leading) {
                            Text(task.summary)
                                .font(.headline)
                            Text(task.taskDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Created: \(task.relativeDateCreated)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Due: \(task.taskDueDate.formatted(.dateTime))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel(task.accessibilityLabel)
                        .accessibilityHint(task.accessibilityHint)
                    }
                }
            }
            .navigationTitle("Task Preview")
        }
    }
}
#endif

