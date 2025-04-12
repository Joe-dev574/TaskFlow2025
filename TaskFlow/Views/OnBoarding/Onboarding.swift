//
//  OnBoardingView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import SwiftData

/// Orchestrates the onboarding flow for TaskFlow2025, guiding users through welcome, feature introduction, and sign-in.
/// Switches between views based on the current page state, ensuring a seamless experience.
struct OnboardingView: View {
    // MARK: - Properties
    
    /// Accesses the SwiftData model context for user data operations
    @Environment(\.modelContext) private var modelContext
    
    /// Tracks the current onboarding page (0: Welcome, 1: Intro, 2: Sign-in)
    @State private var currentPage: Int = 0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Subtle gradient background for visual consistency
            LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.02), .gray.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .accessibilityHidden(true) // Background is decorative
            
            // Switch between onboarding screens based on currentPage
            switch currentPage {
            case 0:
                WelcomeScreen(currentPage: $currentPage)
                    .accessibilityLabel("Welcome Screen")
                    .accessibilityHint("Introduces TaskFlow and offers to start or skip onboarding")
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling
            case 1:
                IntroScreen(currentPage: $currentPage)
                    .accessibilityLabel("Features Screen")
                    .accessibilityHint("Showcases TaskFlow’s key features")
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            case 2:
                SignInScreen()
                    .accessibilityLabel("Sign-in Screen")
                    .accessibilityHint("Allows signing in with Apple")
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            default:
                EmptyView()
                    .accessibilityHidden(true) // Fallback case, not user-facing
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .modelContainer(for: [User.self])
}
