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
            ItemListScreen(itemCategory: .today)
     //           .transition(.opacity)
                .accessibilityLabel("Main Task Flow App")
                .accessibilityHint("Displays your tasks, projects, and notes")
        } else {
                    IntroScreen(currentPage: $currentPage)
                        .accessibilityLabel("Features Screen")
                        .accessibilityHint("Showcases TaskFlow’s key features")
                }
            }
      
        }
