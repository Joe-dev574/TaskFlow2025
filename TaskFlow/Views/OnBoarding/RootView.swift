//
//  RootView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import SwiftData

/// A view that determines whether to display the onboarding flow or the main app content based on user state.
/// This serves as the root entry point for the TaskFlow2025 app, checking if onboarding is complete.
struct RootView: View {
    // MARK: - Properties
    
    /// Accesses the SwiftData model context for saving user data
    @Environment(\.modelContext) private var modelContext
    /// Queries the User model to check onboarding status
    @Query private var users: [User]
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let user = users.first, user.isOnboardingComplete {
                // Show main app content if onboarding is complete
                ContentView()
                    .accessibilityLabel("Main Task Flow App")
                    .accessibilityHint("Displays your tasks, projects, and notes")
            } else {
                // Show onboarding flow if no user or onboarding incomplete
                OnboardingView()
                    .accessibilityLabel("Task Flow Onboarding")
                    .accessibilityHint("Guides you through the app’s features and sign-in")
                    .onAppear {
                        // Ensure a User exists to track onboarding state
                        if users.isEmpty {
                            let newUser = User()
                            modelContext.insert(newUser)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save new user: \(error.localizedDescription)")
                            }
                        }
                    }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling up to xxxLarge
    }
}

// MARK: - Preview

#Preview {
    RootView()
        .modelContainer(for: [User.self, Item.self, Note.self])
}
