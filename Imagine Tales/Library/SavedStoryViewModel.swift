//
//  SavedStoryViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import FirebaseFirestore

final class SavedStoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var savedStories: [Story] = []
    @Published var genre: String = "Adventure"
    
    // Other existing methods...
    
    func getSavedStories(forChild childId: String) {
        let db = Firestore.firestore()
        let savedStoriesRef = db.collection("Children2").document(childId).collection("savedStories")
        
        savedStoriesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting saved stories: \(error)")
                return
            }
            
            var storyDictionary = [String: Story]()
            let storyIds = snapshot?.documents.compactMap { $0.data()["storyId"] as? String } ?? []
            
            let storyGroup = DispatchGroup()
            
            for storyId in storyIds {
                storyGroup.enter()
                db.collection("Story").document(storyId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let story = try? document.data(as: Story.self) {
                            // Use story ID as the key to ensure uniqueness
                            storyDictionary[storyId] = story
                        }
                    }
                    storyGroup.leave()
                }
            }
            
            storyGroup.notify(queue: .main) {
                // Convert dictionary values to array
                self.savedStories = Array(storyDictionary.values)
                self.savedStories.sort(by: { $0.title < $1.title })  // Example sorting, modify as needed
            }
        }
    }
   
}