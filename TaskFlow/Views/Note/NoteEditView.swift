//
//  NoteEditView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 4/5/25.
//


import SwiftUI
import SwiftData

struct NoteEditView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var note: Note
    let itemCategory: Category
    let onSave: (Note) -> Void
    
    // MARK: - State Properties
    @State private var text: String
    @State private var page: String
    @State private var categoryAnimationTrigger: Bool = false
    
    // MARK: - Initialization
    init(note: Binding<Note>, itemCategory: Category, onSave: @escaping (Note) -> Void) {
        self._note = note
        self.itemCategory = itemCategory
        self.onSave = onSave
        self._text = State(initialValue: note.wrappedValue.text)
        self._page = State(initialValue: note.wrappedValue.page ?? "")
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
    }
    
    // MARK: - Content View
    private var contentView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    textSection
                    pageSection
                    dateSection
                }
                .padding()
            }
            .navigationTitle("Edit Note")
            .toolbar { toolbarItems }
            .foregroundStyle(calculateContrastingColor(background: itemCategory.color))
        }
    }
    
    // MARK: - Section Styling Configuration
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let backgroundOpacity: Double = 0.001
        static let reducedOpacity: Double = backgroundOpacity * 0.25
    }
    
    // MARK: - Content Sections
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note Text")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Note Text Section")
            
            CustomTextEditor(remarks: $text, placeholder: "  Enter your note...", minHeight: 85)
                .foregroundStyle(.mediumGrey)
                .padding(8)
                .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
                .accessibilityLabel("Note Text")
                .accessibilityHint("Edit your note content here")
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var pageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Page (Optional)")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Page Section")
            
            CustomTextEditor(remarks: $page, placeholder: "  Enter page reference...", minHeight: 35)
                .foregroundStyle(.mediumGrey)
                .padding(8)
                .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
                .accessibilityLabel("Page Reference")
                .accessibilityHint("Edit the page reference here")
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .foregroundStyle(itemCategory.color)
                .font(.system(size: 22, design: .serif))
                .fontWeight(.bold)
                .accessibilityLabel("Date Section")
            
            LabeledContent {
                Text(note.creationDate.formatted(.dateTime))
                    .font(.system(.callout, design: .serif))
                    .padding(.trailing, 50)
            } label: {
                Text("Created")
                    .font(.system(.body, design: .serif))
            }
            .foregroundStyle(.mediumGrey)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Created on \(note.creationDate.formatted(.dateTime))")
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.4), lineWidth: 1)
        )
    }
    
    // MARK: - Toolbar Items
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(itemCategory.color)
                }
                .accessibilityLabel("Cancel")
            }
            ToolbarItem(placement: .principal) {
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)
                .accessibilityLabel("Save Note")
            }
        }
    }
    
    // MARK: - Private Methods
    private func save() {
        note.text = text
        note.page = page.isEmpty ? nil : page
        onSave(note)
        dismiss()
    }
    
    // MARK: - Contrast Calculation
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
        let lighter = max(l1, l2), darker = min(l1, l2)
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

// MARK: - Preview
#Preview {
    NoteEditView(
        note: .constant(Note(text: "Sample Note", page: "42")),
        itemCategory: .bills,
        onSave: { _ in }
    )
}
