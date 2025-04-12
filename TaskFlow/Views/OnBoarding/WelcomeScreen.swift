//
//  WelcomeScreen.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI

/// The initial onboarding screen for TaskFlow2025, introducing the app and offering to start or skip the process.
/// Displays a logo, title, tagline, and navigation buttons with smooth animations.
struct WelcomeScreen: View {
    // MARK: - Properties
    
    /// Binding to the current onboarding page, controlling navigation
    @Binding var currentPage: Int
    
    /// Tracks animation state for a smooth entrance
    @State private var isAnimating: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Subtle gradient background for visual polish
            LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.02), .gray.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .accessibilityHidden(true) // Decorative background
            
            VStack(spacing: 25) {
                // Animated logo
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Category.today.color)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .animation(.easeInOut(duration: 0.6).delay(0.2), value: isAnimating)
                    .accessibilityLabel("Task Flow Logo")
                
                // Title with slide-up animation
                Text("Welcome to TaskFlow")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.primary)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                    .accessibilityLabel("Welcome to TaskFlow")
                
                // Tagline with fade-in
                Text("Streamline your tasks, projects, and notes effortlessly.")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.6).delay(0.6), value: isAnimating)
                    .accessibilityLabel("Streamline your tasks, projects, and notes effortlessly")
                
                Spacer()
                
                // Get Started button with glowing border
                Button(action: {
                    withAnimation {
                        currentPage = 1 // Navigate to IntroScreen
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Category.today.color)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Category.today.color.opacity(0.5), lineWidth: 2)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeInOut(duration: 0.8).delay(0.8), value: isAnimating)
                        )
                }
                .accessibilityLabel("Get Started")
                .accessibilityHint("Tap to begin exploring TaskFlow")
                
                // Skip button with fade-in
                Button(action: {
                    withAnimation {
                        currentPage = 2 // Navigate to SignInScreen
                    }
                }) {
                    Text("Skip")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(.gray)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeIn(duration: 0.6).delay(1.0), value: isAnimating)
                }
                .accessibilityLabel("Skip Onboarding")
                .accessibilityHint("Tap to skip to sign in")
            }
            .padding(.vertical, 40)
            .hSpacing(.center)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling
            .onAppear {
                isAnimating = true // Triggers animations
            }
        }
    }
}
// MARK: - Preview

#Preview {
    WelcomeScreen(currentPage: .constant(0))
}
