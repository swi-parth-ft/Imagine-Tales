//
//  StoryByGenreView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/7/24.
//

import SwiftUI
import FirebaseFirestore

/// ViewModel for managing the stories based on genre.
final class StoryByGenreViewModel: ObservableObject {
    @Published var stories: [Story] = [] // Array to hold the fetched stories for the selected genre
    private var db = Firestore.firestore() // Reference to Firestore database
    
    /// Fetches approved stories of a specific genre from Firestore.
    /// - Parameter genre: The genre for which stories are to be fetched.
    func fetchStories(genre: String) {
        // Query to fetch stories where status is "Approve" and match the given genre
        Firestore.firestore().collection("Story")
            .whereField("status", isEqualTo: "Approve") // Filter for approved stories
            .whereField("genre", isEqualTo: genre) // Filter by genre
            .getDocuments() { (querySnapshot, error) in
                // Log any error that occurs during fetching
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                // Parse the documents into Story objects and store them in the stories array
                self.stories = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Story.self) // Decode each document into a Story object
                } ?? [] // Default to an empty array if parsing fails
                
                // Debug print to check the fetched stories
                print(self.stories)
            }
    }
}

/// View for displaying stories filtered by genre.
struct StoryByGenreView: View {
    @StateObject var viewModel = StoryByGenreViewModel() // Instantiate the ViewModel
    var genre: String // The genre being displayed

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
                                        .opacity(0.3) // Set opacity for background effect
                                        .frame(width: 300, height: 300) // Fixed size for the image
                                    
                                    Spacer() // Add space between images
                                    
                                    // Second smaller background image
                                    Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")2")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(0.5) // Set opacity for a layered effect
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
                            .background(.white.opacity(0.4)) // Background with a white translucent effect
                            .cornerRadius(22) // Rounded corners for the list item
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
