//
//  TransitionPreview.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/31/24.
//


import SwiftUI

/// A view that lets users see what a given transition looks like,
/// by flipping between two sample views.
struct TransitionPreview: View {
    /// Whether we're showing the first view or the second view.
    @State private var showingFirstView = true

    /// The opacity of our preview view, so users can check how fading works.
    @State private var opacity = 1.0

    /// The shader we're rendering.
    var shader: TransitionShader
    

    @State private var showDetail = false
    @State private var page: Int = 1
    
    var body: some View {
        ZStack {
            VStack {
                if page == 1 {
                    Image("Onboarding-1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width)
                        .opacity(opacity)
                        .drawingGroup()
                        .transition(shader.transition)
                } else if page == 2 {
                    Image("Onboarding-2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width)
                        .opacity(opacity)
                        .drawingGroup()
                        .transition(shader.transition)
                } else {
                    Image("Onboarding-3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width)
                        .opacity(opacity)
                        .drawingGroup()
                        .transition(shader.transition)
                }
                
            }
            VStack {
                Spacer()
                Button("Next") {
                    withAnimation(.easeIn(duration: 1.5)) {
                        
                        page += 1
                    }
                }
                .padding()
                .frame(width: 200, height: 55)
                .background(.orange.opacity(1))
                .cornerRadius(22)
                .foregroundStyle(.black)
            }
            .padding()
        }
    }
    
}

#Preview {
    TransitionPreview(shader: .example)
}
