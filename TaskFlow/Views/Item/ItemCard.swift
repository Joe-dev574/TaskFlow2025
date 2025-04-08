//
//  ItemCard.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

/// A view that displays a card representation of an `Item` with its details and metrics for notes and tasks
struct ItemCardView: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    let item: Item
    
    // MARK: - Computed Properties
    private var category: Category {
        Category(rawValue: item.category) ?? .today
    }
    
    private var isOverdue: Bool {
        Date.now > item.dateDue && !item.isCompleted()
    }
    
    // Assuming Item has these properties
    private var noteCount: Int {
        item.notes?.count ?? 0  // Adjust based on your Item model
    }
    
    private var taskCount: Int {
        item.itemTasks?.count ?? 0  // Adjust based on your Item model
    }
    
    private var completedTaskCount: Int {
        item.itemTasks?.filter { $0.isCompleted }.count ?? 0  // Adjust based on your ItemTask model
    }
    
    // MARK: - Body
    var body: some View {
        SwipeAction(cornerRadius: 12, direction: .trailing) {
            ZStack {
                backgroundLayer
                contentLayer
                metricsOverlay
            }
            .overlay(borderOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(buildAccessibilityLabel())
            .accessibilityHint("Swipe right to delete this item")
        } actions: {
            Action(tint: .red, icon: "trash", action: {
                context.delete(item)
            })
        }
    }
    
    // MARK: - View Components
    private var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        category.color.opacity(0.1),
                        category.color.opacity(0.02),
                        category.color.opacity(0.04),
                        .black.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Color.gray.opacity(0.02)
                    .blendMode(.overlay)
            )
            .shadow(color: category.color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 12) {
            categoryHeader(for: item, category: category, colorScheme: colorScheme)
            titleSection
            datesSection
            remarksSection
            tagsSection
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Metrics Overlay
    private var metricsOverlay: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "note.text")
                    .font(.system(size: 12))
                Text("\(noteCount)")
                    .font(.system(size: 12, weight: .medium, design: .serif))
            }
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 12))
                Text("\(completedTaskCount)/\(taskCount)")
                    .font(.system(size: 12, weight: .medium, design: .serif))
            }
        }
        .foregroundStyle(category.color.opacity(0.9))
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(category.color.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Notes: \(noteCount), Tasks: \(completedTaskCount) completed out of \(taskCount)")
    }
    
    // MARK: - Category Header Function
    private func categoryHeader(for item: Item, category: Category, colorScheme: ColorScheme) -> some View {
        HStack {
            Spacer()
            Text(item.category)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .font(.system(size: 13, weight: .bold, design: .serif))
                .foregroundStyle(colorScheme == .dark ? .lightGrey : .white)
                .background(
                    Capsule()
                        .fill(categoryGradient(for: category, colorScheme: colorScheme))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    colorScheme == .dark ? .darkGrey : category.color.opacity(0.2),
                                    lineWidth: colorScheme == .dark ? 1.5 : 1
                                )
                        )
                        .shadow(color: category.color.opacity(colorScheme == .dark ? 0.3 : 0.5), radius: 4, x: 0, y: 2)
                )
                .accessibilityLabel("Category: \(item.category)")
                .padding(.top, 8)
        }
    }
    
    // MARK: - Dynamic Gradient for Category
    private func categoryGradient(for category: Category, colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                category.color.opacity(colorScheme == .dark ? 0.8 : 1.0),
                category.color.opacity(colorScheme == .dark ? 0.4 : 0.6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Other View Components (Unchanged)
    private var titleSection: some View {
        HStack(spacing: 12) {
            Image(systemName: category.symbolImage)
                .font(.system(size: 20, weight: .semibold))
                .padding(3)
                .foregroundStyle(.lightGrey)
                .frame(width: 35, height: 35)
                .background(
                    Circle()
                        .fill(.inSelectedCategory)
                        .overlay(
                            Capsule()
                                .strokeBorder(category.color.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: category.color.opacity(0.5), radius: 4, x: 0, y: 2)
                )
                .accessibilityLabel("Category: \(item.category)")
                .padding(.top, 8)
            
            Text(item.title)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(category.color.opacity(0.95))
                .lineLimit(1)
                .accessibilityLabel("Title: \(item.title)")
        }
    }
    
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if item.dateAdded != .distantPast {
                dateRow(
                    icon: "calendar",
                    text: "Added: \(item.dateAdded.formatted(.dateTime.day().month().year()))",
                    color: .mediumGrey
                )
            }
            if item.dateDue != .distantPast {
                dateRow(
                    icon: "clock",
                    text: "Due: \(item.dateDue.formatted(.dateTime.day().month().year()))",
                    color: isOverdue ? .red : Color.green.darker(by: 0.3)
                )
            }
        }
        .font(.system(size: 16, design: .serif))
        .padding(.horizontal, 4)
        .padding(.bottom, 15)
    }
    
    private var remarksSection: some View {
        Group {
            if !item.remarks.isEmpty {
                Text(item.remarks)
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(.primary.opacity(0.9))
                    .padding(.vertical, 4)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 7)
                    .lineLimit(3)
                    .accessibilityLabel("Remarks: \(item.remarks)")
            }
        }
    }
    
    private var tagsSection: some View {
        Group {
            if let tags = item.tags, !tags.isEmpty {
                ViewThatFits {
                    TagsStackView(tags: tags)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags) { tag in
                                Text(tag.name)
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 4)
                                    .background(
                                        tag.hexColor
                                            .shadow(.inner(color: .black.opacity(0.2), radius: 2))
                                    )
                                    .clipShape(Capsule())
                                    .accessibilityLabel("Tag: \(tag.name)")
                            }
                            .padding(.bottom, 4)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tags: \(tags.map { $0.name }.joined(separator: ", "))")
            }
        }
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                LinearGradient(
                    colors: [category.color, .white.opacity(0.3), .white.opacity(0.2)],
                    startPoint: .topTrailing,
                    endPoint: .topTrailing
                ),
                lineWidth: 2
            )
    }
    
    // MARK: - Helper Methods
    private func dateRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
    
    private func buildAccessibilityLabel() -> String {
        var tagsString: String {
            guard let tags = item.tags else { return "" }
            return tags.isEmpty ? "" : ", Tags: \(tags.map { $0.name }.joined(separator: ", "))"
        }
        
        var label = "Item: \(item.title), Category: \(item.category)"
        if item.dateAdded != .distantPast {
            label += ", Added on \(item.dateAdded.formatted(.dateTime.day().month().year()))"
        }
        if item.dateDue != .distantPast {
            label += ", Due on \(item.dateDue.formatted(.dateTime.day().month().year()))"
            label += isOverdue ? ", Overdue" : ", On time"
        }
        if !item.remarks.isEmpty {
            label += ", Remarks: \(item.remarks)"
        }
        label += tagsString
        label += ", Notes: \(noteCount), Tasks: \(completedTaskCount) completed out of \(taskCount)"
        return label
    }
}

// MARK: - Color Extension
extension Color {
    func darker(by percentage: Double) -> Color {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        return Color(
            red: max(0, Double(components[0]) * (1 - percentage)),
            green: max(0, Double(components[1]) * (1 - percentage)),
            blue: max(0, Double(components[2]) * (1 - percentage)),
            opacity: Double(components[3])
        )
    }
}

