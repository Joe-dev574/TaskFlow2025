//
//  AttachmentsListViewswift.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/6/25.
//


import SwiftUI
import SwiftData
import PhotosUI // For PhotosPicker and PhotosPickerItem
import AVFoundation // For camera permission
import UniformTypeIdentifiers // For document picker
import QuickLook // For QLPreviewController

struct AttachmentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var attachments: [Attachment]
    let itemCategory: Category
    @Binding var isBlurred: Bool
    @State private var showingImagePicker = false
    @State private var cameraImage: UIImage?
    @State private var showingDocumentPicker = false
    @State private var selectedPhotos: PhotosPickerItem? = nil
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var showingRenameAlert = false
    @State private var renameText = ""
    @State private var attachmentToRename: Attachment?
    @State private var selectedAttachmentURL: AttachmentURL?
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    struct AttachmentURL: Identifiable {
        let id = UUID()
        let url: URL
    }
    
    var photoAttachments: [Attachment] {
        attachments.filter { $0.fileName.hasSuffix(".jpg") }.sorted { $0.creationDate > $1.creationDate }
    }
    
    var documentAttachments: [Attachment] {
        attachments.filter { !$0.fileName.hasSuffix(".jpg") }.sorted { $0.creationDate > $1.creationDate }
    }
    
    init(attachments: Binding<[Attachment]>, itemCategory: Category, isBlurred: Binding<Bool>) {
        self._attachments = attachments
        self.itemCategory = itemCategory
        self._isBlurred = isBlurred
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack(spacing: 5) {
                        Text("Attachments")
                            .foregroundStyle(itemCategory.color)
                            .font(.system(size: 18, design: .serif))
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
                        
                        PhotosPicker(selection: $selectedPhotos, matching: .images, photoLibrary: .shared()) {
                            Image(systemName: "photo")
                                .imageScale(.large)
                                .foregroundStyle(itemCategory.color)
                                .padding(7)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Add Photos")
                        .accessibilityHint("Tap to add photos")
                        .onChange(of: selectedPhotos) { _, newValue in
                            print("PhotosPicker selection changed: \(newValue != nil ? "item selected" : "nil")")
                            if let newValue {
                                loadTransferable(from: newValue)
                            }
                        }
                        
                        Button(action: {
                            print("Document button tapped")
                            hapticFeedback.impactOccurred()
                            showingDocumentPicker = true
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
                        ContentUnavailableView(
                            label: {
                                Label("Documents and Photo bin is empty", systemImage: "rectangle.dashed.and.paperclip")
                                    .font(.system(.body, design: .serif))
                                    .foregroundStyle(.gray)
                            },
                            description: {
                                Text("Add attachments by tapping the buttons above.")
                                    .font(.system(.body, design: .serif))
                                    .foregroundStyle(.gray)
                            }
                        )
                        .accessibilityLabel("No attachments available")
                        .accessibilityHint("Tap the buttons above to add attachments")
                    } else {
                        VStack(alignment: .leading) {
                            Text("Count: \(attachments.count)")
                                .font(.system(size: 14.4, design: .serif))
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                                .accessibilityLabel("Current attachments count: \(attachments.count)")
                                .padding(.horizontal, 7)
                            Text("Photos")
                                .font(.system(size: 16, design: .serif))
                                .foregroundStyle(itemCategory.color)
                                .padding(4)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .accessibilityLabel("Photos Section")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(photoAttachments) { attachment in
                                        AttachmentRowView(attachment: attachment)
                                            .onTapGesture {
                                                if let url = saveToTemporaryFile(data: attachment.data, fileName: attachment.fileName) {
                                                    selectedAttachmentURL = AttachmentURL(url: url)
                                                }
                                            }
                                            .contextMenu {
                                                Button("Rename") {
                                                    attachmentToRename = attachment
                                                    renameText = attachment.fileName
                                                    showingRenameAlert = true
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Documents")
                                .font(.system(size: 16, design: .serif))
                                .foregroundStyle(itemCategory.color)
                                .padding(4)
                                .background(itemCategory.color.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .accessibilityLabel("Documents Section")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(documentAttachments) { attachment in
                                        AttachmentRowView(attachment: attachment)
                                            .onTapGesture {
                                                if let url = saveToTemporaryFile(data: attachment.data, fileName: attachment.fileName) {
                                                    selectedAttachmentURL = AttachmentURL(url: url)
                                                }
                                            }
                                            .contextMenu {
                                                Button("Rename") {
                                                    attachmentToRename = attachment
                                                    renameText = attachment.fileName
                                                    showingRenameAlert = true
                                                }
                                            }
                                    }
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
                VStack {
                    TaskFlowImagePicker(image: $cameraImage)
                        .onAppear { print("Camera sheet appeared") }
                        .onDisappear { print("Camera sheet dismissed, image: \(cameraImage != nil ? "size: \(cameraImage!.size)" : "nil")") }
                        .accessibilityLabel("Camera picker")
                        .accessibilityHint("Tap to take a photo to attach")
                    Button("Dismiss") {
                        dismiss()
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                VStack {
                    DocumentPicker { url in
                        loadDocument(from: url)
                    }
                    Button("Dismiss") {
                        dismiss()
                    }
                    .padding()
                }
            }
            .sheet(item: $selectedAttachmentURL) { attachmentURL in
                QuickLookView(url: attachmentURL.url)
            }
            .alert("Rename Attachment", isPresented: $showingRenameAlert, actions: {
                TextField("New Name", text: $renameText)
                    .foregroundStyle(.primary) // Fix white text
                Button("Save") {
                    if let attachment = attachmentToRename, !renameText.isEmpty {
                        attachment.fileName = renameText
                        do {
                            try modelContext.save()
                            print("Renamed attachment to: \(renameText)")
                        } catch {
                            errorMessage = "Error renaming: \(error.localizedDescription)"
                            print("Rename error: \(error)")
                            showErrorAlert = true
                        }
                    }
                    attachmentToRename = nil
                }
                Button("Cancel", role: .cancel) {
                    attachmentToRename = nil
                }
            }, message: {
                Text("Enter a new name for the attachment")
            })
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage ?? "Unknown error")
                    .accessibilityLabel("Error: \(errorMessage ?? "Unknown error")")
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
                let attachment = Attachment(data: data, fileName: "Pic \(photoAttachments.count + 1).jpg")
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
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            print("Starting loadTransferable for PhotosPicker item")
            if let data = try? await imageSelection.loadTransferable(type: Data.self) {
                print("Loaded photo data: \(data.count) bytes")
                let attachment = Attachment(data: data, fileName: "Pic \(photoAttachments.count + 1).jpg")
                print("Created attachment: \(attachment.fileName)")
                DispatchQueue.main.async {
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
                    selectedPhotos = nil
                }
            } else {
                print("Failed to load photo data")
                DispatchQueue.main.async {
                    errorMessage = "Failed to load photo"
                    showErrorAlert = true
                }
            }
            print("loadTransferable completed")
        }
    }
    
    private func loadDocument(from url: URL) {
        Task {
            print("Starting loadDocument from URL: \(url.lastPathComponent)")
            do {
                let data = try Data(contentsOf: url)
                print("Loaded document data: \(data.count) bytes")
                let attachment = Attachment(data: data, fileName: url.lastPathComponent)
                print("Created attachment: \(attachment.fileName)")
                DispatchQueue.main.async {
                    attachments.append(attachment)
                    modelContext.insert(attachment)
                    do {
                        try modelContext.save()
                        print("Saved attachment: \(attachment.fileName), count: \(attachments.count)")
                    } catch {
                        errorMessage = "Error saving document: \(error.localizedDescription)"
                        print("Save error: \(error)")
                        showErrorAlert = true
                    }
                }
            } catch {
                print("Failed to load document data: \(error)")
                DispatchQueue.main.async {
                    errorMessage = "Failed to load document: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
            print("loadDocument completed")
        }
    }
    
    private func saveToTemporaryFile(data: Data, fileName: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(fileName)
        do {
            try data.write(to: tempURL, options: [.atomic])
            print("Saved temp file at: \(tempURL.path)")
            return tempURL
        } catch {
            print("Error saving temp file: \(error)")
            return nil
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image, UTType.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                print("Document picked: \(url.lastPathComponent)")
                parent.onDocumentPicked(url)
                parent.dismiss()
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker cancelled")
            parent.dismiss()
        }
    }
}

struct QuickLookView: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL
    
    var body: some View {
        NavigationView {
            QuickLookPreview(url: url)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}
