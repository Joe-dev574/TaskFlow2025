//
//  TagRowView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct TagRowView: View {
    let tag: Tag
    @Bindable var item: Item
    let itemCategory: Category
    let onTap: (Tag) -> Void
    
    var body: some View {
        Button(action: {
            onTap(tag)
        }) {
            HStack {
                CreativeTag(label: tag.name, tagColor: tag.hexColor) // Use tag.hexColor instead of tagColor
            }
            .padding(TagView.Style.padding)
            .background(Color("LightGrey").opacity(TagView.Style.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: TagView.Style.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: TagView.Style.cornerRadius)
                    .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
