//
//  User.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftData

/// A SwiftData model representing a user’s onboarding status for TaskFlow2025.
/// Stores whether the user has completed onboarding and their Apple ID for sign-in.
@Model
final class User {
    // MARK: - Properties
    
    /// The user’s Apple ID, used for Sign in with Apple authentication.
    /// Optional since it’s set post-sign-in.
    var appleUserId: String?
    
    /// Indicates whether the user has completed the onboarding flow.
    /// Defaults to false until sign-in is complete.
    var isOnboardingComplete: Bool
    
    // MARK: - Initialization
    
    /// Creates a new User instance with optional Apple ID and onboarding status.
    /// - Parameters:
    ///   - appleUserId: The user’s Apple ID, if available (default: nil).
    ///   - isOnboardingComplete: Whether onboarding is complete (default: false).
    init(appleUserId: String? = nil, isOnboardingComplete: Bool = false) {
        self.appleUserId = appleUserId
        self.isOnboardingComplete = isOnboardingComplete
    }
}

