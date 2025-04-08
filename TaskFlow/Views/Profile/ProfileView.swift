//
//  ProfileView.swift
//  DailyGrind0.2
//
//  Created by Joseph DeWeese on 3/19/25.
//

import SwiftUI



struct ProfileView: View {
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            Button("Save") {
                // Save logic here
            }
        }
        .navigationTitle("Profile")
    }
}
#Preview {
    ProfileView()
}