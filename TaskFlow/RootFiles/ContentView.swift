//
//  ContentView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/24/25.
//

import SwiftUI
import SwiftData



struct ContentView: View {

    var body: some View {
        ItemScreen(itemCategory: .allCases.first!)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
