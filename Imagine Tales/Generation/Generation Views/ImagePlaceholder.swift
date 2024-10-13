//
//  ImagePlaceholder.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/12/24.
//

import SwiftUI

struct ImagePlaceholder: View {
    
    let texts = [
            "Crafting your imagination...",
            "Painting pixels with AI magic...",
            "Rendering dreams into reality...",
            "Generating visual brilliance...",
            "Creating art from algorithms...",
            "Your vision is taking shape...",
            "The AI brush is at work...",
            "Transforming ideas into art...",
            "Unlocking creativity, please wait...",
            "Breathing life into pixels...",
            "Synthesizing an artistic masterpiece...",
            "AI is sculpting your concept...",
            "The canvas is evolving...",
            "Shaping your creative thoughts...",
            "Bringing AI visions to life...",
            "Magically rendering your scene...",
            "Building your digital masterpiece...",
            "Spinning pixels into perfection...",
            "Imagination at work, hang tight...",
            "Innovating your design in progress..."
        ]
    // Array of AI text colors
        let colors: [Color] = [
            .blue, .green, .purple, .orange, .pink, .red, .yellow, .indigo, .teal, .cyan,
            Color(hue: 0.9, saturation: 0.7, brightness: 0.9), // Custom light pink
            Color(hue: 0.4, saturation: 0.8, brightness: 0.8), // Custom bright blue
            Color(hue: 0.3, saturation: 0.6, brightness: 0.7), // Custom greenish
            Color(hue: 0.1, saturation: 0.8, brightness: 0.9), // Custom vibrant orange
            Color(hue: 0.7, saturation: 0.7, brightness: 0.6), // Custom purple
            .mint, .brown, .gray, .white, .black
        ]
@State private var randomColor: Color = .white
        @State private var currentText: String = ""
        @State private var randomPosition: CGPoint = .zero
        @State private var opacity: Double = 0.0
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemThinMaterial)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                .cornerRadius(23)
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        Text(currentText)
                            .font(.title)
                            .foregroundStyle(randomColor)
                           // .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding()
                            .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                            .opacity(opacity) // Control opacity
                            .cornerRadius(22)
                            .position(randomPosition)
                    }
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                .onReceive(timer) { _ in
                    // Animate fade out
                    withAnimation(.easeIn(duration: 0.2)) {
                        opacity = 0.0
                    }
                    
                    // Delay before updating the text and position
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Randomly pick a new text
                        currentText = texts.randomElement() ?? "Loading..."
                        randomColor = colors.randomElement() ?? .black
                        // Randomly pick a new position within the rectangle
                        randomPosition = CGPoint(x: CGFloat.random(in: 150...(UIScreen.main.bounds.width * 0.9 - 150)),
                                                 y: CGFloat.random(in: 150...(UIScreen.main.bounds.width * 0.9 - 150)))
                        
                        // Animate fade in
                        withAnimation(.easeIn(duration: 1)) {
                            opacity = 1.0
                        }
                    }
                }
            MagicView()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
        }
    }
}

#Preview {
    ImagePlaceholder()
}
