//
//  BackgroundView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/6/24.
//


import SwiftUI

struct SignInBG: View {
    @Environment(\.colorScheme) var colorScheme // For light/dark mode detection
    
    var body: some View {
        BackGroundMesh() // External background mesh
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Spacer()
                            Image(colorScheme == .dark ? "bg2dark" : "backgroundShade2") // Left background image
                                .resizable()
                                .scaledToFit()
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            Image(colorScheme == .dark ? "bg1dark" : "backgroundShade1") // Right background image
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            )
    }
}
