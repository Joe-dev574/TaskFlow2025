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
    @Environment(\.modelContext) private var modelContext
    @Binding var attachments: [Attachment]
    let itemCategory: Category
    @Binding var isBlurred: Bool
    @State private var showingImagePicker = false
    @State private var cameraImage: UIImage?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var sortedAttachments: [Attachment] {
        attachments.sorted { $0.creationDate > $1.creationDate }
    }
    
    init(attachments: Binding<[Attachment]>, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._attachments = attachments
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    
                    HStack(spacing: 20) { // Adjusted spacing
                        Text("Attachments")
                            .foregroundStyle(itemCategory.color)
                            .font(.system(size: 22, design: .serif))
                            .fontWeight(.bold)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .accessibilityLabel("Attachments Header")
                            .accessibilityHint("List of attachments for this item")
                        
                        Spacer()
                        
                        Button(action: {
                            print("Camera button tapped")
                            hapticFeedback.impactOccurred()
                            showingImagePicker = true
                        }) {
                            Image(systemName: "camera")
                                .imageScale(.large)
                                .foregroundStyle(itemCategory.color)
                                .padding(7)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Take Photo")
                        .accessibilityHint("Tap to take a photo")
                        
                        Button(action: {
                            print("Photos button tapped")
                            hapticFeedback.impactOccurred()
                        }) {
                            Image(systemName: "photo")
                                .imageScale(.large)
                                .foregroundStyle(itemCategory.color)
                                .padding(7)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Add Photos")
                        .accessibilityHint("Tap to add photos")
                        
                        Button(action: {
                            print("Document button tapped")
                            hapticFeedback.impactOccurred()
                        }) {
                            Image(systemName: "doc")
                                .imageScale(.large)
                                .foregroundStyle(itemCategory.color)
                                .padding(7)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Add Document")
                        .accessibilityHint("Tap to add a document")
                    }
                    
                    if attachments.isEmpty {
                        Text("No attachments")
                            .font(.system(size: 15.3, design: .serif))
                            .foregroundStyle(.gray)
                            .accessibilityLabel("No attachments available")
                    } else {
                        Text("Count: \(attachments.count)")
                            .font(.system(size: 14.4, design: .serif))
                            .foregroundStyle(.gray)
                            .accessibilityLabel("Current attachments count: \(attachments.count)")
                        
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
