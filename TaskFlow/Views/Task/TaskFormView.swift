//
//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

struct TaskFormView: View {
    // MARK: - Environment Properties
        
        /// Dismisses the current view context
        @Environment(\.dismiss) private var dismiss
        
        /// Provides access to the SwiftData model context for task persistence
        @Environment(\.modelContext) private var modelContext
        
        // MARK: - Binding Properties
        
        /// The task being edited, if any; nil for new tasks
        @Binding var taskToEdit: ItemTask?
        
        /// The category of the item, used for theming
        @Binding var itemCategory: Category
        
        // MARK: - Callback Properties
        
        /// Closure to notify the parent view when a task is saved
        var onSave: (ItemTask) -> Void
        
        // MARK: - State Properties
        
        /// Date when the task was added (non-editable for new tasks)
        @State private var dateAdded: Date = Date.now
        
        /// Due date for the task, editable by the user
        @State private var dateDue: Date = Date.now
        
        /// Start date for the task, editable for specific categories
        @State private var dateStarted: Date = Date.now
        
        /// Name of the task, required for saving
        @State private var taskName: String = ""
        
        /// Description of the task, optional
        @State private var taskDescription: String = ""
        
        // MARK: - Computed Properties
        
        /// Indicates whether the form is editing an existing task or creating a new one
        private var isEditing: Bool {
            taskToEdit != nil
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                contentView
            }
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)// Supports large text sizes for accessibility
        }
    }
    
    // MARK: - Background View
    /// Provides a subtle gradient background for visual depth
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .gray.opacity(0.02),
                .gray.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Content View
        
        /// Main form content with navigation and toolbar
    private var contentView: some View {
        NavigationStack {
            Form {
                VStack(spacing: 5) {
                    titleSection
                    taskDescriptionSection
                    datesSection
                }
                .padding(7)
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        HapticsManager.notification(type: .success)
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(.callout, design: .serif))
                            .foregroundStyle(itemCategory.color)
                    }
                }
                ToolbarItem(placement: .principal) {
                    TextOnlyLogoView()
                        .padding(.horizontal)
                        .accessibilityLabel("App Logo")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        saveOrUpdateTask()
                        dismiss()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    .tint(itemCategory.color)
                    .accessibilityLabel("Save Changes")
                    .accessibilityHint("Tap to save your edited item.")
                }
            }
            .foregroundStyle(calculateContrastingColor(background: itemCategory.color))
            .onAppear {
                if let task = taskToEdit {
                    taskName = task.taskName
                    taskDescription = task.taskDescription
                    // Optionally update other fields like dates if they’re editable
                    dateDue = task.taskDueDate
                    print("taskToEdit appeared")
                }
            }
        }
    }
    
    // MARK: - Section Styling Configuration
        
        /// Defines static styling constants for consistent form design
        private struct SectionStyle {
            static let cornerRadius: CGFloat = 10    // Corner radius for rounded sections
            static let padding: CGFloat = 5         // Padding around content
            static let backgroundOpacity: Double = 0.001 // Base opacity for backgrounds
            static let reducedOpacity: Double = backgroundOpacity * 0.25 // Reduced opacity for subtle effects
        }
        
    // MARK: - Content Sections
        
        /// Section for entering the task title
        private var titleSection: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Title")
                    .font(.system(size: 16, design: .serif))
                    .fontWeight(.bold)
                    .foregroundStyle(itemCategory.color)
                
                CustomTextEditor(remarks: $taskName, placeholder: "   Enter name task...", minHeight: 35)
                    .padding(5)
                    .foregroundStyle(.mediumGrey)
                // Note: Update CustomTextEditor to use .font(.system(size: 16, design: .serif)) if editable
                    .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
                    .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
            }
            .padding(2)
            .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                    .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
            )
        }
    /// Section for entering the task description
        private var taskDescriptionSection: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Brief Description")
                    .font(.system(size: 16, design: .serif))
                    .fontWeight(.bold)
                    .foregroundStyle(itemCategory.color)
                
                CustomTextEditor(remarks: $taskDescription, placeholder: "   Enter brief description...", minHeight: 85)
                    .foregroundStyle(.mediumGrey)
                    .padding(8)
                // Note: Update CustomTextEditor to use .font(.system(size: 16, design: .serif)) if editable
                    .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
                    .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
            }
            .padding(SectionStyle.padding)
            .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                    .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
            )
        }
    // MARK:  Section for displaying and editing task dates
        private var datesSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dates")
                    .font(.system(size: 16, design: .serif))
                    .fontWeight(.bold)
                    .foregroundStyle(itemCategory.color)
                
                VStack(spacing: 8) {
                    LabeledContent {
                        Text(dateAdded.formatted(.dateTime))
                            .font(.system(.callout, design: .serif))
                            .padding(.trailing, 50)
                    } label: {
                        Text("Created")
                            .font(.system(.body, design: .serif))
                    }
                    .foregroundStyle(.mediumGrey)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Created \(dateAdded.formatted(.dateTime))")
                }
                .padding(4)
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
                
                datePickersForCategory()
            }
            .padding(SectionStyle.padding)
            .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                    .stroke(itemCategory.color.opacity(0.4), lineWidth: 2)
            )
        }
    // MARK: - Save Methods
    /// Saves a new task or updates an existing one, then triggers the onSave callback
    private func saveOrUpdateTask() {
        let task: ItemTask
        if let existingTask = taskToEdit {
            existingTask.updateTaskName(taskName) // Updates the task name
            existingTask.taskDescription = taskDescription // Updates the description
            task = existingTask
        } else {
            task = ItemTask(taskName: taskName, taskDescription: taskDescription) // Creates a new task
            modelContext.insert(task) // Adds it to the SwiftData context
        }
        saveContext() // Persists changes to the data store
        onSave(task) // Notifies the parent view of the saved task
    }
   // MARK: - Save Context
        
    /// Persists changes to the model context if modifications exist
    private func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
                print("TaskFormView: Context saved successfully")
            } else {
                print("TaskFormView: No changes to save in context")
            }
        } catch {
            print("TaskFormView: Failed to save context: \(error.localizedDescription)")
        }
    }
    // MARK: - Date Pickers
        
        /// Displays date pickers for due and start dates based on category
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        VStack(spacing: 12) {
            LabeledContent {
                DatePicker("", selection: $dateDue)
                    .labelsHidden()
                    .font(.system(.callout, design: .serif))
            } label: {
                Text("Due")
                    .font(.system(.body, design: .serif))
            }
            .foregroundStyle(.mediumGrey)
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
            
            if itemCategory == .today || itemCategory == .work {
                LabeledContent {
                    DatePicker("", selection: $dateStarted)
                        .labelsHidden()
                        .font(.system(.callout, design: .serif))
                } label: {
                    Text("Start")
                        .font(.system(.body, design: .serif))
                }
                .foregroundStyle(.mediumGrey)
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
            }
        }
    }
    // MARK: - Color Contrast Calculation
    private func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    /// Computes the contrast ratio between two luminance values
    private func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2), darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Determines the most contrasting color (white or black) for a given background, using WCAG AAA contrast ratio of 7
    private func calculateContrastingColor(background: Color) -> Color {
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 4.5 && whiteContrast >= blackContrast ? .white : .black
    }
}
