//
//  IntroScreen.swift
//  TaskFlow Onboarding
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI

struct IntroScreen: View {
    @State private var isVisible = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                LogoView()
                    .frame(width: 250, height: 50)
                    .accessibilityLabel("Task Flow logo")
                
                // Simplified graphics (static, no loops)
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
                    .accessibilityLabel("Task creation feature")
                
                Spacer()
                
                NavigationLink {
                    OnboardingView() 
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .accessibilityLabel("Get Started")
                .accessibilityHint("Tap to sign in")
            }
            .padding()
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    isVisible = true
                }
            }
        }
    }
}
