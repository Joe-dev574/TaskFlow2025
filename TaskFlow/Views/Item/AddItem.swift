//
//  AddItem.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

/// A view for adding or editing items with category-based color theming and distinct sections
struct AddItem: View {
    // MARK: - Environment Properties
    
    /// Accesses the SwiftData model context for saving items
    @Environment(\.modelContext) private var context
    
    /// Dismisses the current view context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Item Property
    
    /// The optional Item object being edited; nil for new items
    let item: Item?
    
    // MARK: - State Properties
    
    /// The title of the item, required for saving
    @State private var title: String
    
    /// Additional remarks or description for the item
    @State private var remarks: String
    
    /// Date when the item was added (non-editable for new items)
    @State private var dateAdded: Date
    
    /// Due date for the item, editable by the user
    @State private var dateDue: Date
    
    /// Start date for the item, editable for specific categories
    @State private var dateStarted: Date
    
    /// Completion date for the item, optional
    @State private var dateCompleted: Date
    
    /// The category of the item, influencing theming and date options
    @State private var category: Category = .health
    
    /// Triggers a background animation when the category changes
    @State private var categoryAnimationTrigger: Bool = false
    
    /// Controls the visibility of an error alert
    @State private var showErrorAlert: Bool = false
    
    /// Stores the message to display in the error alert
    @State private var errorMessage: String = ""
    
    /// Random tint color for the item
    @State private var tint: TintColor = tints.randomElement()!
    
    // MARK: - Initialization
    
    /// Initializes the view with an optional item to edit, setting default values for new items
    init(item: Item? = nil) {
        self.item = item
        if let item = item {
            _title = State(initialValue: item.title)
            _remarks = State(initialValue: item.remarks)
            _dateAdded = State(initialValue: item.dateAdded)
            _dateDue = State(initialValue: item.dateDue)
            _dateStarted = State(initialValue: item.dateStarted)
            _dateCompleted = State(initialValue: item.dateCompleted)
            _category = State(initialValue: Category(rawValue: item.category) ?? .health)
          
        } else {
            _title = State(initialValue: "")
            _remarks = State(initialValue: "")
            _dateAdded = State(initialValue: .now)
            _dateDue = State(initialValue: .now)
            _dateStarted = State(initialValue: .now)
            _dateCompleted = State(initialValue: .now)
            _category = State(initialValue: .today)
          
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports large text sizes for accessibility
    }
    
    // MARK: - Background View
    
    /// Provides a subtle gradient background with a category-driven animation
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [.gray.opacity(0.02), .gray.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger)
        .onChange(of: category) { _, _ in
            withAnimation {
                categoryAnimationTrigger = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false
                }
            }
        }
    }
    
    // MARK: - Content View
    
    /// Main content with a scrollable form and navigation toolbar
    private var contentView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    remarksSection
                    categorySection
                    datesSection
                }
                .padding()
            }
            .navigationTitle(title.isEmpty ? "New Item" : title)
            .toolbar { toolbarItems }
            .foregroundStyle(calculateContrastingColor(background: category.color))
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage)
                    .font(.system(.body, design: .serif))
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Section Styling Configuration
    
    /// Defines static styling constants for consistent section design
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 12    // Corner radius for rounded sections
        static let padding: CGFloat = 16        // Padding around content
        static let backgroundOpacity: Double = 0.001 // Base opacity for backgrounds
        static let reducedOpacity: Double = backgroundOpacity * 0.25 // Reduced opacity for subtle effects
    }
    
    // MARK: - Content Sections
    
    /// Section for entering the item title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .foregroundStyle(category.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Title Section")
            
            CustomTextEditor(remarks: $title, placeholder: "  Enter title of your item...", minHeight: 35)
                .foregroundStyle(.mediumGrey)
                .padding(8)
                .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
                .accessibilityLabel("Item Title")
                .accessibilityHint("Enter the title of your item here")
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    /// Section for entering item remarks or description
    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief Description")
                .foregroundStyle(category.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Description Section")
            
            CustomTextEditor(remarks: $remarks, placeholder: "  Enter a brief description...", minHeight: 85)
                .foregroundStyle(.mediumGrey)
                .padding(8)
                .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
                .accessibilityLabel("Item Description")
                .accessibilityHint("Enter a brief description of your item here")
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    //MARK: Section for selecting the item category
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundStyle(category.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Category Section")
            
            LabeledContent {
                CategorySelector(
                    selectedCategory: $category,
                    animateColor: .constant(category.color),
                    animate: .constant(false)
                )
                .foregroundStyle(.primary)
                .accessibilityLabel("Category Selector")
                .accessibilityHint("Choose a category for your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.4), lineWidth: 1)
        )
    }
    
    //MARK:  Section for displaying and editing item dates
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .foregroundStyle(category.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Dates Section")
            
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
                .accessibilityLabel("Created on \(dateAdded.formatted(.dateTime))")
                
                datePickersForCategory()
            }
            .padding(8)
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.4), lineWidth: 1)
        )
    }
    
    // MARK: - Toolbar Items
    
    /// Configures the navigation toolbar with cancel and save actions
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticsManager.notification(type: .success)
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(category.color)
                }
                .accessibilityLabel("Cancel")
                .accessibilityHint("Tap to dismiss without saving changes")
            }
            ToolbarItem(placement: .principal) {
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(category.color)
                .accessibilityLabel("Save Item")
                .accessibilityHint("Tap to save your item")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves the item to the model context and dismisses the view
    private func save() {
        let newItem = Item(
                    title: title,
                    remarks: remarks,
                    dateAdded: dateAdded,
                    dateDue: dateDue,
                    dateStarted: dateStarted,
                    dateCompleted: dateCompleted,
                    category: category,
                    tintColor: tint
                )
        context.insert(newItem)
        do {
            try context.save()
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    /// Displays date pickers based on the selected category
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        VStack(spacing: 12) {
            LabeledContent {
                DatePicker("", selection: $dateDue)
                    .labelsHidden()
                    .font(.system(.caption, design: .serif))
            } label: {
                Text("Due")
                    .font(.system(.body, design: .serif))
            }
            .foregroundStyle(.mediumGrey)
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
            
            if category == .today || category == .work {
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
    
    /// Calculates the relative luminance of a color for contrast determination
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
    
    /// Determines the most contrasting color (white or black) for a background using WCAG AAA contrast ratio
    private func calculateContrastingColor(background: Color) -> Color {
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 7 && whiteContrast >= blackContrast ? .white : .black
    }
}

// MARK: - Preview
#Preview {
    AddItem()
}
