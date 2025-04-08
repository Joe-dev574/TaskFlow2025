//
//  ItemEditView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ItemEditView: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    private let editItem: Item
    
    // MARK: - Query Properties
    @Query(sort: \Tag.name) var tags: [Tag]
    
    // MARK: - State Properties
    @State private var newTag = false
    @State private var notes: [Note] = []
    @State var taskToEdit: ItemTask?
    @State var showingAddTask = false
    @State private var taskName: String
    @State private var taskDescription: String
    @State private var dateAdded: Date
    @State private var dateDue: Date
    @State private var dateStarted: Date
    @State private var dateCompleted: Date
    @State private var itemCategory: Category
    @State private var itemStatus: Item.Status
    @State private var categoryAnimationTrigger: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var showTaskSheet: Bool = false
    @State private var errorMessage: String = ""
    @State private var showTags = false
    @State private var itemTasks: [ItemTask] = []
    @State private var taskListHeight: CGFloat = 0
    @State private var isBlurred: Bool = false
    @State private var attachments: [Attachment] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var cameraImage: UIImage?
    
    // MARK: - Initial Values for Comparison
    private let initialTaskName: String
    private let initialTaskDescription: String
    private let initialDateAdded: Date
    private let initialDateDue: Date
    private let initialDateStarted: Date
    private let initialDateCompleted: Date
    private let initialCategory: Category
    private let initialStatus: Item.Status
    private let initialTags: [Tag]?
    private let initialItemTasks: [ItemTask]?
    private let initialNotes: [Note]?
    private let initialAttachments: [Attachment]?
    
    // MARK: - Initialization
    init(editItem: Item) {
        self.editItem = editItem
        _taskName = State(initialValue: editItem.title)
        _taskDescription = State(initialValue: editItem.remarks)
        _dateAdded = State(initialValue: editItem.dateAdded)
        _dateDue = State(initialValue: editItem.dateDue)
        _dateStarted = State(initialValue: editItem.dateStarted)
        _dateCompleted = State(initialValue: editItem.dateCompleted)
        _itemCategory = State(initialValue: Category(rawValue: editItem.category) ?? .today)
        _itemStatus = State(initialValue: Item.Status(rawValue: editItem.status)!)
        _itemTasks = State(initialValue: editItem.itemTasks ?? [])
        _notes = State(initialValue: editItem.notes ?? [])
        _attachments = State(initialValue: editItem.attachments ?? [])
        initialTaskName = editItem.title
        initialTaskDescription = editItem.remarks
        initialDateAdded = editItem.dateAdded
        initialDateDue = editItem.dateDue
        initialDateStarted = editItem.dateStarted
        initialDateCompleted = editItem.dateCompleted
        initialCategory = Category(rawValue: editItem.category) ?? .today
        initialStatus = Item.Status(rawValue: editItem.status)!
        initialTags = editItem.tags
        initialItemTasks = editItem.itemTasks
        initialNotes = editItem.notes
        initialAttachments = editItem.attachments
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .presentationDetents([.fraction(0.5), .fraction(0.8), .large])
        .presentationDragIndicator(.visible)
        .blur(radius: (showTags || showTaskSheet) ? 10 : 0)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [.gray.opacity(0.02), .gray.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger)
        .onChange(of: itemCategory) {
            withAnimation {
                categoryAnimationTrigger = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false
                }
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    titleSection
                    remarksSection
                    categorySection
                    tagsSection
                    statusSection
                    datesSection
                    taskSection
                    noteSection
                    attachmentsSection
                }
                .padding(12)
            }
            .blur(radius: isBlurred ? 10 : 0)
            .navigationTitle(editItem.title)
            .toolbar { toolbarItems }
            .foregroundStyle(calculateContrastingColor(background: itemCategory.color))
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Section Styling Configuration
    struct SectionStyle {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 12
        static let backgroundOpacity: Double = 0.01
        static let reducedOpacity: Double = backgroundOpacity * 0.30
    }
    
    // MARK: Item Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 20, design: .serif))
                .fontWeight(.bold)
            LabeledContent {
                CustomTextEditor(
                    remarks: $taskName,
                    placeholder: "Enter title of your item",
                    minHeight: 45
                )
                .foregroundStyle(.mediumGrey)
                .accessibilityLabel("Item Title")
                .accessibilityHint("Enter the title of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Item Description Text Editor
    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief Description")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 20, design: .serif))
                .fontWeight(.bold)
            CustomTextEditor(
                remarks: $taskDescription,
                placeholder: "Enter a brief description of your item",
                minHeight: 100
            )
            .foregroundStyle(.mediumGrey)
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
            .accessibilityLabel("Item Description")
            .accessibilityHint("Enter brief description of your item")
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 20, design: .serif))
                .fontWeight(.bold)
            LabeledContent {
                CategorySelector(
                    selectedCategory: $itemCategory,
                    animateColor: .constant(itemCategory.color),
                    animate: .constant(false)
                )
                .foregroundStyle(.primary)
                .accessibilityLabel("Category Selector")
                .accessibilityHint("Choose a category for your item")
            } label: {
                EmptyView()
            }
            .padding(5)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Tag Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TagListView(item: editItem, itemCategory: itemCategory, isBlurred: $isBlurred)
                .padding(SectionStyle.padding)
                .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear { print("List size: \(geometry.size)") }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 20, design: .serif))
                .fontWeight(.bold)
            LabeledContent {
                Picker("Status", selection: $itemStatus) {
                    ForEach(Item.Status.allCases, id: \.self) { status in
                        Text(status.descr)
                            .font(.system(.body, design: .serif))
                            .tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Status Picker")
                .accessibilityHint("Select the status of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Dates Section
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 20, design: .serif))
                .fontWeight(.bold)
            VStack(spacing: 8) {
                LabeledContent {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .foregroundStyle(.gray.opacity(0.2))
                        Text(dateAdded.formatted(.dateTime))
                            .font(.system(size: 16, design: .serif))
                            .foregroundStyle(.mediumGrey)
                    }
                    .frame(width: 195, height: 35)
                    .foregroundStyle(itemCategory.color)
                    .padding(.trailing, 3)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Created \(dateAdded.formatted(.dateTime))")
                } label: {
                    Text("Created")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.mediumGrey)
                }
                datePickersForCategory()
            }
            .padding(8)
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Task Section
    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            TaskListView(itemTasks: $itemTasks, itemCategory: itemCategory, isBlurred: $isBlurred)
                .padding(SectionStyle.padding)
                .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear { print("List size: \(geometry.size)") }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Note Section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            NotesListView(notes: $notes, itemCategory: itemCategory, isBlurred: $isBlurred)
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    // MARK: Attachments Section
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            AttachmentsListView(attachments: $attachments, itemCategory: itemCategory, isBlurred: $isBlurred)
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
        }
    // MARK: - Toolbar Items
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveEditedItem()
                }
                .font(.system(.callout, design: .serif))
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)
                .disabled(!hasFormChanged)
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Tap to save your edited item. Disabled until changes are made.")
            }
        }
    }
    
    // MARK: - Private Computed Properties
    private var hasFormChanged: Bool {
        taskName != initialTaskName ||
        taskDescription != initialTaskDescription ||
        dateAdded != initialDateAdded ||
        dateDue != initialDateDue ||
        dateStarted != initialDateStarted ||
        dateCompleted != initialDateCompleted ||
        itemCategory != initialCategory ||
        itemStatus != initialStatus ||
        editItem.tags != initialTags ||
        itemTasks != initialItemTasks ||
        notes != initialNotes ||
        attachments != initialAttachments
    }
    
    // MARK: - Save Edited Item Function
    private func saveEditedItem() {
        editItem.title = taskName
        editItem.remarks = taskDescription
        editItem.dateAdded = dateAdded
        editItem.dateDue = dateDue
        editItem.dateStarted = dateStarted
        editItem.dateCompleted = dateCompleted
        editItem.category = itemCategory.rawValue
        editItem.status = itemStatus.rawValue
        editItem.itemTasks = itemTasks
        editItem.notes = notes
        editItem.attachments = attachments
        
        do {
            try context.save()
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Date Pickers for Category
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        VStack(spacing: 12) {
            LabeledContent {
                DatePicker("", selection: $dateDue)
                    .labelsHidden()
                    .foregroundStyle(itemCategory.color)
                    .font(.system(.caption, design: .serif))
            } label: {
                Text("Due")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(.mediumGrey)
            }
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
            
            if itemCategory == .today || itemCategory == .work {
                LabeledContent {
                    DatePicker("", selection: $dateStarted)
                        .labelsHidden()
                        .font(.system(.caption, design: .serif))
                } label: {
                    Text("Start")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.mediumGrey)
                }
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
            }
            
            if itemCategory == .today {
                LabeledContent {
                    DatePicker("", selection: $dateCompleted)
                        .labelsHidden()
                        .foregroundStyle(.mediumGrey)
                        .font(.system(.caption, design: .serif))
                } label: {
                    Text("Finish")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.mediumGrey)
                }
                .accessibilityLabel("Completion Date")
                .accessibilityHint("Select the completion date for your item")
            }
        }
    }
    
    // MARK: - Functions
    private func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func calculateContrastingColor(background: Color) -> Color {
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 7 && whiteContrast >= blackContrast ? .white : .black
    }
}

