//
//  OnBoardingView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage: Int = 0

    var body: some View {
        if currentPage == Int.max {
            ItemScreen(itemCategory: .today)
                .transition(.opacity)
                .accessibilityLabel("Main Task Flow App")
                .accessibilityHint("Displays your tasks, projects, and notes")
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.gray.opacity(0.02), .gray.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .accessibilityHidden(true)

                switch currentPage {
                case 0:
                    WelcomeScreen(currentPage: $currentPage)
                        .accessibilityLabel("Welcome Screen")
                        .accessibilityHint("Introduces TaskFlow and offers to start or skip onboarding")
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                case 1:
                    IntroScreen(currentPage: $currentPage)
                        .accessibilityLabel("Features Screen")
                        .accessibilityHint("Showcases TaskFlow’s key features")
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                case 2:
                    SignInScreen(currentPage: $currentPage)
                        .accessibilityLabel("Sign-in Screen")
                        .accessibilityHint("Allows signing in with Apple")
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                default:
                    EmptyView()
                        .accessibilityHidden(true)
                }

//                VStack {
//                    HStack {
//                        Spacer()
//                        Button("Skip") {
//                            do {
//                                let fetchDescriptor = FetchDescriptor<User>()
//                                if let user = try modelContext.fetch(fetchDescriptor).first {
//                                    user.isOnboardingComplete = true
//                                } else {
//                                    let newUser = User(appleUserId: nil, isOnboardingComplete: true)
//                                    modelContext.insert(newUser)
//                                }
//                                try modelContext.save()
//                                print("OnboardingView: Skip - User saved successfully")
//                                currentPage = Int.max
//                            } catch {
//                                print("OnboardingView: Skip - Failed to save user: \(error)")
//                            }
//                        }
//                        .padding()
//                        .accessibilityLabel("Skip onboarding")
//                        .accessibilityHint("Bypasses onboarding and goes to the main app")
//                    }
//                    Spacer()
//                }
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [User.self])
}
