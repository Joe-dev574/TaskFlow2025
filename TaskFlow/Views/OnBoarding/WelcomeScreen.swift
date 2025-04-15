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
    
  
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 35) {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.color1)
                    .accessibilityLabel("Task Flow Logo")
                
                Text("Welcome to TaskFlow")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Welcome to TaskFlow")
                
             
                Text("Streamline your tasks, projects, and notes effortlessly.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityLabel("Streamline your tasks, projects, and notes effortlessly")
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    print("get started button tapped")
                        currentPage = 1 // Navigate to IntroScreen
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(.color1)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.color1, lineWidth: 2)

                        )
                }
                .accessibilityLabel("Get Started")
                .accessibilityHint("Tap to begin exploring TaskFlow")
                
                // Skip button with fade-in
                Button(action: {
                    print(" button pressed-welcome screen")
                        currentPage = 2 // Navigate to SignInScreen
                }) {
                    Text("Skip")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)
                     
                }
                .accessibilityLabel("Skip Onboarding")
                .accessibilityHint("Tap to skip to sign in")
            }
            .padding(.vertical, 40)
            .hSpacing(.center)
         
        }
    }
}
// MARK: - Preview

#Preview {
    WelcomeScreen(currentPage: .constant(0))
}
