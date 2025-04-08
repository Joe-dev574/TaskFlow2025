//
//  AttachmentsListViewswift.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/6/25.
//

import SwiftUI
import SwiftData
import AVFoundation // For camera permission

struct AttachmentsListView: View {
    // MARK: - Properties
    
    /// Environment object for SwiftData model context to persist attachments
    @Environment(\.modelContext) private var modelContext
    
    /// Binding to the array of attachments managed by the parent view
    @Binding var attachments: [Attachment]
    
    /// The category of the item, used for consistent coloring
    let itemCategory: Category
    
    /// Binding to control the blur state of the parent view during attachment actions
    @Binding var isBlurred: Bool
    
    /// State to show the camera picker sheet
    @State private var showingImagePicker = false
    
    /// State to hold the captured image from the camera
    @State private var cameraImage: UIImage?
    
    /// State to display error messages in an alert
    @State private var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Returns attachments sorted by creation date (newest first)
    var sortedAttachments: [Attachment] {
        attachments.sorted { $0.creationDate > $1.creationDate }
    }
    
    // MARK: - Initialization
    
    /// Initializes the view with bindings and category
    init(attachments: Binding<[Attachment]>, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._attachments = attachments
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: Header Section
            HStack {
                Text("Attachments")
                    .foregroundStyle(itemCategory.color)
                    .font(.system(size: 18, design: .serif))
                    .fontWeight(.bold)
                    .accessibilityLabel("Attachments Header")
                
                Spacer()
                
                Button(action: {
                    print("Add Attachment tapped")
                    showingImagePicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(itemCategory.color)
                        .padding(7)
                        .background(itemCategory.color.opacity(0.2))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add Attachment")
                .accessibilityHint("Tap to take a photo")
            }
            
            // MARK: Debug Count
            Text("Attachments Count: \(attachments.count)")
                .font(.system(size: 14.4, design: .serif))
                .foregroundStyle(.gray)
                .accessibilityLabel("Current attachments count: \(attachments.count)")
            
            // MARK: Attachments Display
            if attachments.isEmpty {
                Text("No attachments")
                    .font(.system(size: 15.3, design: .serif))
                    .foregroundStyle(.gray)
                    .accessibilityLabel("No attachments available")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sortedAttachments) { attachment in
                            AttachmentRowView(attachment: attachment)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            TaskFlowImagePicker(image: $cameraImage)
                .onAppear { print("Camera sheet appeared") }
                .onDisappear { print("Camera sheet dismissed, image: \(cameraImage != nil ? "size: \(cameraImage!.size)" : "nil")") }
                .accessibilityLabel("Camera picker")
                .accessibilityHint("Take a photo to attach")
        }
        .onChange(of: cameraImage) { _, newValue in
            print("Camera image changed: \(newValue != nil ? "size: \(newValue!.size)" : "nil")")
            guard let image = newValue,
                  let data = image.jpegData(compressionQuality: 0.8) else {
                print("No image or failed to convert to data")
                cameraImage = nil
                return
            }
            print("Image data size: \(data.count) bytes")
            let attachment = Attachment(data: data, fileName: "camera_\(Date().timeIntervalSince1970).jpg")
            print("Created attachment: \(attachment.fileName)")
            attachments.append(attachment)
            modelContext.insert(attachment)
            do {
                try modelContext.save()
                print("Saved attachment: \(attachment.fileName), count: \(attachments.count)")
            } catch {
                errorMessage = "Error saving photo: \(error.localizedDescription)"
                print("Save error: \(error)")
            }
            cameraImage = nil
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Unknown error")
                .font(.system(size: 15.3, design: .serif))
                .accessibilityLabel("Error: \(errorMessage ?? "Unknown error")")
        }
    }
}
