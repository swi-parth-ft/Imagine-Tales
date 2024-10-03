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
    
    // Other existing methods...
    
    /// Fetches the saved stories for a specific child based on their ID.
    /// - Parameter childId: The ID of the child whose saved stories are to be fetched.
    func getSavedStories(forChild childId: String) {
        let db = Firestore.firestore() // Reference to Firestore database
        let savedStoriesRef = db.collection("Children2").document(childId).collection("savedStories") // Reference to the child's saved stories collection
        
        // Fetch saved stories documents for the given child
        savedStoriesRef.getDocuments { (snapshot, error) in
            // Handle error if fetching fails
            if let error = error {
                print("Error getting saved stories: \(error)") // Log error to console
                return
            }
            
            // Dictionary to store unique stories using story ID as the key
            var storyDictionary = [String: Story]()
            // Extract story IDs from fetched documents
            let storyIds = snapshot?.documents.compactMap { $0.data()["storyId"] as? String } ?? []
            
            // Create a DispatchGroup to manage multiple asynchronous fetches
            let storyGroup = DispatchGroup()
            
            // Loop through each story ID to fetch the corresponding story details
            for storyId in storyIds {
                storyGroup.enter() // Enter the dispatch group for each fetch
                
                // Fetch the story document from the "Story" collection
                db.collection("Story").document(storyId).getDocument { (document, error) in
                    // Check if the document exists and handle any potential error
                    if let document = document, document.exists {
                        // Try to decode the document data into a Story object
                        if let story = try? document.data(as: Story.self) {
                            // Use story ID as the key to ensure uniqueness
                            storyDictionary[storyId] = story
                        }
                    }
                    storyGroup.leave() // Leave the dispatch group after fetching is done
                }
            }
            
            // Notify when all fetches are completed
            storyGroup.notify(queue: .main) {
                // Convert dictionary values to an array of saved stories
                self.savedStories = Array(storyDictionary.values)
                // Sort saved stories alphabetically by title
                self.savedStories.sort(by: { $0.dateCreated! > $1.dateCreated! })  // Example sorting, modify as needed
            }
        }
    }
}
