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
    
    /// SwiftData context for saving attachments
    @Environment(\.modelContext) private var modelContext
    
    /// Binding to the parent’s attachments array
    @Binding var attachments: [Attachment]
    
    /// Category for UI coloring
    let itemCategory: Category
    
    /// Binding to toggle parent view blur
    @Binding var isBlurred: Bool
    
    /// Controls camera sheet visibility
    @State private var showingImagePicker = false
    
    /// Holds the camera-captured image
    @State private var cameraImage: UIImage?
    
    /// Displays save error messages
    @State private var errorMessage: String?
    
    /// Tracks alert visibility
    @State private var showErrorAlert = false
    
    // MARK: - Computed Properties
    
    /// Sorts attachments by date, newest first
    var sortedAttachments: [Attachment] {
        attachments.sorted { $0.creationDate > $1.creationDate }
    }
    
    // MARK: - Initialization
    
    /// Sets up the view with bindings
    init(attachments: Binding<[Attachment]>, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._attachments = attachments
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    // MARK: - Body
    
    /// Main layout with navigation and scrollable sections
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Attachments")
                        .foregroundStyle(itemCategory.color)
                        .font(.system(size: 18, design: .serif))
                        .fontWeight(.bold)
                        .accessibilityLabel("Attachments Header")
                    
                    Text("Count: \(attachments.count)")
                        .font(.system(size: 14.4, design: .serif))
                        .foregroundStyle(.gray)
                        .accessibilityLabel("Current attachments count: \(attachments.count)")
                    
                    Button(action: {
                        print("Camera button tapped")
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundStyle(itemCategory.color)
                            Text("Take Photo")
                                .foregroundStyle(itemCategory.color)
                        }
                        .padding(7)
                        .background(itemCategory.color.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .accessibilityLabel("Take Photo")
                    .accessibilityHint("Tap to take a photo")
                    
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
                .padding(12)
            }
            .navigationTitle("Attachments")
            .blur(radius: isBlurred ? 10 : 0)
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
                    showErrorAlert = true
                }
                cameraImage = nil
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage ?? "Unknown error")
                    .accessibilityLabel("Error: \(errorMessage ?? "Unknown error")")
            }
        }
    }
}
