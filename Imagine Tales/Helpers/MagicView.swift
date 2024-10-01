//
//  MagicView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/28/24.
//


import SwiftUI
import Vortex

/// A sample view demonstrating the built-in magic preset.
struct MagicView: View {
    var body: some View {
        VStack {
            ZStack {
                VortexView(.fireflies) {
                    Circle()
                        .fill(.white)
                        .frame(width: 30)
                        .tag("circle")
                }
            }
            .ignoresSafeArea(edges: .top)
            
            
        }
    }
}
/// A sample view demonstrating confetti bursts.
struct ConfettiView: View {
    @State private var shouldBurst: Bool = false // State to trigger the confetti burst
    
    var body: some View {
        ZStack {
            VortexViewReader { proxy in
                ZStack {
                    VortexView(.confetti.makeUniqueCopy()) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 16, height: 16)
                            .tag("square")
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 16)
                            .tag("circle")
                    }
                    .onChange(of: shouldBurst) { newValue in
                        if newValue {
                            proxy.burst() // Trigger the confetti burst
                            shouldBurst = false // Reset after bursting
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Add the button for triggering the confetti burst
            VStack {
                Spacer()
                Button(action: {
                    shouldBurst = true // Set the state to true when button is clicked
                }) {
                    Text("Celebrate!")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
#Preview {
    ConfettiView()
}
