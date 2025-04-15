//
//  IntroScreen.swift
//  TaskFlow Onboarding
//
//  Created by Joseph DeWeese on 4/11/25.
//

import SwiftUI


struct IntroScreen: View {
    @Binding var currentPage: Int
    
    private let features: [(title: String, symbol: String, color: Color)] = [
        ("Create Projects", "folder.badge.plus", Category.work.color),
        ("Organize with Categories", "square.grid.2x2", Category.family.color),
        ("Tags", "tag", Category.health.color),
        ("Notes", "note.text", Category.learn.color),
        ("Attach Files", "paperclip", Category.bills.color),
        ("Export Reports", "square.and.arrow.up", Category.events.color)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Explore")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
                .accessibilityLabel("Explore Task Flow")
            
            LogoView()
                .frame(width: 250, height: 50)
                .accessibilityLabel("Task Flow logo")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(features.indices, id: \.self) { index in
                    FeatureView(
                        title: features[index].title,
                        symbol: features[index].symbol,
                        color: features[index].color
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(features[index].title)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                currentPage = 2
                print("next tapped/introscreen")
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: 325, minHeight: 50)
                    .padding(.horizontal, 24)
                    .background(.color1)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.bottom, 20)
            .accessibilityLabel("Next")
            .accessibilityHint("Tap to proceed to sign in")
        }
        .padding(.bottom, 20)
    }
}

struct FeatureView: View {
    let title: String
    let symbol: String
    let color: Color
    
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
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
