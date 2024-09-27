//
//  MoodSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// The MoodSelectionView is responsible for displaying a horizontally scrollable grid of moods with corresponding emojis.
// Users can select a mood, updating the bound `mood` and `selectedEmoji` properties, with visual feedback reflecting the selection.
struct MoodSelectionView: View {
    // Bindings to track and control the current mood and emoji selected by the user
    @Binding var isSelectingMood: Bool
    @Binding var mood: String
    @Binding var selectedEmoji: String
    
    // Arrays holding the list of mood names and corresponding emojis
    let moods: [String]
    let moodEmojis: [String]

    var body: some View {
        GeometryReader { geometry in
            // Calculate the height of each mood circle based on available vertical space
            let height = (geometry.size.height - 40) / 8

            // Scrollable horizontal view for mood selection
            ScrollView(.horizontal) {
                LazyHGrid(
                    // Define grid layout: 4 rows with fixed height and spacing between them
                    rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 4),
                    spacing: 60  // Adjust spacing between the columns to bring them closer together
                ) {
                    // Loop through each mood to display a corresponding circle with an emoji and text
                    ForEach(0..<moods.count, id: \.self) { index in
                        VStack {
                            ZStack {
                                // Circle representing each mood option
                                Circle()
                                    // Highlight the selected mood with a more opaque fill and larger scale
                                    .fill(moods[index] == mood ? Color.yellow.opacity(0.5) : Color.yellow.opacity(0.2))
                                    .frame(width: height, height: height)
                                    .shadow(radius: 5) // Add shadow for a subtle depth effect
                                    .scaleEffect(isSelectingMood ? (moods[index] == mood ? 1.4 : 1.2) : 0.0) // Scale effect on selection
                                    .animation(.easeInOut(duration: moods[index] == mood ? 0.6 : 0.3), value: isSelectingMood) // Animate the circle scaling based on selection

                                VStack {
                                    // Display the emoji corresponding to the mood
                                    Text(moodEmojis[index])
                                        .font(.system(size: 32)) // Emoji size for visibility
                                    
                                    // Display the mood name under the emoji
                                    Text(moods[index])
                                        .font(.custom("ComicNeue-Bold", size: 24)) // Custom font for the mood names
                                        .opacity(isSelectingMood ? 1.0 : 0.0) // Fade in/out effect for the mood text
                                        .scaleEffect(isSelectingMood ? (moods[index] == mood ? 1.2 : 1.0) : 0.0) // Scale effect on the text when selected
                                        .animation(.easeInOut(duration: moods[index] == mood ? 0.6 : 0.3), value: isSelectingMood) // Animate the scaling
                                }
                            }
                        }
                        // Offset every other column to create a hexagonal shape pattern
                        .offset(y: (index / 4) % 2 == 0 ? 0 : height / 2)
                        .frame(width: height, height: height)
                        // Handle the tap gesture to update the selected mood and corresponding emoji
                        .onTapGesture {
                            withAnimation {
                                mood = moods[index] // Update the selected mood
                                selectedEmoji = moodEmojis[index] // Update the selected emoji
                            }
                        }
                    }
                }
                .padding(.leading, 50) // Left padding for better alignment
                .padding(.bottom, 70)  // Bottom padding for visual spacing
            }
            Spacer() // Add extra spacing at the bottom
        }
        // Add transition effect for smooth appearance/disappearance of the view
        .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
    }
}
