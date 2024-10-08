//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI
import Drops
import GoogleMobileAds

// HomeView displays the home screen of Imagine Tales app, allowing users to view stories filtered by genres or followed accounts.
struct HomeView: View {
    
    // MARK: - State & Binding Variables

    // ViewModel for managing the data and state related to fetching stories and child information.
    @StateObject var viewModel = HomeViewModel()
    
    // Binding variable to trigger reloading of stories. This is passed from a parent view to update when needed.
    @Binding var reload: Bool
    
    // Accessing the current color scheme (light or dark mode).
    @Environment(\.colorScheme) var colorScheme
    
    // Array of genres that users can choose from to filter stories.
    let genres = [
        "Following", "Adventure", "Fantasy", "Mystery", "Romance", "Science Fiction", "Horror", "Thriller",
        "Historical", "Comedy", "Drama", "Detective", "Dystopian", "Fairy Tale", "Magical Realism", "Biography",
        "Coming-of-Age", "Action", "Paranormal", "Supernatural", "Western"
    ]
    
    // Fetching the childId from the app's storage, used to identify which child's data to display.
    @AppStorage("childId") var childId: String = "Default Value"
    
    // Local state variable to track the currently selected genre.
    @State private var cat = "Following"
    
    // Accessing the orientation manager (could be used to manage layout for portrait/landscape modes).
    @EnvironmentObject var oriantation: OrientationManager
    
    // MARK: - Body
    
    var body: some View {
        // NavigationStack provides a structured navigation system for this view.
        NavigationStack {
            
            VStack {
                
                
                  
                // Horizontal scroll view for selecting different genres.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Iterate through the list of genres and display a button for each.
                        ForEach(genres, id: \.self) { category in
                            Button(action: {
                                // When a genre is selected, update the 'cat' variable and fetch stories.
                                cat = category
                                if category == "Following" {
                                    // Fetch stories for followed accounts.
                                    Task {
                                        await viewModel.getFollowingStories(genre: category, childId: childId)
                                        reload.toggle() // Toggle reload to update the view.
                                    }
                                } else {
                                    // Fetch stories for a specific genre.
                                    Task {
                                        await viewModel.getStorie(genre: category)
                                        reload.toggle() // Toggle reload to update the view.
                                    }
                                }
                            }) {
                                // Button appearance: Change background color based on the selected category.
                                Text(category)
                                    .padding()
                                    .background(category == cat ? (colorScheme == .dark ? Color(hex: "#4B8A1C") : .green) : Color.clear)
                                    .foregroundColor(category == cat ? .white : .primary)
                                    .overlay(
                                        // Add a green border around the button when it’s not selected.
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: category == cat ? 0 : 1)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal) // Padding on both sides of the horizontal scroll view.
                }
                .padding() // Padding around the entire genre section.

                // If no stories are available, display a message.
                if viewModel.newStories.isEmpty {
                    ContentUnavailableView {
                        Label("No Stories Yet", systemImage: "book.fill")
                    } description: {
                        Text("It looks like there's no stories posted yet.")
                    }
                } else {
                    // Show the list of stories in a scrollable view.
                    ScrollView {
                        LazyVStack {
                            // If the selected category is "Following", display stories from followed users.
                            if cat == "Following" {
                                ForEach(Array(viewModel.newStories.enumerated()), id: \.element.id) { index, story in
                                    // Display each story using a custom StoryRowView.
                                    StoryRowView(story: story, childId: childId, reload: $reload)
                                    
                                    // Check if the index is divisible by 2, and display something after every 2 items.
                                    if (index + 1) % 2 == 0 {
                                        // Display ad after every 2 items.
                                        GeometryReader { geometry in
                                            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
                                            
                                            VStack {
                                                
                                                BannerView(adSize)
                                                    .frame(height: adSize.size.height / 4)
                                            }
                                            
                                        }.frame(height: 100)
                                    }
                                    
                                    // If the current story is the last one, show a progress view and load more stories.
                                    if story == viewModel.newStories.last {
                                        ProgressView()
                                            .onAppear {
                                                Task {
                                                    // Fetch more stories as the user scrolls.
                                                    await viewModel.getFollowingStories(isLoadMore: true, genre: cat, childId: childId)
                                                }
                                            }
                                    }
                                }
                            } else {
                                // Display stories for other genres.
                                ForEach(viewModel.newStories, id: \.id) { story in
                                    StoryRowView(story: story, childId: childId, reload: $reload)
                                    
                                    // Show a progress view and load more stories when reaching the last story.
                                    if story == viewModel.newStories.last {
                                        ProgressView()
                                            .onAppear {
                                                Task {
                                                    // Fetch more stories for the selected genre.
                                                    await viewModel.getStorie(isLoadMore: true, genre: cat)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 60) // Extra padding at the bottom to accommodate the navigation bar.
                }
            }
            .navigationTitle("Imagine Tales") // Title for the HomeView screen.

            // When the view appears, fetch stories and child-related data.
            .onAppear {
                Task {
                    // Fetch stories for the selected genre or followed accounts.
                    await viewModel.getFollowingStories(genre: cat, childId: childId)
                    
                    // Fetch child and friends information.
                    viewModel.fetchChild(ChildId: childId)
                    viewModel.fetchFriends(childId: childId)
                }
            }
        }
    }
}

// Preview for SwiftUI canvas.
#Preview {
    HomeView(reload: .constant(false)) // Preview with a constant reload state.
}
