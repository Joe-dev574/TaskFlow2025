//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/24/25.
//

import SwiftUI

@main
struct TaskFlowApp: App {
    var body: some Scene {
        WindowGroup {
            IntroScreen()
                .modelContainer(for: [Item.self, Note.self, User.self, Tag.self, ItemTask.self, Attachment.self])
        }
    }
}
