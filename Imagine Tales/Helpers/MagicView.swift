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

#Preview {
    MagicView()
}
