//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/24/25.
//

import SwiftUI
import SwiftData

/// The main entry point for the TaskFlow2025 app.
/// Configures SwiftData persistence and sets RootView as the entry scene.
@main
struct TaskFlow2025App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Item.self, Note.self, User.self, Tag.self, ItemTask.self, Attachment.self])
    }
}
