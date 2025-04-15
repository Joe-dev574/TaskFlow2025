//
//  CustomTabBar.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var activeTab: Category
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Category.allCases, id: \.rawValue) { tab in
                Button(action: { activeTab = tab }) {
                    HStack(spacing: 4) {
                        Image(systemName: tab.symbolImage)
                            .font(.system(size: 16))
                        if activeTab == tab {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(activeTab == tab ? .white : .gray)
                    .padding(.vertical, 6)
                    .padding(.horizontal, activeTab == tab ? 12 : 8)
                    .background(activeTab == tab ? tab.color : Color.gray.opacity(0.1))
                    .clipShape(Capsule())
                }
                .accessibilityLabel("Select \(tab.rawValue)")
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
    }
}

#if DEBUG
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(activeTab: .constant(.events))
    }
}
#endif
