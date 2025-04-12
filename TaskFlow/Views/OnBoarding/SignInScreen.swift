//
//  SignInScreen.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import AuthenticationServices
import SwiftData

/// The final onboarding screen for TaskFlow2025, allowing users to sign in with Apple.
/// Updates the user’s onboarding status and logs authentication details.
struct SignInScreen: View {
    // MARK: - Properties
    
    /// Accesses the SwiftData model context for user updates
    @Environment(\.modelContext) private var modelContext
    
    /// Detects the color scheme for button styling
    @Environment(\.colorScheme) private var colorScheme
    
    /// Queries the User model to update onboarding status
    @Query private var users: [User]
    
    /// Controls the error alert visibility
    @State private var showErrorAlert: Bool = false
    
    /// Stores the error message for display
    @State private var errorMessage: String = ""
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Title with bold styling
            Text("Sign In to TaskFlow")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(UIColor(Category.today.color).accessibleFontColor)
                .accessibilityLabel("Sign In to TaskFlow")
            
            // Instructional text
            Text("Use Sign in with Apple to get started.")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityLabel("Use Sign in with Apple to get started")
            
            Spacer()
            
            // Sign in with Apple button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    // Configure the authentication request
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    // Handle authentication result
                    switch result {
                    case .success(let authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            let userID = appleIDCredential.user
                            let fullName = appleIDCredential.fullName?.formatted() ?? "Not provided"
                            let email = appleIDCredential.email ?? "Not provided"
                            
                            // Log authentication details
                            print("Sign in with Apple Success:")
                            print("User ID: \(userID)")
                            print("Full Name: \(fullName)")
                            print("Email: \(email)")
                            
                            // Update or create User
                            if let user = users.first {
                                user.appleUserId = userID
                                user.isOnboardingComplete = true
                            } else {
                                let newUser = User(appleUserId: userID, isOnboardingComplete: true)
                                modelContext.insert(newUser)
                            }
                            do {
                                try modelContext.save()
                            } catch {
                                errorMessage = "Failed to save user: \(error.localizedDescription)"
                                showErrorAlert = true
                                print("Save Error: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        errorMessage = "Sign in failed: \(error.localizedDescription)"
                        showErrorAlert = true
                        print("Sign in Error: \(error.localizedDescription)")
                    }
                }
            )
            .frame(maxWidth: 375, minHeight: 50) // Matches HIG touch target
            .padding(.horizontal)
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .accessibilityLabel("Sign in with Apple")
            .accessibilityHint("Tap to sign in using your Apple ID")
            
            Spacer()
        }
        .padding(.vertical, 40)
        .hSpacing(.center)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { showErrorAlert = false }
        } message: {
            Text(errorMessage)
                .accessibilityLabel("Error: \(errorMessage)")
        }
    }
}

// MARK: - Preview

#Preview {
    SignInScreen()
        .modelContainer(for: [User.self])
}
