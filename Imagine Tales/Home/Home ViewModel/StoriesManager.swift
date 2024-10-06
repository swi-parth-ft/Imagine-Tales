//
//  StoriesManager.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class StoriesManager {
    static let shared = StoriesManager()
    private let storiesCollection = Firestore.firestore().collection("Story")
//    private let savedStories = Firestore.firestore().collection("Children2").document(childId).collection("savedStories")
    // Fetch stories with pagination support
    func getAllStories(count: Int, genre: String, lastDocument: DocumentSnapshot?) async throws -> (stories: [Story], lastDocument: DocumentSnapshot?) {
        var query: Query = storiesCollection
            .whereField("status", isEqualTo: "Approve")
            .whereField("genre", isEqualTo: genre)
            .order(by: "dateCreated", descending: true)  // Order by date
        
        // Start query after last document if pagination exists
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        // Limit the results
        let snapshot = try await query.limit(to: count).getDocuments()
        
        let stories = try snapshot.documents.map { try $0.data(as: Story.self) }
        return (stories, snapshot.documents.last) // Return last document for pagination
    }
    
    func getAllFollowing(count: Int, genre: String, ids: [String], lastDocument: DocumentSnapshot?) async throws -> (stories: [Story], lastDocument: DocumentSnapshot?) {
        guard !ids.isEmpty else {
            return ([], nil)  // Handle empty IDs safely
        }
        
        // Split the ids into batches of 10, as Firestore limits 'in' queries to 10 items.
        let idBatches = ids.chunked(into: 10)
        var allStories: [Story] = []
        var lastDoc: DocumentSnapshot? = nil

        for batch in idBatches {
            var query: Query = storiesCollection
                .whereField("status", isEqualTo: "Approve")
                .whereField("childId", in: batch)
                .order(by: "dateCreated", descending: true)

            // Start query after last document if pagination exists
            if let lastDocument = lastDocument {
                query = query.start(afterDocument: lastDocument)
            }

            // Fetch stories from the current batch
            let snapshot = try await query.limit(to: count).getDocuments()
            
            // Append stories from this batch to the overall result
            let batchStories = try snapshot.documents.map { try $0.data(as: Story.self) }
            allStories.append(contentsOf: batchStories)

            // Update the last document for pagination
            lastDoc = snapshot.documents.last
            
            // If we've fetched enough stories, stop querying
            if allStories.count >= count {
                break
            }
        }

        // Limit the total stories to the requested count
        let limitedStories = Array(allStories.prefix(count))
        
        return (limitedStories, lastDoc)
    }
    
    func getAllMyStories(count: Int, childId: String, lastDocument: DocumentSnapshot?) async throws -> (stories: [Story], lastDocument: DocumentSnapshot?) {
        
        var query: Query = storiesCollection
            .whereField("childId", isEqualTo: childId)
            .order(by: "dateCreated", descending: true)  // Order by date
        
        // Start query after last document if pagination exists
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        // Limit the results
        let snapshot = try await query.limit(to: count).getDocuments()
        
        let stories = try snapshot.documents.map { try $0.data(as: Story.self) }
        return (stories, snapshot.documents.last) // Return last document for pagination
    }
    
    func getAllMyFriendsStories(count: Int, childId: String, lastDocument: DocumentSnapshot?) async throws -> (stories: [Story], lastDocument: DocumentSnapshot?) {
        
        var query: Query = storiesCollection
            .whereField("status", isEqualTo: "Approve")
            .whereField("childId", isEqualTo: childId)
            .order(by: "dateCreated", descending: true)  // Order by date
        
        // Start query after last document if pagination exists
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        // Limit the results
        let snapshot = try await query.limit(to: count).getDocuments()
        
        let stories = try snapshot.documents.map { try $0.data(as: Story.self) }
        return (stories, snapshot.documents.last) // Return last document for pagination
    }
    
    func getAllMySavedStories(count: Int, childId: String, lastDocument: DocumentSnapshot?) async throws -> (storyIds: [String], lastDocument: DocumentSnapshot?) {
        
        var query: Query = Firestore.firestore().collection("Children2").document(childId).collection("savedStories")
            .order(by: "timestamp", descending: true)  // Order by date
        
        // Start query after last document if pagination exists
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        // Limit the results
        let snapshot = try await query.limit(to: count).getDocuments()
        let storyIds = snapshot.documents.compactMap { $0.data()["storyId"] as? String }
       // let stories = try snapshot.documents.map { try $0.data(as: Story.self) }
        print("Story IDs: \(storyIds)")
        return (storyIds, snapshot.documents.last) // Return last document for pagination
    }
    
    // Function to fetch a story by its storyId
        func getStory(by storyId: String) async throws -> Story {
            let storyRef = Firestore.firestore().collection("Story").document(storyId)
            
            // Fetch the document
            let document = try await storyRef.getDocument()
            
            // Ensure the document exists and can be decoded into a Story
            guard let data = document.data() else {
                throw NSError(domain: "StoryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Story not found"])
            }
            
            // Decode the document into a Story model
            let story = try Firestore.Decoder().decode(Story.self, from: data)
            return story
        }
}
