//
//  ItemCard.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

/// A professional card view for an Item, displaying title, category, dates, remarks, tags, and metrics.
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
    
    private var noteCount: Int {
        item.notes?.count ?? 0
    }
    
    private var taskCount: Int {
        item.itemTasks?.count ?? 0
    }
    
    private var completedTaskCount: Int {
        item.itemTasks?.filter { $0.isCompleted }.count ?? 0
    }
    
    // MARK: - Body
    var body: some View {
        SwipeAction(cornerRadius: 12, direction: .trailing) {
            VStack(alignment: .leading, spacing: 12) {
                headerSection
                titleSection
                datesSection
                remarksSection
                tagsSection
                metricsSection
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .shadow(radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(buildAccessibilityLabel())
            .accessibilityHint("Swipe right to delete")
        } actions: {
            Action(tint: .red, icon: "trash", action: {
                context.delete(item)
            })
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        HStack {
            Spacer()
            Text(item.category)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(category.color)
                )
        }
    }
    
    private var titleSection: some View {
        HStack(spacing: 12) {
            Image(systemName: category.symbolImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(category.color)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                )
            Text(item.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
    
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if item.dateAdded != .distantPast {
                dateRow(
                    icon: "calendar",
                    text: "Added: \(item.dateAdded.formatted(.dateTime.day().month(.wide).year()))",
                    color: .gray
                )
            }
            if item.dateDue != .distantPast {
                dateRow(
                    icon: "clock",
                    text: "Due: \(item.dateDue.formatted(.dateTime.day().month(.wide).year()))",
                    color: isOverdue ? .red : .green
                )
            }
        }
    }
    
    private var remarksSection: some View {
        Group {
            if !item.remarks.isEmpty {
                Text(item.remarks)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.vertical, 2)
            }
        }
    }
    
    private var tagsSection: some View {
        Group {
            if let tags = item.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags) { tag in
                            Text(tag.name)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(tag.hexColor)
                                )
                        }
                    }
                }
            }
        }
    }
    
    private var metricsSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "note.text")
                    .font(.system(size: 12))
                Text("\(noteCount)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 12))
                Text("\(completedTaskCount)/\(taskCount)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            Spacer()
        }
        .foregroundStyle(category.color)
        .padding(.top, 4)
    }
    
    // MARK: - Helper Methods
    private func dateRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(color)
        }
    }
    
    private func buildAccessibilityLabel() -> String {
        var tagsString: String {
            guard let tags = item.tags else { return "" }
            return tags.isEmpty ? "" : ", Tags: \(tags.map { $0.name }.joined(separator: ", "))"
        }
        
        var label = "Item: \(item.title), Category: \(item.category)"
        if item.dateAdded != .distantPast {
            label += ", Added on \(item.dateAdded.formatted(.dateTime.day().month(.wide).year()))"
        }
        if item.dateDue != .distantPast {
            label += ", Due on \(item.dateDue.formatted(.dateTime.day().month(.wide).year()))"
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
