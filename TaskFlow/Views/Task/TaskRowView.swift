//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

/// Enum defining events that can occur within a task row
enum TaskRowEvent {
    case toggleCompletion
}

/// A view representing a single task row, designed for clarity and interactivity
struct TaskRowView: View {
    // MARK: - Environment Properties
    
    /// Provides access to the SwiftData model context for task operations
    @Environment(\.modelContext) private var modelContext
    
    /// Detects the current color scheme (light or dark) for adaptive styling
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Properties
    
    /// The task data to display in the row
    let itemTask: ItemTask
    
    /// Callback function to handle task events like toggling completion
    let onEvent: (TaskRowEvent) -> Void
    
    /// Tracks the completion state of the task
    @State private var checked: Bool = false
    
    /// Tracks hover state for platforms supporting it (e.g., macOS)
    @State private var isHovered: Bool = false
    
    // MARK: - Date Formatting
    
    /// Formats a date into a concise, readable string tailored for serif display
    private func formatItemTaskDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        if date.isToday {
            return "Today"
        } else if date.isYesterday {
            return "Yesterday"
        } else if date.isTomorrow {
            return "Tomorrow"
        } else {
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Adaptive Styling
    
    /// Determines the foreground color based on task completion and hover interaction
    private var taskForegroundStyle: Color {
        if checked {
            return .gray.opacity(0.8) // Dimmed when completed
        } else if isHovered {
            return .blue.opacity(0.9) // Highlighted on hover
        } else {
            return .primary // Default state, adapts to light/dark mode
        }
    }
    
    /// Calculates due date color to reflect urgency or completion status
    private var dueDateColor: Color {
        let today = Date()
        if checked {
            return .gray // Completed tasks are neutral
        } else if itemTask.taskDueDate < today {
            return .red.opacity(0.8) // Overdue tasks in red
        } else if itemTask.taskDueDate.isToday || itemTask.taskDueDate.isTomorrow {
            return .orange.opacity(0.8) // Upcoming tasks in orange
        } else {
            return .gray // Future tasks in gray
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background with subtle depth and shadow for visual hierarchy
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.inSelectedCategory)) // TODO: Verify this color is defined in assets
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            HStack {
                // Toggle button for marking task completion with spring animation
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        checked.toggle()
                        onEvent(.toggleCompletion)
                    }
                }) {
                    Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(checked ? .green : .gray.opacity(0.5))
                        .scaleEffect(checked ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: checked)
                }
                .padding(.leading, 4)
                .buttonStyle(.plain)
                .accessibilityLabel(checked ? "Completed" : "Not completed")
                .accessibilityHint("Double-tap to toggle task completion")
                .accessibilityAddTraits(.isButton)
                
                // Task details organized in a vertical stack for readability
                VStack(alignment: .leading) {
                    // Task name, prominently displayed with serif font
                    Text(itemTask.taskName)
                        .font(.system(size: 20, design: .serif))
                        .foregroundStyle(taskForegroundStyle)
                        .fontWeight(.semibold)
                        .strikethrough(checked, color: .gray)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 7)
                        .padding(.bottom, 2)
                    
                    // Optional task description with serif font, shown if not empty
                    if !itemTask.taskDescription.isEmpty {
                        Text(itemTask.taskDescription)
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(checked ? .gray.opacity(0.7) : .secondary)
                            .strikethrough(checked, color: .gray)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 7)
                            .padding(.bottom, 8)
                    }
                    
                    // Compact date display with creation and due dates
                    VStack(alignment: .leading) {
                        HStack {
                            // Creation date label and value
                            Text("Created: ")
                                .font(.system(.caption2, design: .serif))
                                .foregroundStyle(.mediumGrey)
                            Label(formatItemTaskDate(itemTask.dateCreated), systemImage: "calendar")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(.gray)
                                .padding(.horizontal, -10)
                            
                            Spacer()
                            
                            // Due date label and value with dynamic color
                            Text("Due: ")
                                .font(.system(.caption2, design: .serif))
                                .foregroundStyle(.mediumGrey)
                            Label(formatItemTaskDate(itemTask.taskDueDate), systemImage: "clock")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(dueDateColor)
                                .padding(.horizontal, -10)
                            Spacer()
                        }
                    }
                }
                .padding(2)
            }
            .padding(.vertical, 10)
        }
        .onAppear {
            checked = itemTask.isCompleted // Sync with initial completion state on load
        }
        .onChange(of: itemTask.isCompleted) { _, newValue in
            checked = newValue // Update state if task completion changes externally
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering // Apply hover effect for supported platforms
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Task: \(itemTask.taskName), \(checked ? "completed" : "not completed"), Due: \(formatItemTaskDate(itemTask.taskDueDate))")
        .accessibilityHint("Double-tap to toggle task completion")
    }
}

// MARK: - Preview

/// Preview for testing the view in Xcode with a sample task
#Preview {
    TaskRowView(
        itemTask: ItemTask(
            taskName: "Sample Task",
            taskDescription: "This is a sample task description.",
            isCompleted: false,
            dateCreated: Date(),
            taskDueDate: Date().addingTimeInterval(86400)
        ),
        onEvent: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
