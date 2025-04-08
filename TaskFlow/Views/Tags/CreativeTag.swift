//
//  CreativeTag.swift
//  DailyGrind1.0
//
//  Created by Joseph DeWeese on 3/18/25.
//

import SwiftUI

struct CreativeTag: View {
    let label: String // Tag name
    let tagColor: Color // Custom color for the hexagon fill
    
    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(
                LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom) // Metallic text effect
            )
            .padding(10)
            .background(
                HexagonShape()
                    .fill(tagColor) // Use the custom tagColor here
            )
            .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0) // Glowing effect
            .overlay(
                HexagonShape()
                    .stroke(Color.cyan, lineWidth: 2) // Neon outline
            )
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width * 0.25, y: 0))
        path.addLine(to: CGPoint(x: width * 0.75, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.75, y: height))
        path.addLine(to: CGPoint(x: width * 0.25, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.5))
        path.closeSubpath()
        return path
    }
}

// Example usage in a preview or your code
struct CreativeTag_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            CreativeTag(label: "Work", tagColor: .blue)
            CreativeTag(label: "Personal", tagColor: .red)
            CreativeTag(label: "Urgent", tagColor: .orange)
        }
    }
}
