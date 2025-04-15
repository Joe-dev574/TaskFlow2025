//
//  LogoView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI




struct LogoView: View {
    // MARK: - Animation States
    
    /// The opacity level of the gear
    @State private var gearOpacity: Double = Constants.initialGearOpacity
    
    /// The scale factor for the gear's pulse animation
    @State private var gearScale: Double = 1.0
    
    /// The vertical offset for text bounce animation
    @State private var textOffset: CGFloat = 0.0
    
    /// The intensity of the gear's glow effect
    @State private var glowIntensity: Double = 0.3
    
    // MARK: - Environment
    
    /// Detects the current color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
    /// Respects the user's reduced motion preference
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            // Gear icon
            Image(systemName: "gearshape.2.fill")
                .resizable()
                .tint(.darkBlue)
                .frame(width: 40, height: 40)
                .accessibilityHint("Part of the Task Flow logo")
            
            // Text group with dynamic styling
            HStack(spacing: Constants.textSpacing) {
                Text("Task")
                    .font(.custom("Avenir-Heavy", size: 18))
                    .foregroundStyle(.lightGrey)
                    .offset(y: textOffset)
                
                Text("Flow")
                    .font(.custom("Avenir-Black", size: 18))
                    .foregroundStyle(.lightBlue )
                    .offset(y: -textOffset)
                
                Text("1.0")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(versionColor)
                    .rotationEffect(.degrees(15))
                    .offset(x: 2)
            }
            .shadow(color: shadowColor, radius: 2)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Task Flow version 1.0")
            .accessibilityHint("App logo and version")
        }
        .padding(.vertical, 8)
        .frame(maxHeight: Constants.maxHeight)
 //       .background(backgroundOverlay)
    }
    
    // MARK: - Adaptive Styling
    
    /// Gradient colors for the gear, adjusted for color scheme
    private var gearGradientColors: [Color] {
        colorScheme == .dark
        ? [.cyan.opacity(0.7), .purple.opacity(0.5)]
        : [.blue.opacity(0.7), .cyan.opacity(0.5)]
    }
    
    /// Color for the version number, mode-specific
    private var versionColor: Color {
        colorScheme == .dark ? .yellow.opacity(0.9) : .orange.opacity(0.9)
    }
    
    /// Glow color that adapts to the color scheme
    private var glowColor: Color {
        colorScheme == .dark ? .cyan.opacity(glowIntensity) : .blue.opacity(glowIntensity)
    }
    
    /// Shadow color with mode-appropriate opacity
    private var shadowColor: Color {
        colorScheme == .dark ? .gray.opacity(0.5) : .gray.opacity(0.3)
    }
    
    /// Background overlay for contrast enhancement
    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
            .shadow(color: shadowColor, radius: 3)
    }
    
    // MARK: - Constants
    
    /// Static values used throughout the view
    private enum Constants {
        static let gearSize: CGFloat = 32
        static let initialGearOpacity: Double = 1.0
        static let finalGearOpacity: Double = 0.85
        static let spacing: CGFloat = 6
        static let textSpacing: CGFloat = 3
        static let maxHeight: CGFloat = 40
    }
        }
// MARK: - Preview

#Preview {
    VStack {
        LogoView()
            .preferredColorScheme(.light)
        
        LogoView()
            .preferredColorScheme(.dark)
    }
    .padding()
    .background(Color(.systemBackground))
}