// MARK: - TagItem View
struct TagItemView: View {
    let tag: Tag
    let onDelete: () -> Void
    @State var showTags = false
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                HStack(spacing: 0) {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(tag.hexColor)
                    Text(tag.name)
                        .foregroundStyle(.mediumGrey)
                        .font(.system(size: 12, design: .serif))
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(.lightGrey)
                            .frame(width: 15, height: 15)
                            .padding(.horizontal, 1)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 2)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tag: \(tag.name)")
                .accessibilityAddTraits(.isButton)
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    func darker() -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: max(red - 0.2, 0), green: max(green - 0.2, 0), blue: max(blue - 0.2, 0), opacity: alpha)
    }
}

// MARK: - Tag Extension
extension Tag {
    var swiftUIColor: Color {
        switch tagColor.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "gray": return .gray
        case "black": return .black
        case "white": return .white
        default:
            if tagColor.hasPrefix("#"), tagColor.count == 7 {
                let hex = String(tagColor.dropFirst())
                if let intValue = UInt32(hex, radix: 16) {
                    let r = Double((intValue >> 16) & 0xFF) / 255.0
                    let g = Double((intValue >> 8) & 0xFF) / 255.0
                    let b = Double(intValue & 0xFF) / 255.0
                    return Color(red: r, green: g, blue: b)
                }
            }
            return .green
        }
    }
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}
