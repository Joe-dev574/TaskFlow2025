//
//  
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

/// A button representing a category with dynamic styling based on selection state.
/// Used in category selectors or tab bars within DailyGrind0.2.
struct CategoryButton: View {
    // MARK: - Properties
    
    /// The category this button represents
    let category: Category
    
    /// Indicates if this category is currently selected
    let isSelected: Bool
    
    /// Action to perform when the button is tapped
    let onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text(category.rawValue.uppercased())
                .font(.system(.body, design: .serif))
                .fontWeight(.regular)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(category.color.opacity(isSelected ? 0.9 : 0.45).gradient)
                )
                .padding(4)
                .foregroundStyle(isSelected ? .white : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(category.color, lineWidth: isSelected ? 3 : 0) // Fixed from .remark
                )
                .onTapGesture(perform: onTap)
                .accessibilityLabel("Category: \(category.rawValue)")
                .accessibilityHint(isSelected ? "Currently selected category" : "Tap to select this category")
                .accessibilityAddTraits(.isButton)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }
}

// MARK: - Preview

/// Preview provider for CategoryButton in selected and unselected states
#Preview {
    VStack {
        CategoryButton(category: .today, isSelected: true, onTap: { print("Tapped Today") })
        CategoryButton(category: .work, isSelected: false, onTap: { print("Tapped Work") })
    }
    .padding()
}

