//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct VersionView: View {
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        Text("App Version: \(version)")
            .navigationTitle("Version")
    }
}
#Preview {
    VersionView()
}
