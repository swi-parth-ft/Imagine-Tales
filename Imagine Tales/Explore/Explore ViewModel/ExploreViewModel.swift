//
//  ExploreViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import FirebaseFirestore

// ViewModel for managing the data for ExploreView.
final class ExploreViewModel: ObservableObject {
    @Published var topStories: [Story] = [] // Array to hold the top stories

    /// Fetches the most liked stories from Firestore.
    func getMostLikedStories() {
        let db = Firestore.firestore() // Reference to Firestore
        
        // Query to get the top 3 stories ordered by likes
        db.collection("Story")
            .order(by: "likes", descending: true)
            .limit(to: 3) // Limit the results to the top 3
            .getDocuments { (querySnapshot, error) in
                // Log any error that occurs
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                // Ensure the query snapshot is not nil and has documents
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No documents found")
                    return
                }
                
                // Parse the top 3 stories into an array
                var fetchedStories: [Story] = []
                for document in documents {
                    do {
                        let story = try document.data(as: Story.self) // Decode the Story object
                        fetchedStories.append(story)
                    } catch {
                        print("Error decoding Story: \(error.localizedDescription)") // Log decoding errors
                    }
                }
                
                // Update the topStories array on the main thread
                DispatchQueue.main.async {
                    self.topStories = fetchedStories
                }
            }
    }
    
    @Published var storiesByGenre: [String: [Story]] = [:] // Dictionary to hold stories grouped by genre

    private var db = Firestore.firestore() // Reference to Firestore

    /// Fetches stories that are approved and groups them by genre.
    func fetchStories() {
        db.collection("Story").whereField("status", isEqualTo: "Approve").getDocuments { [weak self] snapshot, error in
            // Log any error that occurs during fetching
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            // Ensure there are documents in the snapshot
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            // Decode stories and group them by genre
            let stories = documents.compactMap { try? $0.data(as: Story.self) }
         //   self?.storiesByGenre = Dictionary(grouping: stories, by: { $0.genre })
          
            // Group stories by genre and sort them by timeStamp
                    self?.storiesByGenre = Dictionary(grouping: stories, by: { $0.genre })
                .mapValues { $0.sorted(by: { $0.dateCreated! > $1.dateCreated! }) }
        }
    }
}
