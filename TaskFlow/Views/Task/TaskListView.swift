//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

/// A view that displays a list of tasks for an item, with options to add, edit, and delete tasks
struct TaskListView: View {
    // MARK: - Properties
    
    /// Environment property to access the SwiftData model context for saving and deleting tasks
    @Environment(\.modelContext) private var modelContext
    
    /// Binding to the item's tasks, allowing updates to the task list
    @Binding var itemTasks: [ItemTask]
    
    /// The category of the item, used for styling and theming (immutable, so using let)
    let itemCategory: Category
    
    /// Binding to the blur state of the parent view, notifying when the sheet is shown or dismissed
    @Binding var isBlurred: Bool
    
    /// State variables for managing the add/edit task sheet and tracking list height
    @State private var showingAddTask = false
    @State private var taskToEdit: ItemTask?
    @State private var taskListHeight: CGFloat = 0
    
    // MARK: - Section Styling Configuration
    
    /// Struct containing constants for styling the task list sections
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 10    // Corner radius for rounded sections
        static let padding: CGFloat = 16        // Padding around content
        static let backgroundOpacity: Double = 0.01 // Base opacity for backgrounds
        static let reducedOpacity: Double = backgroundOpacity * 0.30 // Reduced opacity for subtle effects
    }
    
    // MARK: - Initialization
    
    /// Custom initializer to set up the task list binding, category, and blur state
    init(itemTasks: Binding<[ItemTask]>, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._itemTasks = itemTasks
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    // MARK: - Preference Key for Height Measurement
    
    /// PreferenceKey to measure the height of the task list content dynamically
    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    // MARK: - Body
    
    /// Main view body, containing the task list header and content
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Header with "Tasks" title and Add Task button
            HStack {
                Text("Tasks")
                    .foregroundStyle(itemCategory.color)
                    .font(.system(size: 18, design: .serif))
                    .fontWeight(.bold)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .accessibilityLabel("Tasks Header")
                    .accessibilityHint("List of tasks for this item")
                
                Spacer()
                
                Button(action: {
                    taskToEdit = nil
                    showingAddTask = true
                    isBlurred = true // Notify parent view to apply blur
                    HapticsManager.notification(type: .success) // Haptic feedback for interaction
                }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(itemCategory.color)
                        .padding(7)
                        .background(itemCategory.color.opacity(0.2))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add Task")
                .accessibilityHint("Tap to add a new task to this item")
            }
            
            // Content based on whether there are tasks
            if itemTasks.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("Task bin is empty", systemImage: "list.bullet.rectangle")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(.gray)
                    },
                    description: {
                        Text("Add a new task by tapping the plus (+) button above.")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(.gray)
                    }
                )
                .accessibilityLabel("No tasks available")
                .accessibilityHint("Tap the Add Task button to create a new task")
            } else {
                List {
                    ForEach(itemTasks.indices, id: \.self) { index in
                        TaskRowView(itemTask: itemTasks[index]) { event in
                            handleTaskRowEvent(event, for: itemTasks[index])
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                        .swipeActions(edge: .leading) {
                            Button {
                                taskToEdit = itemTasks[index]
                                showingAddTask = true
                                isBlurred = true // Notify parent view to blur
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .font(.system(.body, design: .serif))
                            }
                            .tint(.blue)
                            .accessibilityLabel("Edit Task")
                            .accessibilityHint("Swipe left and tap to edit this task")
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteTask(itemTasks[index])
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .font(.system(.body, design: .serif))
                            }
                            .accessibilityLabel("Delete Task")
                            .accessibilityHint("Swipe right and tap to delete this task")
                        }
                    }
                }
                .padding(4)
                .listStyle(.plain)
                .frame(minHeight: 250, maxHeight: 1000)
                .accessibilityLabel("Task List")
                .accessibilityHint("Contains a list of tasks for this item")
            }
        }
        .sheet(isPresented: $showingAddTask, onDismiss: {
            isBlurred = false // Reset blur when sheet is dismissed
        }) {
            TaskFormView(taskToEdit: $taskToEdit, itemCategory: .constant(itemCategory), onSave: { newTask in
                if let taskToEdit = taskToEdit, let index = itemTasks.firstIndex(where: { $0 === taskToEdit }) {
                    // Update existing task
                    itemTasks[index] = newTask
                } else {
                    // Add new task
                    itemTasks.append(newTask)
                    modelContext.insert(newTask)
                }
            })
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Methods
    
    /// Handles events from TaskRowView, such as toggling task completion
    private func handleTaskRowEvent(_ event: TaskRowEvent, for task: ItemTask) {
        switch event {
        case .toggleCompletion:
            task.toggleCompletion()
            saveContext()
        }
    }
    
    /// Deletes a task from the list and the model context
    private func deleteTask(_ task: ItemTask) {
        if let index = itemTasks.firstIndex(where: { $0 === task }) {
            itemTasks.remove(at: index)
        }
        modelContext.delete(task)
        saveContext()
    }
    
    /// Saves changes to the model context if there are any modifications
    private func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
                print("TaskListView: Context saved successfully")
            } else {
                print("TaskListView: No changes to save in context")
            }
        } catch {
            print("TaskListView: Failed to save context: \(error.localizedDescription)")
            // Optionally, show an alert to the user here
        }
    }
}

// MARK: - Preview
#Preview {
    TaskListView(
        itemTasks: .constant([]),
        itemCategory: .work,
        isBlurred: .constant(false)
    )
}
