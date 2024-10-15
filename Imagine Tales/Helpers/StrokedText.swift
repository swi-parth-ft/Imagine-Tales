//
//  StrokedText.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/15/24.
//

import SwiftUI

struct StrokedText: View {
    var text: String
    var textColor: Color
    var strokeColor: Color
    var lineWidth: CGFloat

    var body: some View {
        ZStack {
            // Stroke by applying the text multiple times with different offsets
            Text(text)
                .foregroundColor(strokeColor)
                .offset(x: lineWidth, y: lineWidth)
            
            Text(text)
                .foregroundColor(strokeColor)
                .offset(x: -lineWidth, y: lineWidth)

            Text(text)
                .foregroundColor(strokeColor)
                .offset(x: lineWidth, y: -lineWidth)

            Text(text)
                .foregroundColor(strokeColor)
                .offset(x: -lineWidth, y: -lineWidth)
            
            // Main text in the center
            Text(text)
                .foregroundColor(textColor)
        }
    }
}
