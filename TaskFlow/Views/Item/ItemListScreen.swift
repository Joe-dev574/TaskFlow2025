//
//  ItemListScreen.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftData
import SwiftUI

/// A view displaying a list of items with a fixed toolbar for navigation and actions
struct ItemScreen: View {
    // MARK: - Environment and State Properties
    // MARK: - Environment and State Properties
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("themeChoice") private var themeChoice = "Light"
    @AppStorage("selectedColor") private var selectedColorData = Color.blue.toHex() ?? "#0000FF"
    @State private var showAddItemSheet: Bool = false  // Toggles the add item sheet visibility
    @State private var showTaskListSheet: Bool = false
    @State private var currentDate: Date = Date()  // Tracks current date for header display
    @State var itemCategory: Category
    private var selectedColor: Color {
        Color(hex: selectedColorData)
    }
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {  // Use ZStack to layer content and button
                ScrollView {  // Isolate scrolling to ItemList
                    VStack(alignment: .leading, spacing: 0) {
                        ItemList()  // Displays the list of items
                            .padding(.top, 10)  // Add padding to avoid overlap with toolbar
                    }
                    .frame(maxWidth: .infinity)  // Ensure full width
                }
                .scrollContentBackground(.hidden)  // Optional: hide default scroll background

                addItemButton  // Floating action button pinned to bottom-right
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .centerLastTextBaseline)
            }
            .blur(radius: showAddItemSheet ? 8 : 0)  // Blurs content when sheet is active
            .sheet(isPresented: $showAddItemSheet) {  // Presents sheet for adding new items
                AddItem()
                    .presentationDetents([.large])
            }
            .toolbar { toolbarItems }  // Configures fixed toolbar
            .toolbarBackground(.visible, for: .navigationBar)  // Ensures toolbar background stays visible
            .navigationBarTitleDisplayMode(.inline)  // Keeps toolbar compact and pinned
        }
    }
    
    // MARK: - Subviews
    /// Floating button to trigger the add item sheet
    private var addItemButton: some View {
        Button(action: {
            showAddItemSheet = true
            HapticsManager.notification(type: .success)  // Provides haptic feedback on tap
        }) {
            Image(systemName: "plus")
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: 45, height: 45)
                .background(selectedColor.gradient)  // Use itemCategory.color
                .shadow(radius: 5, x: 5, y: 5)
                .clipShape(Circle())
                
        }
        .offset(x: 0, y: -20)////control height of add item button for future  reference of a bottom tab bar
        .padding()  // Adds padding around button
        .accessibilityLabel("Add New Item")
    }

    //MARK: Custom header view for the toolbar
    @ViewBuilder
    private func headerView() -> some View {
        HStack(spacing: 8) {  // Reduced crowding with tighter spacing
            VStack(alignment: .leading, spacing: 2) {  // Compact vertical stack for date
                Text(currentDate.format("MMMM YYYY"))  // Combines month and year in one line
                    .font(.title2.bold())  // Smaller, bold font for clarity
                    .foregroundStyle(itemCategory.color.gradient)

                Text(currentDate.format("EEEE, d"))  // Day and weekday on second line
                    .font(.callout)  // Smaller font for less emphasis
                    .foregroundStyle(.primary)
            }
            Spacer()  // Pushes logo to the right
        }
        .padding(.horizontal, 12)  // Consistent horizontal padding
    }

    // MARK: - Toolbar Configuration
    /// Defines toolbar items for navigation and actions
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {  // Sidebar toggle button
                NavigationLink(destination: SettingsView()) {
                    GearButtonView()  // Compact logo
                        .frame(width: 30, height: 25)  // Reduced size for toolbar fit
                        .foregroundStyle(selectedColor.gradient)
                        .padding(.bottom, 5)
                }
                .accessibilityLabel("Settings")
            }

            ToolbarItem(placement: .principal) {  // Custom header in center
                headerView().padding(.bottom, 7)
            }

            ToolbarItem(placement: .navigationBarTrailing) {  // Profile navigation link
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundStyle(selectedColor.gradient)
                }
                .accessibilityLabel("Profile")
            }
        }
    }
}
// MARK: - Preview

/// Preview provider for ItemScreen
#Preview {
    ItemScreen(itemCategory: .events) // Requires Category enum with .events case
        .modelContainer(for: [Item.self, ItemTask.self]) // Matches schema
}
