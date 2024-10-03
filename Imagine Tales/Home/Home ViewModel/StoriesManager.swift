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
        print(ids)
        print("Querying with status: 'Approve', childId: \(ids), genre: '\(genre)'")
        var query: Query = storiesCollection
            .whereField("status", isEqualTo: "Approve")
            .whereField("childId", in: ids)
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
}
