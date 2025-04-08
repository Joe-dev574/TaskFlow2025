//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct PrivacySettingsView: View {
    @State private var shareData = false
    
    var body: some View {
        Form {
            Toggle("Share Usage Data", isOn: $shareData)
        }
        .navigationTitle("Privacy")
    }
}

#Preview {
    PrivacySettingsView()
}
