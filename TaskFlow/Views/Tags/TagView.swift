//
//  TagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

/// A view for selecting existing tags or creating new ones for an item
struct TagView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Tag.name) var tags: [Tag]
    @Bindable var item: Item
    let itemCategory: Category
    @State private var showNewTag = false
    
    // MARK: - Styling Configuration
    struct Style {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 7
        static let backgroundOpacity: Double = 0.01
        static let reducedOpacity: Double = backgroundOpacity * 0.30
    }
    
    init(item: Item, itemCategory: Category) {
        self._item = Bindable(item)
        self.itemCategory = itemCategory
    }
    
    var body: some View {
        NavigationStack {
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                TagSelectionList(item: item, itemCategory: itemCategory, showNewTag: $showNewTag)
            }
            .background(itemCategory.color.opacity(Style.reducedOpacity))
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            //Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(itemCategory.color)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(itemCategory.color)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: Style.cornerRadius)
                                    .stroke(itemCategory.color, lineWidth: 2)
                                    .opacity(item.tags?.isEmpty ?? true ? 0.3 : 1.0)
                            )
                    }
                    .disabled(item.tags?.isEmpty ?? true)
                }
            }
            .sheet(isPresented: $showNewTag) {
                NewTagView(item: item, itemCategory: itemCategory)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .tint(itemCategory.color)
    }
}

