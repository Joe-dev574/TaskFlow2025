//
//  ItemListScreen.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

struct ItemListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("themeChoice") private var themeChoice = "Light"
    @AppStorage("selectedColor") private var selectedColorData = Color.blue.toHex() ?? "#0000FF"
    @State private var showAddItemSheet = false
    @State private var showTaskListSheet = false
    @State private var currentDate = Date()
    @State var itemCategory: Category
    private var selectedColor: Color { Color(hex: selectedColorData) }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ItemList()
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollContentBackground(.hidden)

                addItemButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerLastTextBaseline)
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddItem()
                    .presentationDetents([.medium])
            }
            .toolbar(content: toolbarContent)
            .toolbarBackground(.clear, for: .navigationBar)
        }
    }

    private var addItemButton: some View {
        Button(action: {
            showAddItemSheet = true
        }) {
            Image(systemName: "plus")
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: 45, height: 45)
                .background(.darkBlue)
                .shadow(radius: 3)
                .clipShape(Circle())
        }
        .offset(x: 0, y: -20)
        .padding()
        .accessibilityLabel("Add New Item")
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gear")
                    .font(.title)
                    .foregroundStyle(.color1)
                    .padding(.bottom, 2)
            }
            .accessibilityLabel("Settings")
        }
        ToolbarItem(placement: .principal) {
            VStack(alignment: .leading, spacing: 2) {
                Text(currentDate.format("MMMM YYYY"))
                    .font(.title2.bold())
                    .foregroundStyle(.color1)//blue
                Text(currentDate.format("EEEE, d"))
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 7)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle")
                    .font(.title)
                    .foregroundStyle(.color1)
            }
            .accessibilityLabel("Profile")
        }
    }
}

#Preview {
    ItemListScreen(itemCategory: .events)
        .modelContainer(for: [Item.self, ItemTask.self])
}
