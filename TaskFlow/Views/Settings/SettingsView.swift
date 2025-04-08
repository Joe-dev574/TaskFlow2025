//
//  SettingsView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import StoreKit
import UIKit

/// A settings view for configuring app preferences and accessing support options
struct SettingsView: View {
    // MARK: - Persistent Properties
    
    /// Persists the user's preference for enabling notifications
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    /// Persists the user's selected theme color as a hex string
    @AppStorage("selectedColor") private var selectedColorData = Color.blue.toHex() ?? "#0000FF"
    
    // MARK: - State Properties
    
    /// Tracks the pressed state of buttons for potential UI feedback (currently unused)
    @State private var isButtonPressed = false
    
    /// Controls the visibility of an export confirmation alert (currently unused)
    @State private var showExportConfirmation = false
    
    // MARK: - Environment Properties
    
    /// Dismisses the current view context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Computed Properties
    
    /// Converts the hex string to a Color for use in the view, with setter to update persistent storage
    private var selectedColor: Color {
        get { Color(hex: selectedColorData) }
        set { selectedColorData = newValue.toHex() ?? "#0000FF" }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                profileSection
                missionStatementSection
                displaySettingsSection
                notificationsSection
                exportSection
                aboutSection
                contactDeveloperSection
                rateAppSection
            }
            .navigationTitle("Settings")
            .accentColor(selectedColor)
        }
    }
    
    // MARK: - Sections
    
    /// Displays user profile information with navigation to settings
    private var profileSection: some View {
        Section {
            NavigationLink(destination: Text("Profile Settings")) { // TODO: Replace with actual ProfileView
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(selectedColor)
                    VStack(alignment: .leading) {
                        Text("Joseph DeWeese")
                            .font(.title2)
                        Text("Apple ID, Media & Purchases, Account, Privacy & Security")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                .accessibilityLabel("Profile for Joseph DeWeese")
                .accessibilityHint("Tap to edit profile settings")
            }
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    //MARK:   MISSION  STATEMENT SECTION
    /// Presents the app's mission statement with stylized text
    private var missionStatementSection: some View {
        Section(header: Text("Mission").font(.headline).foregroundColor(selectedColor)) {
            let missionText = "Efficiently manage tasks with our app's clear, logical design. It's a private tool that adapts to your journey, learning from your habits to guide you. Reflect on your path and understand your life's story with a personalized companion."
            
            HStack(alignment: .top, spacing: 5) {
                Text(String(missionText.prefix(1)))
                    .font(.custom("Georgia", size: 24))
                    .fontWeight(.bold)
                    .foregroundStyle(selectedColor)
                    .offset(y: -7)
                
                Text(AttributedString(missionText.dropFirst(), attributes: AttributeContainer([
                    .font: Font.custom("Georgia", size: 16),
                    .foregroundColor: Color.mediumGrey // Assumes mediumGrey is defined in assets
                ])))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Mission statement: \(missionText)")
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - Display Settings Section
    
    /// Allows customization of the app's display settings
    private var displaySettingsSection: some View {
        Section(header: Text("Display").font(.headline).foregroundStyle(selectedColor)) {
            HStack {
                Image(systemName: "paintpalette")
                    .foregroundStyle(selectedColor)
                ColorPicker("App Theme Color", selection: Binding(
                    get: { selectedColor },
                    set: { newColor in selectedColorData = newColor.toHex() ?? "#0000FF" }
                ))
                .accessibilityLabel("Choose app theme color")
                .accessibilityHint("Select a color to customize the app's theme")
            }
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - Notifications Section
    
    /// Provides a toggle for enabling/disabling notifications
    private var notificationsSection: some View {
        Section(header: Text("Notifications").font(.headline).foregroundStyle(selectedColor)) {
            Toggle(isOn: $notificationsEnabled) {
                HStack {
                    Image(systemName: "bell")
                        .foregroundStyle(selectedColor)
                    Text("Enable Notifications")
                }
            }
            .accessibilityLabel("Notifications toggle")
            .accessibilityHint(notificationsEnabled ? "Tap to disable notifications" : "Tap to enable notifications")
            .accessibilityValue(notificationsEnabled ? "On" : "Off")
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - Export Section
    
    /// Offers an option to export project details
    private var exportSection: some View {
        Section(header: Text("Reporting").font(.headline).foregroundColor(selectedColor)) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundStyle(selectedColor)
                Button {
                    exportProjectDetails()
                    HapticsManager.notification(type: .success) // Assumes HapticsManager exists
                } label: {
                    Text("Export Project Details")
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(selectedColor.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .mediumGrey, radius: 2, x: 2, y: 2)
                }
                .hoverEffect(.lift)
                .accessibilityLabel("Export Project Details")
                .accessibilityHint("Tap to export project details to a shareable format")
            }
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - About Section
    
    /// Displays app information and legal navigation links
    private var aboutSection: some View {
        Section(header: Text("About").font(.headline).foregroundColor(selectedColor)) {
            NavigationLink(destination: Text("App Version: 1.0.0")) { // TODO: Replace with actual VersionView
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(selectedColor)
                    Text("Version")
                }
                .accessibilityLabel("App Version")
                .accessibilityHint("Tap to view the app's version number")
            }
            NavigationLink(destination: Text("Terms and Conditions")) { // TODO: Replace with actual TermsView
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(selectedColor)
                    Text("Terms and Conditions")
                }
                .accessibilityLabel("Terms and Conditions")
                .accessibilityHint("Tap to view the app's terms and conditions")
            }
            NavigationLink(destination: Text("Privacy Policy")) { // TODO: Replace with actual PrivacyPolicyView
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(selectedColor)
                    Text("Privacy Policy")
                }
                .accessibilityLabel("Privacy Policy")
                .accessibilityHint("Tap to view the app's privacy policy")
            }
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - Contact Developer Section
    
    /// Provides options for contacting the developer
    private var contactDeveloperSection: some View {
        Section(header: Text("Contact the Developer").font(.headline).foregroundColor(selectedColor)) {
            NavigationLink(destination: Text("Send Feedback")) { // TODO: Replace with actual FeedbackView
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(selectedColor)
                    Text("Send Feedback")
                }
                .accessibilityLabel("Send Feedback")
                .accessibilityHint("Tap to send feedback to the developer")
            }
            NavigationLink(destination: Text("Report a Bug")) { // TODO: Replace with actual BugReportView
                HStack {
                    Image(systemName: "ant")
                        .foregroundStyle(selectedColor)
                    Text("Report a Bug")
                }
                .accessibilityLabel("Report a Bug")
                .accessibilityHint("Tap to report a bug to the developer")
            }
            NavigationLink(destination: Text("Contact Support")) { // TODO: Replace with actual SupportView
                HStack {
                    Image(systemName: "headphones")
                        .foregroundStyle(selectedColor)
                    Text("Contact Support")
                }
                .accessibilityLabel("Contact Support")
                .accessibilityHint("Tap to contact developer support")
            }
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - Rate App Section
    
    /// Links to the App Store for rating the app
    private var rateAppSection: some View {
        Section {
            Link(destination: URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review")!) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(selectedColor.opacity(0.8))
                    Text("Rate on App Store")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.gray)
                }
                .accessibilityLabel("Rate on App Store")
                .accessibilityHint("Tap to open the App Store to rate the app")
            }
        }
        .customSectionStyle(selectedColor: selectedColor)
    }
    
    // MARK: - Functions
    
    /// Exports project details via a share sheet
    private func exportProjectDetails() {
        let report = "Your report data here" // TODO: Replace with actual project data
        let activityVC = UIActivityViewController(activityItems: [report], applicationActivities: nil)
        
        // Present the share sheet using modern iOS window scene API
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            activityVC.completionWithItemsHandler = { activity, completed, _, error in
                if completed {
                    print("Export completed successfully via \(activity?.rawValue ?? "unknown")")
                } else if let error = error {
                    print("Export failed: \(error.localizedDescription)")
                }
            }
            rootViewController.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Custom Section Style Modifier

/// A modifier to apply a consistent gradient and border style to settings sections
struct CustomSectionStyle: ViewModifier {
    let selectedColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(7)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [selectedColor.opacity(0.09), selectedColor.opacity(0.03)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(selectedColor.opacity(0.3), lineWidth: 2)
                    .shadow(color: .mediumGrey.opacity(0.3), radius: 5, x: 2, y: 2)
            )
    }
}

// MARK: - View Extension

extension View {
    /// Applies the custom section style with the specified selected color
    func customSectionStyle(selectedColor: Color) -> some View {
        self.modifier(CustomSectionStyle(selectedColor: selectedColor))
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
