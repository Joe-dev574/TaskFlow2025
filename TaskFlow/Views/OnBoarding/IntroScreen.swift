//
//  IntroScreen.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI
import UIKit // For haptics

/// Displays a feature introduction screen for TaskFlow2025 onboarding, animating key app functionalities.
/// Shows a logo, title, and a grid of feature blocks that settle into place, with navigation to sign-in.
struct IntroScreen: View {
    // MARK: - Properties
    
    /// Binding to the current onboarding page, controlling navigation
    @Binding var currentPage: Int
    
    /// Tracks the animation phase for feature blocks (initial, rotate, settle)
    @State private var animationPhase: AnimationPhase = .initial
    
    /// Controls visibility of the Next button and logo/title animations
    @State private var showNextButton: Bool = false
    
    /// Defines the features to display with titles, symbols, and colors
    private let features: [(title: String, symbol: String, color: Color)] = [
        ("Create Tasks", "checkmark.circle", Category.today.color),
        ("Create Projects", "folder.badge.plus", Category.work.color),
        ("Categorize", "square.grid.2x2", Category.family.color),
        ("Tags", "tag", Category.health.color),
        ("Notes", "note.text", Category.learn.color),
        ("Attachments", "paperclip", Category.bills.color),
        ("Export", "square.and.arrow.up", Category.events.color)
    ]
    
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
            .accessibilityHidden(true) // Decorative background
            
            VStack(spacing: 20) {
                // Logo and "Explore" title, delayed until blocks settle
                if animationPhase == .settle {
                    VStack(spacing: 8) {
                        Text("Explore")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundStyle(.black)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
                            .overlay(
                                LinearGradient(
                                    colors: [.black, .gray.opacity(0.7), .black],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(Text("Explore")
                                    .font(.system(size: 32, weight: .bold, design: .serif)))
                            )
                            .accessibilityLabel("Explore Task Flow")
                        
                        LogoView()
                            .frame(width: 250, height: 50)
                            .accessibilityLabel("Task Flow logo")
                    }
                    .opacity(showNextButton ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: showNextButton)
                } else {
                    Spacer().frame(height: 82) // Placeholder for logo/title
                }
                
                // Feature blocks in a 2-column grid
                ZStack {
                    ForEach(features.indices, id: \.self) { index in
                        FeatureView(
                            title: features[index].title,
                            symbol: features[index].symbol,
                            color: features[index].color,
                            phase: animationPhase,
                            index: index,
                            totalFeatures: features.count
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(features[index].title)
                    }
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
                .offset(y: animationPhase == .settle ? -200 : 0) // Raised 200pt
                
                Spacer()
                
                // Next button, 80pt from bottom
                if showNextButton {
                    Button(action: {
                        withAnimation {
                            currentPage = 2 // Navigate to SignInScreen
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 325, minHeight: 50)
                            .padding(.horizontal, 24)
                            .background(Category.today.color)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Category.today.color.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.bottom, 20)
                    .accessibilityLabel("Next")
                    .accessibilityHint("Tap to proceed to sign in")
                    .transition(.opacity)
                }
            }
            .hSpacing(.center)
            .padding(.bottom, 20) // Safe area padding
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling
        }
        .onAppear {
            // Animation sequence for feature blocks
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                animationPhase = .rotate
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    animationPhase = .settle
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showNextButton = true
                }
            }
        }
    }
    
    // MARK: - Animation Phase
    
    /// Defines the animation stages for feature blocks
    enum AnimationPhase {
        case initial, rotate, settle
    }
}

// MARK: - Feature View

/// A subview representing a single feature block with animated positioning.
struct FeatureView: View {
    // MARK: - Properties
    
    let title: String
    let symbol: String
    let color: Color
    let phase: IntroScreen.AnimationPhase
    let index: Int
    let totalFeatures: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.white)
        }
        .padding()
        .frame(width: 180, height: 90)
        .background(color.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .offset(calculateOffset())
        .scaleEffect(phase == .initial ? 0.8 : 1.0)
        .zIndex(phase == .settle ? Double(totalFeatures - index) : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8).delay(Double(index) * 0.05), value: phase)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling
    }
    
    // MARK: - Helpers
    
    /// Calculates the offset for each block based on animation phase
    private func calculateOffset() -> CGSize {
        let screenHeight = UIScreen.main.bounds.height
        let baseSpacing = screenHeight / 8
        
        switch phase {
        case .initial:
            switch index {
            case 0: return CGSize(width: -200, height: -200)
            case 1: return CGSize(width: 200, height: -200)
            case 2: return CGSize(width: -150, height: -100)
            case 3: return CGSize(width: 150, height: -100)
            case 4: return CGSize(width: -150, height: 100)
            case 5: return CGSize(width: 150, height: 100)
            case 6: return CGSize(width: 0, height: 200)
            default: return .zero
            }
        case .rotate:
            return CGSize(width: 0, height: CGFloat(index - (totalFeatures - 1) / 2) * baseSpacing)
        case .settle:
            let row = index / 2
            let col = index % 2
            return CGSize(width: index == 6 ? 0 : (col == 0 ? -100 : 100), height: CGFloat(row) * baseSpacing)
        }
    }
}

// MARK: - Preview

#Preview {
    IntroScreen(currentPage: .constant(1))
        .modelContainer(for: [User.self])
}
