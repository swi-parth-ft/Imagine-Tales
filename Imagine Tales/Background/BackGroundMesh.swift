//
//  BackGroundMesh.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/7/24.
//

import Foundation
import SwiftUICore


struct BackGroundMesh: View {
    
    
    let bookBackgroundColorsLight: [Color] = [
        Color(red: 255/255, green: 235/255, blue: 190/255),  // More vivid Beige
        Color(red: 220/255, green: 220/255, blue: 220/255),  // More vivid Light Gray
        Color(red: 255/255, green: 230/255, blue: 240/255),  // More vivid Lavender Blush
        Color(red: 255/255, green: 255/255, blue: 245/255),  // More vivid Mint Cream
        Color(red: 230/255, green: 255/255, blue: 230/255),  // More vivid Honeydew
        Color(red: 230/255, green: 248/255, blue: 255/255),  // More vivid Alice Blue
        Color(red: 255/255, green: 250/255, blue: 230/255),  // More vivid Seashell
        Color(red: 255/255, green: 250/255, blue: 215/255),  // More vivid Old Lace
        Color(red: 255/255, green: 250/255, blue: 200/255)   // More vivid Cornsilk
    ]
    
    let bookBackgroundColorsDark: [Color] = [
        Color(red: 54/255, green: 48/255, blue: 42/255),  // Dark Olive Green
        Color(red: 50/255, green: 50/255, blue: 50/255),  // Dark Charcoal Gray
        Color(red: 47/255, green: 42/255, blue: 47/255),  // Dark Violet
        Color(red: 48/255, green: 48/255, blue: 44/255),  // Dark Slate Gray
        Color(red: 37/255, green: 45/255, blue: 37/255),  // Dark Jungle Green
        Color(red: 37/255, green: 45/255, blue: 50/255),  // Dark Teal
        Color(red: 48/255, green: 48/255, blue: 40/255),  // Dark Fern Green
        Color(red: 48/255, green: 48/255, blue: 37/255),  // Dark Olive
        Color(red: 48/255, green: 48/255, blue: 36/255)   // Dark Olive Yellow
    ]
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        // Choose the appropriate color palette based on the color scheme
        let backgroundColors = (colorScheme == .dark) ? bookBackgroundColorsDark : bookBackgroundColorsLight
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: backgroundColors
        ).ignoresSafeArea()
        
    }
}
