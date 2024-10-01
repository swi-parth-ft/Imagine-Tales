//
//  StoryByGenreView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/7/24.
//

import SwiftUI
import FirebaseFirestore



/// View for displaying stories filtered by genre.
struct StoryByGenreView: View {
    @StateObject var viewModel = StoryByGenreViewModel() // Instantiate the ViewModel
    var genre: String // The genre being displayed
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Background view for the interface
                
                // List to display the stories
                List {
                    // Iterate through each story in the view model
                    ForEach(viewModel.stories) { story in
                        // Navigation link to navigate to StoryFromProfileView when a story is tapped
                        NavigationLink(destination: StoryFromProfileView(story: story)) {
                            ZStack {
                                // Layer for background images related to the story theme
                                HStack {
                                    // First background image with reduced opacity
                                    Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")1")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(colorScheme == .dark ? 0.6 : 0.3) // Set opacity for background effect
                                        .frame(width: 300, height: 300) // Fixed size for the image
                                    
                                    Spacer() // Add space between images
                                    
                                    // Second smaller background image
                                    Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")2")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(colorScheme == .dark ? 1 : 0.5) // Set opacity for a layered effect
                                        .frame(width: 70, height: 70) // Fixed size for the smaller image
                                    
                                    Spacer() // Add space between images
                                }
                                .frame(height: 100) // Set the height for the HStack containing images
                                
                                // Layer for the main content of the story
                                HStack {
                                    VStack {
                                        // Display the title of the story
                                        Text("\(story.title)")
                                            .font(.custom("ComicNeue-Bold", size: 32)) // Custom font for the title
                                            .padding([.leading, .bottom]) // Padding around the title
                                    }
                                    Spacer() // Add space to the right
                                }
                                .contentShape(Rectangle()) // Define the tappable area for the HStack
                            }
                            .padding(.vertical) // Vertical padding for the list item
                            .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4)) // Background with a white translucent effect
                            .cornerRadius(22) // Rounded corners for the list item
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 0)
                            .contentShape(Rectangle()) // Define the tappable area for the overall item
                        }
                        .buttonStyle(.plain) // Use a plain button style to remove default button styling
                        .listRowBackground(Color.white.opacity(0)) // Transparent background for list row
                        .listRowSeparator(.hidden) // Hide the separator between rows
                    }
                }
                .scrollContentBackground(.hidden) // Hide the default scroll background
                .onAppear {
                    // Fetch stories for the selected genre when the view appears
                    viewModel.fetchStories(genre: genre)
                }
            }
            .navigationTitle(genre) // Set the navigation title to the current genre
        }
    }
}

// Preview provider for SwiftUI previews
#Preview {
    StoryByGenreView(genre: "Horror") // Preview for the Horror genre
}
