//
//  SignInScreen.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import AuthenticationServices
import SwiftData

struct SignInScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @Binding var currentPage: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In to TaskFlow")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(UIColor(Category.today.color).accessibleFontColor)
                .accessibilityLabel("Sign In to TaskFlow")

            Text("Use Sign in with Apple to get started.")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityLabel("Use Sign in with Apple to get started")

            Spacer() // Pushes content up, button will be pinned to bottom

            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let authResults):
                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                let userID = appleIDCredential.user
                                let fullName = appleIDCredential.fullName?.formatted() ?? "Not provided"
                                let email = appleIDCredential.email ?? "Not provided"

                                print("Sign in with Apple Success: UserID=\(userID), FullName=\(fullName), Email=\(email)")

                                do {
                                    let fetchDescriptor = FetchDescriptor<User>()
                                    if let user = try modelContext.fetch(fetchDescriptor).first {
                                        user.appleUserId = userID
                                        user.isOnboardingComplete = true
                                    } else {
                                        let newUser = User(appleUserId: userID, isOnboardingComplete: true)
                                        modelContext.insert(newUser)
                                    }
                                    try modelContext.save()
                                    print("SignInScreen: User saved successfully")
                                    currentPage = Int.max // Exit to ItemScreen
                                } catch {
                                    errorMessage = "Failed to save user: \(error.localizedDescription)"
                                    showErrorAlert = true
                                    print("SignInScreen: Save Error: \(error)")
                                }
                            }
                        case .failure(let error):
                            errorMessage = "Sign in failed: \(error.localizedDescription)"
                            showErrorAlert = true
                            print("SignInScreen: Sign in Error: \(error)")
                        }
                    }
                }
            )
            .frame(width: 325, height: 50)
            .padding(.horizontal)
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .accessibilityLabel("Sign in with Apple")
            .accessibilityHint("Tap to sign in using your Apple ID")
        }
        .padding(.vertical, 40)
        .padding(.bottom, 30) // Positions button 30pt from bottom
        .hSpacing(.center)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { showErrorAlert = false }
        } message: {
            Text(errorMessage)
                .accessibilityLabel("Error: \(errorMessage)")
        }
    }
}

#Preview {
    SignInScreen(currentPage: .constant(2))
        .modelContainer(for: [User.self])
}
