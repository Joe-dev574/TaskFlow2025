//
//  AttachmentsListViewswift.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/6/25.
//

import SwiftUI
import SwiftData
import PhotosUI
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
    
    /// State to track selected photos from the PhotosPicker
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    /// State to show the camera picker sheet
    @State private var showingImagePicker = false
    
    /// State to hold the captured image from the camera
    @State private var cameraImage: UIImage?
    
    /// State to display error messages in an alert
    @State private var errorMessage: String?
    
    /// State to show the action sheet for choosing attachment source
    @State private var showingAttachmentOptions = false
    
    /// State to show the PhotosPicker sheet
    @State private var showingPhotosPicker = false
    
    /// State to force UI refresh if needed
    @State private var refreshID = UUID()
    
    /// State to track permission statuses
    @State private var cameraPermissionGranted = false
    @State private var photosPermissionGranted = false
    
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
                    .font(.system(size: 18, design: .serif)) // 10% less than 20
                    .fontWeight(.bold)
                    .accessibilityLabel("Attachments Header")
                
                Spacer()
                
                Button(action: {
                    print("Add Attachment tapped") // Debug tap
                    checkPermissionsBeforeAction()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(itemCategory.color)
                        .padding(7)
                        .background(itemCategory.color.opacity(0.2))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add Attachment")
                .accessibilityHint("Tap to add a photo from your library or camera")
            }
            
            // MARK: Debug Count
            Text("Attachments Count: \(attachments.count)")
                .font(.system(size: 14.4, design: .serif)) // 10% less than 16
                .foregroundStyle(.gray)
                .accessibilityLabel("Current attachments count: \(attachments.count)")
            
            // MARK: Attachments Display
            if attachments.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("No attachments", systemImage: "paperclip")
                            .font(.system(size: 15.3, design: .serif)) // 10% less than 17
                            .foregroundStyle(.gray)
                    },
                    description: {
                        Text("Add a photo using the plus button.")
                            .font(.system(size: 15.3, design: .serif)) // 10% less than 17
                            .foregroundStyle(.gray)
                    }
                )
                .accessibilityLabel("No attachments available")
                .accessibilityHint("Use the plus button to add an attachment")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sortedAttachments.indices, id: \.self) { index in
                            AttachmentRowView(attachment: sortedAttachments[index])
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteAttachment(sortedAttachments[index])
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .font(.system(size: 15.3, design: .serif)) // 10% less than 17
                                    }
                                    .accessibilityLabel("Delete attachment \(sortedAttachments[index].fileName)")
                                }
                        }
                    }
                }
                .id(refreshID) // Force redraw on refreshID change
            }
        }
        // MARK: Dynamic Type Support
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Support up to xxxLarge
        .onAppear {
            checkInitialPermissions() // Check permissions on load
        }
        
        // MARK: PhotosPicker Handler
        .onChange(of: selectedPhotos) { _, newValue in
            print("Photos selected: \(newValue.count)") // Debug PhotosPicker
            isBlurred = true
            Task {
                for photo in newValue {
                    do {
                        if let data = try await photo.loadTransferable(type: Data.self) {
                            let attachment = Attachment(data: data, fileName: "photo_\(Date().timeIntervalSince1970).jpg")
                            attachments.append(attachment)
                            modelContext.insert(attachment)
                            try modelContext.save()
                            print("Attachment added: \(attachment.fileName)") // Debug success
                            refreshID = UUID() // Trigger UI refresh
                        } else {
                            errorMessage = "Failed to load photo data"
                            print("Photo data is nil")
                        }
                    } catch {
                        errorMessage = "Error loading photo: \(error.localizedDescription)"
                        print("PhotosPicker error: \(error)")
                    }
                }
                selectedPhotos = []
                isBlurred = false
            }
        }
        // MARK: PhotosPicker Sheet
        .sheet(isPresented: $showingPhotosPicker) {
            VStack {
                PhotosPicker("Select Photos", selection: $selectedPhotos, matching: .images)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                Text("If blank, check permissions or library")
                    .font(.system(size: 15.3, design: .serif)) // 10% less than 17
                    .foregroundStyle(.red)
            }
            .onAppear {
                isBlurred = true
                print("PhotosPicker sheet appeared") // Debug sheet
            }
            .onDisappear {
                isBlurred = false
                print("PhotosPicker sheet dismissed") // Debug dismissal
            }
        }
        // MARK: Camera Sheet
        .sheet(isPresented: $showingImagePicker, onDismiss: {
            isBlurred = false
            print("Camera sheet dismissed") // Debug dismissal
            if cameraImage == nil {
                print("Camera dismissed with no image set") // Debug nil check
            }
        }) {
            TaskFlowImagePicker(image: $cameraImage)
                .onAppear {
                    isBlurred = true
                    print("Camera sheet appeared") // Debug appearance
                }
                .onChange(of: cameraImage) { _, newValue in
                    print("Camera image changed: \(newValue != nil ? "Image present (\(newValue?.size ?? .zero))" : "Image nil")") // Enhanced debug
                    guard let image = newValue else {
                        errorMessage = "No image captured from camera"
                        print("Camera returned nil image")
                        cameraImage = nil
                        isBlurred = false
                        return
                    }
                    guard let data = image.jpegData(compressionQuality: 0.8) else {
                        errorMessage = "Failed to convert image to data"
                        print("Image data conversion failed")
                        cameraImage = nil
                        isBlurred = false
                        return
                    }
                    print("Image data size: \(data.count) bytes") // Debug data
                    let attachment = Attachment(data: data, fileName: "camera_\(Date().timeIntervalSince1970).jpg")
                    attachments.append(attachment)
                    modelContext.insert(attachment)
                    do {
                        try modelContext.save()
                        print("Camera attachment added: \(attachment.fileName)") // Debug success
                        print("Attachments count after save: \(attachments.count)") // Debug binding
                        refreshID = UUID() // Trigger UI refresh
                    } catch {
                        errorMessage = "Error saving camera photo: \(error.localizedDescription)"
                        print("Save error: \(error)")
                    }
                    cameraImage = nil
                    isBlurred = false
                }
        }
        // MARK: Attachment Options Action Sheet
        .actionSheet(isPresented: $showingAttachmentOptions) {
            ActionSheet(
                title: Text("Add Attachment")
                    .font(.system(size: 18, design: .serif)), // 10% less than 20
                message: Text("Choose how to add an attachment")
                    .font(.system(size: 15.3, design: .serif)), // 10% less than 17
                buttons: [
                    .default(Text("Add from Photos")
                        .font(.system(size: 15.3, design: .serif))) {
                        print("Photos option selected") // Debug Photos option
                        if photosPermissionGranted {
                            showingPhotosPicker = true
                        } else {
                            errorMessage = "Photo library permission denied"
                            print("Photos permission not granted")
                        }
                    },
                    .default(Text("Take Photo")
                        .font(.system(size: 15.3, design: .serif))) {
                        print("Take Photo selected") // Debug camera option
                        if cameraPermissionGranted {
                            showingImagePicker = true
                        } else {
                            errorMessage = "Camera permission denied"
                            print("Camera permission not granted")
                        }
                    },
                    .cancel()
                ]
            )
        }
        // MARK: Error Alert
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Unknown error")
                .font(.system(size: 15.3, design: .serif)) // 10% less than 17
                .accessibilityLabel("Error: \(errorMessage ?? "Unknown error")")
        }
    }
    
    // MARK: - Methods
    
    /// Checks camera and photo library permissions on view appearance
    private func checkInitialPermissions() {
        // Camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            print("Camera permission granted")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    print("Camera permission request: \(granted ? "granted" : "denied")")
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
            print("Camera permission denied or restricted")
        @unknown default:
            cameraPermissionGranted = false
            print("Unknown camera permission status")
        }
        
        // Photo library permission
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            photosPermissionGranted = true
            print("Photos permission granted")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    photosPermissionGranted = (status == .authorized || status == .limited)
                    print("Photos permission request: \(photosPermissionGranted ? "granted" : "denied")")
                }
            }
        case .denied, .restricted:
            photosPermissionGranted = false
            print("Photos permission denied or restricted")
        @unknown default:
            photosPermissionGranted = false
            print("Unknown photos permission status")
        }
    }
    
    /// Checks permissions before showing the action sheet
    private func checkPermissionsBeforeAction() {
        if !cameraPermissionGranted || !photosPermissionGranted {
            checkInitialPermissions()
        } else {
            showingAttachmentOptions = true
        }
    }
    
    /// Deletes an attachment from the list and persists the change
    private func deleteAttachment(_ attachment: Attachment) {
        if let index = attachments.firstIndex(of: attachment) {
            attachments.remove(at: index)
        }
        modelContext.delete(attachment)
        do {
            try modelContext.save()
            print("Attachment deleted, new count: \(attachments.count)") // Debug deletion
            refreshID = UUID() // Trigger UI refresh
        } catch {
            print("AttachmentsListView: Failed to delete attachment: \(error.localizedDescription)")
        }
    }
}
