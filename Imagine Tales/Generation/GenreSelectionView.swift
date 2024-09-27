//
//  GenreSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// The GenreSelectionView is responsible for presenting a list of genres in a horizontally scrolling grid.
// Users can select a genre, which updates the binding `genre` property, and the view's appearance changes accordingly.
struct GenreSelectionView: View {
    // Binding to control whether the genre selection view is visible or not
    @Binding var isSelectingGenre: Bool
    
    // Binding to track the currently selected genre
    @Binding var genre: String
    
    // List of available genres to display
    let genres: [String]

    var body: some View {
        GeometryReader { geometry in
            // Calculate the height for each genre circle based on the available screen space
            let height = (geometry.size.height - 40) / 7

            // Horizontal scrollable view to display genres
            ScrollView(.horizontal) {
                LazyHGrid(
                    // Define grid layout: fixed row height with spacing between the rows
                    rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 4),
                    spacing: 60  // Adjust spacing between columns to bring them closer together
                ) {
                    // Loop through each genre to create the selection circles
                    ForEach(0..<genres.count, id: \.self) { index in
                        VStack {
                            ZStack {
                                // Circle representing the genre option
                                Circle()
                                    // Highlight the selected genre by changing the circle's fill color and scaling up
                                    .fill(genres[index] == genre ? Color.cyan.opacity(0.5) : Color.cyan.opacity(0.2))
                                    .frame(width: height, height: height)
                                    .shadow(radius: 5)
                                    .scaleEffect(isSelectingGenre ? (genres[index] == genre ? 1.4 : 1.2) : 0.0) // Scale effect on selection
                                    .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre) // Animation based on selection

                                // Display the genre text inside the circle
                                Text(genres[index])
                                    .font(.custom("ComicNeue-Bold", size: 24)) // Custom font for genre names
                                    .opacity(isSelectingGenre ? 1.0 : 0.0) // Fade in/out effect for the text
                                    .scaleEffect(isSelectingGenre ? (genres[index] == genre ? 1.2 : 1.0) : 0.0) // Scale effect on text
                                    .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre) // Animate scaling based on selection
                            }
                        }
                        // Offset the circle for every other column to create a hexagonal pattern effect
                        .offset(y: (index / 4) % 2 == 0 ? 0 : height / 2)
                        .frame(width: height, height: height)
                        // Handle the tap gesture to update the selected genre
                        .onTapGesture {
                            withAnimation {
                                genre = genres[index] // Update the genre when a circle is tapped
                            }
                        }
                    }
                }
                .padding(.leading, 50) // Add left padding for the grid
                .padding(.bottom, 70)  // Add bottom padding for better spacing
            }
            Spacer() // Add some spacing at the bottom
        }
        // Transition effect when the view appears/disappears
        .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
    }
}
