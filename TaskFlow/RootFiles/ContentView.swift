//
//  ContentView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/24/25.
//

import SwiftUI
import SwiftData

/// The main app view displayed after onboarding completion in TaskFlow2025.
/// Shows a list of tasks or a placeholder if none exist, with an option to reset onboarding.
struct ContentView: View {
    // MARK: - Properties
    
    /// Accesses the SwiftData model context for data operations
    @Environment(\.modelContext) private var modelContext
    
    /// Queries all items (tasks) for display
    @Query private var items: [Item]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
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
                    // App title
                    Text("TaskFlow")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                        .accessibilityLabel("Task Flow App")
                    
                    // Task list or placeholder
                    if items.isEmpty {
                        Text("No tasks yet.")
                            .font(.system(size: 18, design: .serif))
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("No tasks available")
                            .accessibilityHint("Add tasks to populate the list")
                    } else {
                        List(items) { item in
                            HStack {
                                Image(systemName: Category(rawValue: item.category)?.symbolImage ?? "questionmark")
                                    .foregroundStyle(Category(rawValue: item.category)?.color ?? .gray)
                                    .accessibilityLabel("Category: \(Category(rawValue: item.category)?.accessibilityLabel ?? "Unknown")")
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.system(.body, design: .serif))
                                        .accessibilityLabel("Task: \(item.title)")
                                    
                                    Text(item.remarks)
                                        .font(.system(.caption, design: .serif))
                                        .foregroundStyle(.secondary)
                                        .accessibilityLabel("Remarks: \(item.remarks)")
                                }
                            }
                            .accessibilityElement(children: .combine)
                        }
                        .accessibilityLabel("Task List")
                        .accessibilityHint("Lists all your tasks with categories and details")
                    }
                    
                    Spacer()
                    
                    // Reset onboarding button (for testing)
                    Button("Reset Onboarding") {
                        if let user = try? modelContext.fetch(FetchDescriptor<User>()).first {
                            modelContext.delete(user)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to reset onboarding: \(error.localizedDescription)")
                            }
                        }
                    }
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 20)
                    .accessibilityLabel("Reset Onboarding")
                    .accessibilityHint("Tap to restart the onboarding process")
                }
            }
            .navigationTitle("Tasks")
            .accessibilityLabel("Tasks Navigation")
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports Dynamic Type scaling
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, User.self])
}
