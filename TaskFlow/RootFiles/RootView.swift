//
//  RootView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if let user = try? modelContext.fetch(FetchDescriptor<User>()).first, user.isOnboardingComplete {
                ItemListScreen(itemCategory: .today) // Default category
                    .accessibilityLabel("Main Task Flow App")
                    .accessibilityHint("Displays your tasks, projects, and notes")
            } else {
                OnboardingView()
                    .accessibilityLabel("Task Flow Onboarding")
                    .accessibilityHint("Guides you through the app’s features and sign-in")
                    .onAppear {
                        let fetchDescriptor = FetchDescriptor<User>()
                        if (try? modelContext.fetch(fetchDescriptor).isEmpty) ?? true {
                            let newUser = User()
                            modelContext.insert(newUser)
                            do {
                                try modelContext.save()
                                print("RootView: New user created and saved")
                            } catch {
                                print("RootView: Failed to save new user: \(error)")
                            }
                        }
                    }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [User.self, Item.self, Note.self])
}
