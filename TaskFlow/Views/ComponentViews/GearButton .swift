//
//  GearButton .swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct GearButtonView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            Image(systemName: "gearshape.2.fill")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundStyle(
                    LinearGradient(
                        colors: gearGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.95)
                .shadow(color: glowColor, radius: 2, x: 0, y: 1)
                .padding(4)
                .background(backgroundOverlay)
                .accessibilityLabel("Settings button")
                .accessibilityHint("Double tap to open settings")
        }
    }

    private var gearGradientColors: [Color] {
        colorScheme == .dark
            ? [.cyan.opacity(0.25), .purple.opacity(0.7)]
            : [.blue, .cyan.opacity(0.15)]
    }

    private var glowColor: Color {
        colorScheme == .dark ? .cyan.opacity(0.3) : .blue.opacity(0.3)
    }

    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colorScheme == .dark ? Color.black.opacity(0.9) : Color.white.opacity(0.9))
            .shadow(color: colorScheme == .dark ? .black.opacity(0.6) : .gray.opacity(0.7), radius: 6)
    }
}

#Preview {
    NavigationStack {
        GearButtonView()
            .preferredColorScheme(.light)
            .padding()
    }
}
