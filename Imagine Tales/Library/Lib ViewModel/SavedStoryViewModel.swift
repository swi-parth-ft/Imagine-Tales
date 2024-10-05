//
//  SavedStoryViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import FirebaseFirestore

/// ViewModel for managing saved stories.
final class SavedStoryViewModel: ObservableObject {
    @Published var stories: [Story] = [] // Array to hold all stories
    @Published var savedStories: [Story] = [] // Array to hold saved stories for the user
    @Published var genre: String = "Adventure" // Default genre, can be modified as needed
    private var lastDocument: DocumentSnapshot? = nil
    private let limit = 10  // Set a limit of 10 stories per batch
    // Other existing methods...
    private var storyIds: [String] = []

    
    
    
    
    // Function to load stories with pagination
    @MainActor
    func getMySavedStories(isLoadMore: Bool = false, childId: String) async {
        // Reset the stories and pagination if not loading more
        if !isLoadMore {
            storyIds = []
            stories = []
            lastDocument = nil
        }
        
        do {
                // Fetch a batch of saved story IDs from Firestore
                let (newStoryIds, lastDoc) = try await StoriesManager.shared.getAllMySavedStories(count: limit, childId: childId, lastDocument: lastDocument)
                
                // Fetch the actual Story models for each storyId
                for storyId in newStoryIds {
                    if !self.storyIds.contains(storyId) {
                        self.storyIds.append(storyId)
                        
                        // Fetch the actual Story document based on the storyId
                        let story = try await StoriesManager.shared.getStory(by: storyId)
                        
                        // Update the UI on the main thread
                        DispatchQueue.main.async {
                            self.stories.append(story) // Assuming you have a list of Story models
                        }
                    }
                }
                
                // Update the last document for pagination
                DispatchQueue.main.async {
                    self.lastDocument = lastDoc
                }
                
            } catch {
            print("Error fetching stories: \(error.localizedDescription)")
        }
    }
}
