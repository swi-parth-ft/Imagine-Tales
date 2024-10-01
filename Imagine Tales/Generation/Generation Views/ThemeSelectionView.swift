//
//  ThemeSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// ThemeSelectionView allows users to select a theme for their story from a horizontal list of themed options.
struct ThemeSelectionView: View {
    @Binding var isSelectingTheme: Bool   // Binding to control whether the theme selection is active
    @Binding var theme: String             // Binding to store the currently selected theme
    let themes: [String]                   // Array of available theme names
    let themeColors: [Color]               // Array of colors associated with each theme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // GeometryReader allows access to the size of the enclosing view, enabling responsive design
        GeometryReader { geometry in
            // Calculate the height for each theme circle based on the available height
            let height = (geometry.size.height - 40) / 6
            
            // Horizontal scroll view for theme selection
            ScrollView(.horizontal) {
                // LazyHGrid provides a horizontal grid layout for the themes
                LazyHGrid(
                    rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 3), // Create 3 rows of fixed height
                    spacing: 60  // Space between each column of themes
                ) {
                    // Loop through each theme index to create the UI
                    ForEach(0..<themes.count, id: \.self) { index in
                        VStack {
                            // ZStack allows stacking of elements on top of each other
                            ZStack {
                                // Circle background for each theme
                                Circle()
                                    .fill(themes[index] == theme ? (colorScheme == .dark ? themeColors[index].opacity(0.9) : themeColors[index].opacity(0.5)) : (colorScheme == .dark ? themeColors[index].opacity(0.5) : themeColors[index].opacity(0.2))) // Change opacity based on selection
                                    .frame(width: height, height: height) // Set size of the circle
                                    .shadow(radius: 5) // Add shadow for depth
                                    // Scale effect for the selected theme
                                    .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.4 : 1.2) : 0.0)
                                    .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme) // Animation effect

                                VStack(spacing: themes[index] == theme ? -5 : -10) {
                                    // Image associated with the theme
                                    Image("\(themes[index].filter { !$0.isWhitespace })") // Filter out whitespaces from theme names for image loading
                                        .resizable() // Allow image to be resized
                                        .scaledToFit() // Maintain aspect ratio
                                        .frame(width: height * 0.7, height: height * 0.7, alignment: .center) // Set size for the image
                                        .shadow(radius: 5) // Add shadow for depth
                                        // Scale effect for the image based on selection
                                        .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.2 : 1.0) : 0.0)
                                        .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme) // Animation effect

                                    // Split the theme string into words for multiline text display
                                    let words = themes[index].split(separator: " ")

                                    VStack {
                                        // Loop through each word in the theme string
                                        ForEach(words, id: \.self) { word in
                                            Text(String(word)) // Convert Substring to String for display
                                                .font(.custom("ComicNeue-Bold", size: 22)) // Custom font for theme name
                                                .multilineTextAlignment(.center) // Center align the text
                                                .opacity(isSelectingTheme ? 1.0 : 0.0) // Control visibility based on selection
                                                // Scale effect for the text based on selection
                                                .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.2 : 1.0) : 0.0)
                                                .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme) // Animation effect
                                        }
                                    }
                                    
                                }
                                .padding() // Padding around the VStack for spacing
                            }
                        }
                        // Apply offset for every other column to create a hexagonal shape effect
                        .offset(y: (index / 3) % 2 == 0 ? 0 : height / 2) // Adjust Y position based on index
                        .frame(width: height, height: height) // Set fixed frame for the theme item
                        // Tap gesture to select a theme
                        .onTapGesture {
                            withAnimation { // Animate the theme selection
                                theme = themes[index] // Update the selected theme
                            }
                        }
                    }
                }
                .padding(.leading, 50) // Add left padding to the grid
                .padding(.bottom, 70) // Add bottom padding to the grid
            }
            Spacer() // Add a spacer to push content
        }
        // Transition effect for when the view appears/disappears
        .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
    }
}
