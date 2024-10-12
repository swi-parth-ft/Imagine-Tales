//
//  InvertedCornersShape.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/11/24.
//

import SwiftUI

struct InvertedCornersTabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start from the bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Draw to the bottom-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Draw to the top-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        // Draw to the top-left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        // Add rounded inverted corners at the bottom
        path.addArc(center: CGPoint(x: rect.minX, y: rect.maxY - 10),
                    radius: 10,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: true)

        path.addArc(center: CGPoint(x: rect.maxX, y: rect.maxY - 10),
                    radius: 10,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: true)

        return path
    }
}
