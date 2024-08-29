//
//  GradientRectView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/28/24.
//

import SwiftUI

struct GradientRectView: View {
    
    @State private var gradientColors: [Color] = generateRandomColors()
    let colorChangeInterval: Double = 2.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            [0, 0], [0.5, 0], [1, 0],
                            [0, 0.5], [0.5, 0.5], [1, 0.5],
                                    [0, 1], [0.5, 1], [1, 1]
                        ],
                        colors: gradientColors
                    )

                )
                .padding()
            
            Color.white.opacity(0.3)
        }
        .frame(height: 300)
        .onAppear {
                    startColorChange()
                }
    }
    private func startColorChange() {
            Timer.scheduledTimer(withTimeInterval: colorChangeInterval, repeats: true) { _ in
                withAnimation(Animation.linear(duration: colorChangeInterval)) {
                    gradientColors = GradientRectView.generateRandomColors()
                }
            }
        }
        
        private static func generateRandomColors() -> [Color] {
            let possibleColors: [Color] = [
                .orange, .yellow, .green, .blue, .purple, .red,
                .pink, .cyan, .teal, .gray, .white, .black
            ]
            return (0..<9).map { _ in possibleColors.randomElement()! }
        }
}

#Preview {
    GradientRectView()
}
