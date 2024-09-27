//
//  ProfileViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseFirestore

/// ViewModel responsible for managing profile-related data and interactions.
final class ProfileViewModel: ObservableObject {
    
    // Published properties to trigger UI updates when values change
    @Published private(set) var user: AuthDataResultModel? = nil // Authenticated user data
    @Published var child: UserChildren? // Child user's data
    @Published var pin: String = "" // User's pin for access control
    @Published var profileURL = "" // URL for the child's profile image
    @Published var numberOfFriends = 0 // Count of the child's friends
    @Published var imageURL: String = "" // URL for any additional images (not used currently)

    /// Load the authenticated user data
    func loadUser() throws {
        user = try AuthenticationManager.shared.getAuthenticatedUser() // Fetch the authenticated user
    }

    /// Log out the current user
    func logOut() throws {
        try AuthenticationManager.shared.SignOut() // Sign out the user
    }

    /// Fetch child data from Firestore based on the child's ID
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId) // Reference to the child document
        
        docRef.getDocument(as: UserChildren.self) { result in // Fetch document
            switch result {
            case .success(let document):
                self.child = document // Set child data
                self.profileURL = document.profileImage // Update profile URL
            case .failure(let error):
                print(error.localizedDescription) // Log any errors
            }
        }
    }

    /// Fetch the user's pin from Firestore
    func getPin() throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // Get the current user
        Firestore.firestore().collection("users").document(authDataResult.uid).getDocument { doc, error in
            if let doc = doc, doc.exists {
                self.pin = doc.get("pin") as? String ?? "0" // Retrieve the pin or default to "0"
                print(self.pin) // Debug print the pin
            }
        }
    }

    /// Fetch the count of friends for a given child ID
    func getFriendsCount(childId: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2").document(childId).collection("friends") // Reference to friends collection
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)") // Log any errors
            } else {
                let documentCount = querySnapshot?.count ?? 0 // Count the number of friends
                print("Number of documents: \(documentCount)") // Debug print the count
                self.numberOfFriends = documentCount // Update the number of friends
            }
        }
    }

    /// Update the child's username in Firestore
    func updateUsername(childId: String, username: String) {
        let db = Firestore.firestore() // Reference to Firestore database
        let documentReference = db.collection("Children2").document(childId) // Reference to child's document
        
        // Data to update
        let updatedData: [String: Any] = [
            "username": username // Update the username field
        ]
        
        // Perform the update
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)") // Log errors
            } else {
                print("Document successfully updated!") // Confirm success
            }
        }
    }

    /// Fetch the profile image URL for a given document ID
    func getProfileImage(documentID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2") // Reference to children collection
        
        collectionRef.document(documentID).getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)") // Log any errors
                completion(nil) // Return nil if there's an error
                return
            }
            
            if let document = document, document.exists {
                let profileImage = document.get("profileImage") as? String // Get the profile image URL
                completion(profileImage) // Return the profile image URL
            } else {
                print("Document does not exist") // Log if the document does not exist
                completion(nil) // Return nil if it doesn't exist
            }
        }
    }
    
    @Published var sharedStories: [SharedStory] = [] // Array to hold shared stories

    /// Fetch shared stories for the given child ID
    func fetchSharedStories(childId: String) {
        self.sharedStories.removeAll() // Clear any existing shared stories
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("sharedStories").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching shared stories: \(error.localizedDescription)") // Log any errors
            } else {
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        // Extract story data from the document
                        let storyId = document["storyid"] as? String ?? ""
                        let fromId = document["fromid"] as? String ?? ""
                        let id = document["id"] as? String ?? ""
                        // Fetch the whole story using the story ID
                        self.fetchWholeStory(storyId: storyId, fromId: fromId, id: id)
                    }
                }
            }
        }
    }

    /// Fetch the entire story details for a given story ID
    func fetchWholeStory(storyId: String, fromId: String, id: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Story").document(storyId) // Reference to the story document
        
        docRef.getDocument(as: Story.self) { result in // Fetch the story document
            switch result {
            case .success(let story):
                let sharedStory = SharedStory(id: id, story: story, fromId: fromId) // Create a shared story object
                self.sharedStories.append(sharedStory) // Add it to the shared stories array
                print(self.sharedStories) // Debug print the shared stories
            case .failure(let error):
                print(error.localizedDescription) // Log any errors
            }
        }
    }

    /// Delete a shared story from Firestore
    func deleteSharedStory(childId: String, id: String) {
        let db = Firestore.firestore() // Reference to Firestore database
        // Perform the delete operation
        db.collection("Children2").document(childId).collection("sharedStories").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)") // Log any errors
            } else {
                print("Document successfully removed!") // Confirm successful deletion
            }
        }
    }
}
