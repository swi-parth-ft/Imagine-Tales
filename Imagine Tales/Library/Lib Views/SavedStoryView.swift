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
    
    // Define the grid layout with two columns
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    let columnsLandscape = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var retryCount = 0 // Count for retry attempts when loading images
    @State private var maxRetryAttempts = 3 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retries
    @State private var selectedStory: Story? = nil
    @EnvironmentObject var orientation: OrientationManager
    var body: some View {
        NavigationStack {
            // Check if there are no saved stories
            if viewModel.stories.isEmpty {
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
                .onAppear {
                    // Fetch saved stories when the view appears
                    Task {
                        await viewModel.getMySavedStories(childId: childId)
                    }
                }
            }
                
            
            ScrollView {
                LazyVGrid(columns: orientation.isLandscape ? columnsLandscape : columns, spacing: 23) {
                    ForEach(viewModel.stories, id: \.id) { story in
                                ZStack {
                                    // Load the story image asynchronously
                                    AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                        switch phase {
                                        case .empty:
                                            MagicView()
                                                .frame(width: orientation.isLandscape ? UIScreen.main.bounds.width * 0.30 : UIScreen.main.bounds.width * 0.45, height: 500)
                                            
                                        case .success(let image):
                                            // Successfully loaded image
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: orientation.isLandscape ? UIScreen.main.bounds.width * 0.30 : UIScreen.main.bounds.width * 0.45, height: 500)
                                                .clipped()
                                                .cornerRadius(16)
                                            
                                        case .failure(_):
                                            // Placeholder for failed load
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: orientation.isLandscape ? UIScreen.main.bounds.width * 0.30 : UIScreen.main.bounds.width * 0.45, height: 500)
                                                .cornerRadius(16)
                                                .padding()
                                                .onAppear {
                                                    // Retry loading logic
                                                    if retryCount < maxRetryAttempts {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                            retryCount += 1
                                                        }
                                                    }
                                                }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Add shadow to the image
                                    
                                    VStack {
                                        Spacer()
                                        
                                        ZStack {
                                           
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .frame(width: orientation.isLandscape ? UIScreen.main.bounds.width * 0.28 : UIScreen.main.bounds.width * 0.43, height: 200)
                                                .cornerRadius(16)
                                            VStack(spacing: 0) {
                                                
                                                Text(story.title)
                                                    .font(.system(size: 18))
                                                Text("By \(story.childUsername)")
                                                    .font(.system(size: 16))
                                                    .padding(.top, -20)
                                                HStack {
                                                    Image(systemName: "heart.fill")
                                                        .foregroundStyle(.red)
                                                    Text("\(story.likes) Likes")
                                                        .padding(.trailing)
                                                    
                                                    Text(story.theme ?? "")
                                                        .padding(7)
                                                        .background(colorScheme == .dark ? Color(hex: "#4B8A1C") : .green)
                                                        .foregroundStyle(.white)
                                                        .cornerRadius(22)
                                                        
                                                }
                                                .font(.system(size: 16))
                                                .padding(.top)
                                                Button {
                                                    selectedStory = story
                                                } label: {
                                                    HStack {
                                                        Text("Read Now")
                                                        Image(systemName: "book.pages")
                                                    }
                                                    .frame(width: orientation.isLandscape ? UIScreen.main.bounds.width * 0.12 : UIScreen.main.bounds.width * 0.35)
                                                }
                                                .padding()
                                                .font(.system(size: 16))
                                                .background(Color(hex: "#FF6F61"))
                                                .foregroundStyle(.white)
                                                .cornerRadius(16)
                                                .padding(.top)
                                            }
                                            .foregroundStyle(.primary)
                                            
                                        }
                                        .padding(.bottom, 10)
                                    }
                                }
                        if story == viewModel.stories.last {
                            ProgressView()
                                .onAppear {
                                    Task {
                                        await viewModel.getMySavedStories(isLoadMore: true, childId: childId)
                                    }
                                }
                        }
                            }
                        }
                        .padding()
                    }
            .padding(.bottom, 40)
            .fullScreenCover(item: $selectedStory) { story in
                    StoryFromProfileView(story: story)
            }
            .navigationTitle("Saved Stories") // Set the title of the navigation bar
            .onAppear {
                // Fetch saved stories when the view appears
               // viewModel.getSavedStories(forChild: childId)
                Task {
                    await viewModel.getMySavedStories(childId: childId)
                }
                
            }
      
          

        }
    }
}

// Preview provider for SwiftUI previews
#Preview {
    SavedStoryView(reload: .constant(false)) // Preview for the SavedStoryView with reload set to false
}
