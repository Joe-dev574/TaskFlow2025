//
//  ItemList.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData


/// A view displaying a scrollable list of items filtered by category
struct ItemList: View {
    // MARK: - Properties
    
    /// SwiftData model context for data operations
    @Environment(\.modelContext) private var context
    
    /// Query to fetch all items from the data store
    @Query private var items: [Item]
    
    /// State tracking the currently selected category tab
    @State private var activeTab: Category = .today
    
    // MARK: - Computed Properties
    
    /// Filters and sorts items based on the active category tab
    private var filteredItems: [Item] {
        let categoryItems = items.filter { $0.category == activeTab.rawValue }
        switch activeTab {
        case .events:
            return categoryItems.sorted { $0.dateDue < $1.dateDue } // Sort by due date
        case .work:
            return categoryItems.sorted { $0.title < $1.title } // Sort alphabetically by title
        case .today:
            return categoryItems.sorted { $0.dateAdded < $1.dateAdded } // Sort by addition date
        case .family:
            return categoryItems.sorted { $0.dateAdded < $1.dateAdded } // Sort by addition date
        case .health:
            return categoryItems.sorted { $0.dateAdded < $1.dateAdded } // Sort by addition date
        case .learn:
            return categoryItems.sorted { $0.dateAdded < $1.dateAdded } // Sort by addition date
        case .bills:
            return categoryItems.sorted { $0.dateDue < $1.dateDue } // Sort by due date
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                // Custom tab bar for category selection
                CustomTabBar(activeTab: $activeTab)
                    .accessibilityLabel("Category selector")
                    .accessibilityHint("Select a category to filter items")
                
                LazyVStack(spacing: 12) {
                    // Category header with playful text for Events
                    Text(activeTab.rawValue + (activeTab == .events ? " Thou Shalt Not Forget!" : " Focus"))
                        .font(.system(.body, design: .serif, weight: .bold))
                        .foregroundColor(.mediumGrey) // Assumes mediumGrey is defined elsewhere
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Current category: \(activeTab.rawValue)")
                    
                    // Item list or empty state
                    if filteredItems.isEmpty {
                        Text("No items in \(activeTab.rawValue)")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
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
                            .accessibilityLabel("View details for \(item.title)") // Brief label for navigation
                            .accessibilityHint("Tap to edit this item")
                        }
                    }
                }
                .accessibilityElement(children: .combine) // Groups content for VoiceOver
                .accessibilityLabel(buildListAccessibilityLabel())
            }
            .navigationTitle("Items") // Adds a title to the navigation bar
        }
    }
    
    // MARK: - Helper Methods
    
    /// Builds an accessibility label summarizing the list content
    private func buildListAccessibilityLabel() -> String {
        if filteredItems.isEmpty {
            return "Item list for \(activeTab.rawValue), currently empty"
        }
        return "Item list for \(activeTab.rawValue), \(filteredItems.count) items"
    }
}

