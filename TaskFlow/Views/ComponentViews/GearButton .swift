//
//  GearButton .swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

/// A stylized gear button that animates on appearance and navigates to settings when tapped
struct GearButtonView: View {
    // MARK: - Properties
    
    /// Angle for gear rotation animation
    @State private var rotationAngle: Double = 0.0
    
    /// Opacity of the gear icon
    @State private var gearOpacity: Double = Constants.initialGearOpacity
    
    /// Scale factor for the gear icon
    @State private var gearScale: Double = 1.0
    
    /// Intensity of the glow effect
    @State private var glowIntensity: Double = 0.3
    
    /// Tracks when the initial animation sequence completes
    @State private var isAnimationComplete: Bool = false
    
    /// Environment variable to adapt to light/dark mode
    @Environment(\.colorScheme) var colorScheme
    
    /// Controls navigation to the settings view
    @State private var showSettings: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Image(systemName: "gearshape.2.fill")
                .resizable()
                .frame(width: Constants.gearSize, height: Constants.gearSize)
                .foregroundStyle(
                    LinearGradient(
                        colors: gearGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(gearOpacity)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(gearScale)
                .shadow(color: glowColor, radius: 2, x: 0, y: 1)
                .overlay(
                    Circle()
                        .stroke(glowColor, lineWidth: 1)
                        .scaleEffect(gearScale * 1.2)
                        .opacity(glowIntensity)
                        .shadow(color: .black, radius: 5, x: 2, y: 2)
                )
                .padding(4)
                .shadow(color: isAnimationComplete ? .primary : .clear, radius: 1, x: 1, y: 1)
                .frame(maxHeight: Constants.maxHeight)
                .background(backgroundOverlay)
                .onAppear(perform: startAnimation)
                .accessibilityLabel(isAnimationComplete ? "Settings button" : "Settings button, animating")
                .accessibilityHint("Double tap to open settings")
                .onTapGesture {
                    if isAnimationComplete {
                        showSettings = true
                        HapticsManager.notification(type: .success)
                    }
                }
                .navigationDestination(isPresented: $showSettings) {
                    SettingsView()
                }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Gradient colors for the gear, adjusted for color scheme
    private var gearGradientColors: [Color] {
        colorScheme == .dark
            ? [.cyan.opacity(0.25), .purple.opacity(0.7)]
            : [.blue, .cyan.opacity(0.15)]
    }
    
    /// Glow color with intensity, adapted to color scheme
    private var glowColor: Color {
        colorScheme == .dark ? .cyan.opacity(glowIntensity) : .blue.opacity(glowIntensity)
    }
    
    /// Shadow color, adjusted for color scheme
    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.6) : .gray.opacity(0.7)
    }
    
    /// Background overlay with adaptive opacity and shadow
    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colorScheme == .dark ? Color.black.opacity(isAnimationComplete ? 0.9 : 0.6) : Color.white.opacity(isAnimationComplete ? 0.9 : 0.6))
            .shadow(color: shadowColor, radius: isAnimationComplete ? 6 : 4)
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let gearSize: CGFloat = 35
        static let initialGearOpacity: Double = 1.0
        static let finalGearOpacity: Double = 0.95 // Slightly dimmed for resting state
        static let fastDuration: Double = 0.5
        static let slowDuration: Double = 0.2
        static let fadeDuration: Double = 0.15
        static let pulseDuration: Double = 1.0
        static let slowRotations: Double = 1.25
        static let maxHeight: CGFloat = 40
    }
    
    // MARK: - Animation
    
    /// Starts the multi-stage animation sequence on appearance
    private func startAnimation() {
        // Initial rotation and scale up
        withAnimation(.easeInOut(duration: Constants.fastDuration)) {
            rotationAngle = 360 * Constants.slowRotations
            gearScale = 1.15
            glowIntensity = 0.1
        }
        
        // Bounce back with spring effect
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration) {
            withAnimation(.spring(response: Constants.slowDuration, dampingFraction: 0.7)) {
                rotationAngle = 360 * Constants.slowRotations + 10
                gearScale = 0.97
                glowIntensity = 0.0
            }
        }
        
        // Fade to final opacity and normalize scale
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration) {
            withAnimation(.easeInOut(duration: Constants.fadeDuration)) {
                gearOpacity = Constants.finalGearOpacity
                gearScale = 1.0
            }
        }
        
        // Pulse effect after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration + Constants.fadeDuration) {
            isAnimationComplete = true
            withAnimation(.easeInOut(duration: Constants.pulseDuration).repeatForever(autoreverses: true)) {
                gearScale = 1.05
                glowIntensity = 0.3 // Subtle glow pulse
            }
        }
    }
}

// MARK: - Preview

/// Previews the gear button in light and dark modes within a navigation context
#Preview {
    NavigationStack {
        VStack(spacing: 20) {
            GearButtonView()
                .preferredColorScheme(.light)
                .padding()
            
            GearButtonView()
                .preferredColorScheme(.dark)
                .padding(4)
        }
        .navigationTitle("Gear Button Demo")
    }
}
