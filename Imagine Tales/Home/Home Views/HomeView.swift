//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI
import Drops

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel() // ViewModel for handling data fetching and state management
    @Binding var reload: Bool // Binding to trigger reloading of stories
    @Environment(\.colorScheme) var colorScheme
    // List of genres available for selection
    let genres = [
        "Following", "Adventure", "Fantasy", "Mystery", "Romance", "Science Fiction", "Horror", "Thriller",
        "Historical", "Comedy", "Drama", "Detective", "Dystopian", "Fairy Tale", "Magical Realism", "Biography",
        "Coming-of-Age", "Action", "Paranormal", "Supernatural", "Western"
    ]
    
    // Retrieve the childId stored in AppStorage (used for identifying the user)
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        NavigationStack {
            VStack {
                // Horizontal scroll view for genre buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Loop through genres and create a button for each
                        ForEach(genres, id: \.self) { category in
                            Button(action: {
                                // When a genre is selected, update the genre in ViewModel and fetch stories
                                withAnimation {
                                    viewModel.genre = category
                                    Task {
                                        try? await viewModel.getStories(childId: childId) // Fetch stories for the selected genre
                                        reload.toggle() // Toggle reload to refresh the view
                                    }
                                }
                            }) {
                                // Style the genre button based on selection
                                Text(category)
                                    .padding()
                                    .background(category == viewModel.genre ? (colorScheme == .dark ? Color(hex: "#4B8A1C") : .green) : Color.clear)
                                    .foregroundColor(category == viewModel.genre ? .white : .primary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: category == viewModel.genre ? 0 : 1)
                                    )
                                    .cornerRadius(10)
                               
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                
                // Display message if there are no stories available
                if viewModel.stories.isEmpty {
                    ContentUnavailableView {
                        Label("No Stories Yet", systemImage: "book.fill")
                    } description: {
                        Text("It looks like there's no stories posted yet.")
                    }
                } else {
                    // Display the list of stories if available
                    StoryListView(stories: viewModel.stories, reload: $reload, childId: childId)
                        .padding(.bottom, 60)
                }
            }
            .navigationTitle("Imagine Tales") // Title of the view
            
            // Fetch stories and child-related data when the view appears
            .onAppear {
                Task {
                    try? await viewModel.getStories(childId: childId) // Fetch initial set of stories
                    viewModel.fetchChild(ChildId: childId) // Fetch child information
                    viewModel.fetchFriends(childId: childId) // Fetch friend information
                }
            }
            
            // Reload the stories when the reload flag changes
            .onChange(of: reload) {
                Task {
                    try? await viewModel.getStories(childId: childId) // Fetch updated stories
                }
            }
        }
    }
}

#Preview {
    HomeView(reload: .constant(false)) // Preview with a default state
}
