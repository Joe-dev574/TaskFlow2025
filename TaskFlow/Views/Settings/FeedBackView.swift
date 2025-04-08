//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct FeedBackView: View {
    let feedbackType: String
    @State private var message = ""
    
    var body: some View {
        Form {
            TextField("Your \(feedbackType)", text: $message)
            Button("Send") {
                // Email or API logic here
            }
        }
        .navigationTitle(feedbackType)
    }
}
#Preview {
    FeedBackView(feedbackType: "")
}
