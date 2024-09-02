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
    @State private var showDetail = false
    var body: some View {
        ZStack {
            
            if #available(iOS 18, *) {
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
            }
            Color.white.opacity(0.3)
        }
        .frame(height: 500)
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


extension AnyTransition {
 
    /// A transition that stretches a view from one edge to the other, while
    /// also fading it out. This one is for left-to-right transitions.
    public static let crosswarpLTR: AnyTransition = .asymmetric(
        insertion: .modifier(
            active: InfernoTransition(name: "crosswarpLTRTransition", progress: 1),
            identity: InfernoTransition(name: "crosswarpLTRTransition", progress: 0)
        ),
        removal: .modifier(
            active: InfernoTransition(name: "crosswarpRTLTransition", progress: 1),
            identity: InfernoTransition(name: "crosswarpRTLTransition", progress: 0)
        )
    )
}


struct InfernoTransition: ViewModifier {
    /// The name of the shader function we're rendering.
    var name: String

    /// How far we are through the transition: 0 is unstarted, and 1 is finished.
    var progress = 0.0

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        ShaderLibrary.crosswarpLTRTransition(
                            .float2(proxy.size),
                            .float(progress)
                        ), maxSampleOffset: .zero)
            }
    }
}


