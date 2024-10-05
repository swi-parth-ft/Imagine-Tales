//
//  StoryByGenreViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/1/24.
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
                
                self.stories.sort { $0.dateCreated! > $1.dateCreated!}
                // Debug print to check the fetched stories
                print(self.stories)
            }
    }
    
    private var lastDocument: DocumentSnapshot? = nil
    private let limit = 10  // Set a limit of 10 stories per batch
    
    @MainActor
    func getStorie(isLoadMore: Bool = false, genre: String) async {
        // Reset the stories and pagination if not loading more
        if !isLoadMore {
            stories = []
            lastDocument = nil
        }
        
        do {
            // Fetch a batch of stories from Firestore
            let (newStories, lastDoc) = try await StoriesManager.shared.getAllStories(count: limit, genre: genre, lastDocument: lastDocument)
            
            // Update UI in main thread
            DispatchQueue.main.async {
                self.stories.append(contentsOf: newStories)
                self.lastDocument = lastDoc // Update last document for pagination
            }
        } catch {
            print("Error fetching stories: \(error.localizedDescription)")
        }
    }
}
