//
//  ItemList.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData

struct ItemList: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Item> { $0.category == "Today" }, sort: \Item.dateDue, order: .forward) private var items: [Item]
    @State private var activeTab: Category = .today
    private let categories: [Category] = [.today, .events, .work, .family, .bills]

    private var filteredItems: [Item] {
        let categoryItems = items.filter { $0.category == activeTab.rawValue }
        switch activeTab {
        case .events: return categoryItems.sorted { $0.dateDue < $1.dateDue }
        case .work: return categoryItems.sorted { $0.title < $1.title }
        case .today: return categoryItems.sorted { $0.dateAdded < $1.dateAdded }
        case .family: return categoryItems.sorted { $0.dateDue < $1.dateDue }
        case .bills: return categoryItems.sorted { $0.title < $1.title }
        default: return categoryItems.sorted { $0.dateAdded < $1.dateAdded }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyHStack {
                    Picker("Category", selection: $activeTab) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .accessibilityLabel("Category selector")
                    .accessibilityHint("Select a category to filter items")
                }
                
                LazyVStack(spacing: 12) {
                    Text(activeTab.rawValue + (activeTab == .events ? " Thou Shalt Not Forget!" : " Focus"))
                        .font(.system(.body, design: .serif, weight: .bold))
                        .foregroundStyle(.mediumGrey)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Current category: \(activeTab.rawValue)")
                    
                    if filteredItems.isEmpty {
                        Text("No items in \(activeTab.rawValue)")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(.gray)
                            .padding(.top, 20)
                            .accessibilityLabel("No items available in \(activeTab.rawValue) category")
                    } else {
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                ItemEditView(editItem: item)
                            } label: {
                                ItemCardView(item: item)
                                    .padding(.horizontal, 12)
                            }
                            .accessibilityLabel("View details for \(item.title)")
                            .accessibilityHint("Tap to edit this item")
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(buildListAccessibilityLabel())
            }
        }
    }

    private func buildListAccessibilityLabel() -> String {
        if filteredItems.isEmpty {
            return "Item list for \(activeTab.rawValue), currently empty"
        }
        return "Item list for \(activeTab.rawValue), \(filteredItems.count) items"
    }
}
