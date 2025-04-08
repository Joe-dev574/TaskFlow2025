//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/24/25.
//

import SwiftUI
import SwiftData

/// The main entry point for the DailyGrind0.2 app.
/// Configures SwiftData persistence and defines the root scene.
@main
struct DailyGrind_ProtoApp: App {
    /// Shared SwiftData model container for persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            ItemTask.self, // Added to match modelContainer usage
            Tag.self       // Added for completeness with relationships
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView() // Assumes ContentView exists as the root view
        }
        .modelContainer(sharedModelContainer) // Updated to use shared container
    }
}
