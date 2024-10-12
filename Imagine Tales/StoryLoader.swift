//
//  StoryLoader.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/11/24.
//


import FirebaseFirestore

class StoryLoader {
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFetching = false
    var stories: [Story] = []
    
    func performSearchForStory(query: String, limit: Int = 10, completion: @escaping ([Story]?, Error?) -> Void) {
        guard !isFetching else { return }
        
        let db = Firestore.firestore()
        var queryRef: Query = db.collection("Story")
            .limit(to: limit)
        
        // Start after the last document for pagination
        if let lastDoc = lastDocumentSnapshot {
            queryRef = queryRef.start(afterDocument: lastDoc)
        }
        
        isFetching = true
        queryRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            self.isFetching = false
            
            if let error = error {
                completion(nil, error)
                print("Error getting documents: \(error)")
            } else {
                guard let snapshot = snapshot else {
                    completion([], nil)
                    return
                }
                
                let documents = snapshot.documents
                self.lastDocumentSnapshot = documents.last // Save the last document for pagination
                
                // Client-side filtering for partial and case-insensitive search
                let filteredStories = documents.compactMap { document -> Story? in
                    if let data = try? document.data(as: Story.self) {
                        // Perform case-insensitive and partial search on the desired field
                        if data.title.lowercased().contains(query.lowercased()) {
                            return data
                        }
                    }
                    return nil
                }
                
                // Append the fetched stories to the existing ones
                self.stories.append(contentsOf: filteredStories)
                
                // Return the stories in the completion handler
                completion(filteredStories, nil)
            }
        }
    }
    
    func resetPagination() {
        lastDocumentSnapshot = nil
        stories.removeAll()
    }
}