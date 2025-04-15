//
//  SwipeManager.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

/// A customizable swipe action view that reveals action buttons when swiped.
/// Ideal for list items (e.g., tasks) with interactive options like edit or delete.
struct SwipeAction<Content: View>: View {
    // MARK: - Properties
    
    /// Corner radius of the swipe container, defaults to 0 for sharp edges.
    var cornerRadius: CGFloat = 0
    
    /// Direction of the swipe (leading or trailing), defaults to trailing.
    var direction: SwipeDirection = .trailing
    
    /// The main content view to be swiped (e.g., a task row).
    @ViewBuilder var content: Content
    
    /// Array of actions to display as buttons when swiped.
    @ActionBuilder var actions: [Action]
    
    /// Environment property to adapt background to light/dark mode.
    @Environment(\.colorScheme) private var scheme
    
    /// Unique identifier for the content view within the scroll view.
    /// Hardcoded for simplicity; consider parameterizing for multiple instances.
    private let viewID = "CONTENTVIEW"
    
    /// Controls whether swipe interaction is enabled (e.g., disabled during action execution).
    @State private var isEnabled: Bool = true
    
    /// Tracks the horizontal scroll position for swipe animation.
    @State private var scrollOffset: CGFloat = .zero
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    content
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0)) // Flips for leading swipe
                        .containerRelativeFrame(.horizontal)
                        .background(scheme == .dark ? .black : .white) // Adapts to color scheme
                        .background {
                            if let firstAction = filteredActions.first {
                                Rectangle()
                                    .fill(firstAction.tint)
                                    .opacity(scrollOffset == .zero ? 0 : 1) // Shows tint when swiped
                            }
                        }
                        .id(viewID)
                        .transition(.identity)
                        .overlay {
                            GeometryReader { proxy in
                                let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
                                Color.clear
                                    .preference(key: OffsetKey.self, value: minX)
                                    .onPreferenceChange(OffsetKey.self) { scrollOffset = $0 }
                            }
                        }
                        .accessibilityElement(children: .contain) // Groups content for VoiceOver
                        .accessibilityLabel("Swipeable content")
                        .accessibilityHint(direction == .trailing ? "Swipe left to reveal actions" : "Swipe right to reveal actions")
                    
                    ActionButtons {
                        withAnimation(.snappy) {
                            scrollProxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                    .opacity(scrollOffset == .zero ? 0 : 1) // Shows buttons when swiped
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    content
                    // TODO: Uncomment and test if offset improves swipe behavior
                    // .offset(x: scrollOffset(geometryProxy))
                }
            }
            .scrollIndicators(.hidden) // Hides scroll bar for cleaner UI
            .scrollTargetBehavior(.viewAligned) // Aligns content during swipe
            .background {
                if let lastAction = filteredActions.last {
                    Rectangle()
                        .fill(lastAction.tint)
                        .opacity(scrollOffset == .zero ? 0 : 1) // Background tint when swiped
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .rotationEffect(.init(degrees: direction == .leading ? 180 : 0)) // Flips entire view for leading
            .allowsHitTesting(isEnabled) // Disables interaction during action execution
            .transition(CustomTransition())
            .accessibilityElement(children: .combine) // Combines content and actions for VoiceOver
            .accessibilityHint("Swipe to reveal \(filteredActions.count) actions")
        }
    }
    
    // MARK: - Action Buttons
    
    /// Creates the action buttons revealed by swiping.
    /// - Parameter resetPosition: Closure to reset the scroll position after an action.
    @ViewBuilder
    func ActionButtons(resetPosition: @escaping () -> ()) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(filteredActions.count) * 100) // Fixed width per button
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0) {
                    ForEach(filteredActions) { button in
                        Button(action: {
                            Task {
                                isEnabled = false // Disable interaction during animation
                                resetPosition() // Reset swipe position
                                try? await Task.sleep(for: .seconds(0.3)) // Delay for animation
                                button.action() // Execute the action
                                try? await Task.sleep(for: .seconds(0.05)) // Brief pause
                                isEnabled = true // Re-enable interaction
                            }
                        }, label: {
                            Image(systemName: button.icon)
                                .font(button.iconFont)
                                .foregroundStyle(button.iconTint)
                                .frame(width: 100)
                                .frame(maxHeight: .infinity)
                                .contentShape(.rect)
                        })
                        .buttonStyle(.plain) // Removes default button styling
                        .background(button.tint)
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .accessibilityLabel(button.accessibilityLabel)
                        .accessibilityHint(button.accessibilityHint)
                        .accessibilityAddTraits(.isButton)
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    
    /// Calculates the scroll offset based on geometry proxy (currently unused).
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return (minX > 0 ? -minX : 0)
    }
    
    /// Filtered list of enabled actions for display.
    var filteredActions: [Action] {
        actions.filter { $0.isEnabled }
    }
}

// MARK: - Supporting Types

/// Preference key for tracking scroll offset in the swipe view.
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Custom transition effect for swipe animation, sliding vertically.
struct CustomTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .mask {
                GeometryReader {
                    let size = $0.size
                    Rectangle()
                        .offset(y: phase == .identity ? 0 : -size.height) // Slides up/down
                }
                .containerRelativeFrame(.horizontal)
            }
    }
}

/// Direction of the swipe action (leading or trailing).
enum SwipeDirection {
    case leading
    case trailing
    
    /// Alignment for action buttons based on swipe direction.
    var alignment: Alignment {
        switch self {
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

/// Model representing a single action button with customizable properties.
struct Action: Identifiable {
    let id: UUID = .init()
    var tint: Color          // Background color of the button
    var icon: String         // SF Symbol for the button
    var iconFont: Font = .title // Font size/style for the icon
    var iconTint: Color = .white // Color of the icon
    var isEnabled: Bool = true   // Whether the action is available
    var action: () -> ()         // Closure to execute on tap
    
    // MARK: - Accessibility
    
    /// Default accessibility label (can be overridden when creating Action).
    var accessibilityLabel: String {
        "Action button with icon \(icon)"
    }
    
    /// Default accessibility hint (customize based on action purpose).
    var accessibilityHint: String {
        "Tap to perform an action"
    }
}

@resultBuilder
struct ActionBuilder {
    static func buildBlock(_ components: Action...) -> [Action] {
        components
    }
}

