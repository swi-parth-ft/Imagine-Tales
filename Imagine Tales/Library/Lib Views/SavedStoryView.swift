//
//  SavedStoryView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/29/24.
//

import SwiftUI

/// View for displaying saved stories for a user.
struct SavedStoryView: View {
    @ObservedObject var viewModel = SavedStoryViewModel() // ViewModel to manage the state and data of saved stories
    @AppStorage("childId") var childId: String = "Default Value" // Stores the child's ID in user defaults
    @Binding var reload: Bool // Binding to trigger view updates when the value changes
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            // Check if there are no saved stories
            if viewModel.savedStories.isEmpty {
                // Display a view indicating that no stories are saved
                ContentUnavailableView {
                    Label("No Saved Stories Yet", systemImage: "book.fill") // Title with an icon
                } description: {
                    // Description below the title
                    Text("It looks like there's no stories saved yet.")
                } actions: {
                    // Placeholder for actions, currently no actions are defined
                }
                .listRowBackground(Color.clear) // Clear background for the unavailable content view
            }
            // List to display saved stories, each identified by its unique ID
            List(viewModel.savedStories, id: \.id) { story in
                // Navigation link to view details of the saved story
                NavigationLink(destination: StoryFromProfileView(story: story)) {
                    ZStack {
                        HStack {
                            // First background image for the story theme
                            Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")1")
                                .resizable() // Make the image resizable
                                .scaledToFit() // Scale the image to fit its container
                                .opacity(colorScheme == .dark ? 0.7 : 0.3) // Set opacity for a translucent effect
                                .frame(width: 300, height: 300) // Fixed dimensions for the image
                            Spacer() // Spacer to push the second image to the right
                            // Second background image with reduced size and opacity
                            Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")2")
                                .resizable()
                                .scaledToFit()
                                .opacity(colorScheme == .dark ? 1 : 0.7) // Higher opacity than the first image
                                .frame(width: 70, height: 70) // Smaller fixed dimensions
                            Spacer() // Spacer to ensure proper layout
                        }
                        .frame(height: 100) // Set the height for the HStack containing the images
                        
                        // HStack for the main content of the story
                        HStack {
                            VStack {
                                // Title of the story displayed prominently
                                Text("\(story.title)")
                                    .font(.custom("ComicNeue-Bold", size: 32)) // Custom font style for the title
                                    .padding([.leading, .bottom]) // Padding around the title text
                            }
                            Spacer() // Spacer to align title to the left
                        }
                        .contentShape(Rectangle()) // Define the tappable area for the HStack
                    }
                    // Padding and background for the list item
                    .padding(.vertical) // Vertical padding for the list item
                    .background(colorScheme == .dark ? Color.black.opacity(0.4) : .white.opacity(0.4)) // Semi-transparent white background
                    .cornerRadius(22) // Rounded corners for the list item
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 0)
                    .contentShape(Rectangle()) // Define the tappable area for the overall item
                }
                .buttonStyle(.plain) // Use a plain button style for a consistent look
                .listRowBackground(Color.white.opacity(0)) // Transparent background for the list row
                .listRowSeparator(.hidden) // Hide the separator between rows
            }
            .scrollContentBackground(.hidden) // Hide the default scroll background
            .navigationTitle("Saved Stories") // Set the title of the navigation bar
            .onAppear {
                // Fetch saved stories when the view appears
                viewModel.getSavedStories(forChild: childId)
            }
            .onChange(of: reload) { // Observe changes to the reload binding
                // Fetch saved stories again when reload is triggered
                viewModel.getSavedStories(forChild: childId)
            }
        }
    }
}

// Preview provider for SwiftUI previews
#Preview {
    SavedStoryView(reload: .constant(false)) // Preview for the SavedStoryView with reload set to false
}
