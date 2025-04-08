//
//  TextOnlyLogoView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

/// A simplified logo view featuring only the text, optimized for both light and dark modes.
struct TextOnlyLogoView: View {
    // MARK: - Environment
    
    /// Detects the current color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Constants.textSpacing) {
            Text("Task")
                .font(.system(.body, design: .serif)) // Larger, bold font
                .foregroundStyle(.taskColor11.gradient)
                .offset(y: 0)  // Centered
            
            Text("Flow")
                .fontWeight(.bold)// Larger, extra bold font
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(textGradient)
                .offset(x: -5, y: 3)  // Centered
            
            Text("0.1")
                .font(.custom("Avenir-Medium", size: 18))  // Slightly larger, lighter weight for version
                .foregroundStyle(versionColor.gradient)
                .rotationEffect(.degrees(0))  // No tilt
                .offset(x: 0)  // Centered
        }
        .padding()
        .background(backgroundOverlay)  // Subtle backdrop
        .cornerRadius(7)
        .shadow(color: shadowColor, radius: 6)  // Enhanced text shadow
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily Grind version 1.0")
        .padding(.vertical, 10)  // Adds vertical breathing room
        .frame(maxHeight: Constants.maxHeight)  // Constrains height
    }
    
    // MARK: - Adaptive Styling
    
    /// Gradient for text, optimized for readability
    private var textGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [.white.opacity(0.9), .gray.opacity(0.7)]  // High contrast
                : [.black.opacity(0.9), .gray.opacity(0.8)], // Subtle in light
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Color for the version number, mode-specific
    private var versionColor: Color {
        colorScheme == .dark ? .yellow.opacity(0.9) : .orange.opacity(0.9)
    }
    
    /// Shadow color with mode-appropriate opacity
    private var shadowColor: Color {
        colorScheme == .dark ? .gray.opacity(0.4) : .gray.opacity(0.2)
    }
    
    /// Background overlay for contrast enhancement
    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
            .shadow(color: shadowColor, radius: 6)
    }
    
    // MARK: - Constants
    
    /// Static values used throughout the view
    private enum Constants {
        static let textSpacing: CGFloat = 8         // Increased space between text elements
        static let maxHeight: CGFloat = 60          // Increased maximum height of the logo
    }
}

// MARK: - Preview

/// Previews the text-only logo in both light and dark modes
#Preview {
    VStack {
        TextOnlyLogoView()
            .preferredColorScheme(.light)
        TextOnlyLogoView()
            .preferredColorScheme(.dark)
    }
    .padding()
    .background(Color(.systemBackground))
}
