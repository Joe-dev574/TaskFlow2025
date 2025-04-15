//
//  OnBoardingView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import AuthenticationServices

struct Onboarding: View {
    var body: some View {
        VStack {
            Text("Sign in to TaskFlow")
                .font(.title)
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                // Handle authentication
            }
            .frame(height: 50)
            .padding()
        }
    }
}
