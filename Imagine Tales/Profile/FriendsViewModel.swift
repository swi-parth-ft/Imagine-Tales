//
//  FriendsViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseFirestore

// The ViewModel responsible for managing friends and friend requests
final class FriendsViewModel: ObservableObject {
    
    @Published var friends = [String]()                   // Array of friend user IDs
    @Published var friendRequests = [(requestId: String, fromUserId: String)]() // Array of friend requests
    @Published var child: UserChildren?                   // Current child user information
    @Published var children: [UserChildren] = []          // List of children (friends) details
    @Published var friendReqIds = [String]()              // Array of friend request user IDs
    
    // Fetch the list of friends for a specific child
    func fetchFriends(childId: String) {
        self.children.removeAll() // Clear the existing children array
        let db = Firestore.firestore()
        
        // Listen to changes in the friend's collection
        db.collection("Children2").document(childId).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    // Extract friend user IDs from the fetched documents
                    self.friends = snapshot.documents.compactMap { $0["friendUserId"] as? String }
                    self.fetchChildren() // Fetch details of the friends
                }
            }
        }
    }
    
    // Fetch pending friend requests for a specific child
    func fetchFriendRequests(childId: String) {
        let db = Firestore.firestore()
        
        // Listen to changes in the friend requests collection
        db.collection("Children2").document(childId).collection("friendRequests").whereField("status", isEqualTo: "pending").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching friend requests: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    // Extract friend request user IDs
                    self.friendReqIds = snapshot.documents.compactMap { $0["fromUserId"] as? String }
                    self.fetchChildrenFromReqs() // Fetch details of users who sent requests
                    // Extract request details
                    self.friendRequests = snapshot.documents.compactMap {
                        let requestId = $0.documentID
                        let fromUserId = $0["fromUserId"] as? String ?? ""
                        return (requestId: requestId, fromUserId: fromUserId)
                    }
                    print(self.friendRequests) // Print friend requests for debugging
                    print(self.friendReqIds)    // Print friend request IDs for debugging
                }
            }
        }
    }
    
    // Respond to a specific friend request
    func respondToFriendRequest(childId: String, requestId: String, response: String, friendUserId: String) {
        let db = Firestore.firestore()
        
        // Update the friend request status in Firestore
        db.collection("Children2").document(childId).collection("friendRequests").document(requestId).updateData([
            "status": response
        ]) { error in
            if let error = error {
                print("Error updating friend request: \(error.localizedDescription)")
            } else {
                print("Friend request updated to \(response) successfully!")
                
                if response == "accepted" {
                    // If accepted, add both users as friends
                    self.addFriends(forUserId: childId, friendUserId: friendUserId)
                    self.addFriends(forUserId: friendUserId, friendUserId: childId)
                }
            }
        }
    }
    
    // Add a friend to a user's friend list
    func addFriends(forUserId userId: String, friendUserId: String) {
        let db = Firestore.firestore()
        
        // Create a dictionary for the friend's data
        let userFriendData: [String: Any] = [
            "friendUserId": friendUserId,
            "addedDate": Date() // Store the date when the friend was added
        ]
        
        // Add friend data to Firestore
        db.collection("Children2").document(userId).collection("friends").document(friendUserId).setData(userFriendData) { error in
            if let error = error {
                print("Error adding friend: \(error.localizedDescription)")
            } else {
                print("Friend added successfully!")
            }
        }
    }
    
    // Fetch a specific child by ID
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        // Get the document as UserChildren
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                self.child = document // Assign fetched child document to the property
            case .failure(let error):
                print(error.localizedDescription) // Handle errors
            }
        }
    }
    
    // Fetch details of friends from their user IDs
    func fetchChildren() {
        let db = Firestore.firestore()
        
        self.children.removeAll() // Clear existing children data
        
        for childId in friends {
            let docRef = db.collection("Children2").document(childId)
            
            // Get each friend's document as UserChildren
            docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    self.children.append(document) // Append the fetched document to the children array
                case .failure(let error):
                    print(error.localizedDescription) // Handle errors
                }
            }
        }
    }
    
    // Fetch details of users who sent friend requests
    func fetchChildrenFromReqs() {
        let db = Firestore.firestore()
        
        self.children.removeAll() // Clear existing children data
        
        for childId in friendReqIds {
            let docRef = db.collection("Children2").document(childId)
            
            // Get each request sender's document as UserChildren
            docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    self.children.append(document) // Append the fetched document to the children array
                case .failure(let error):
                    print(error.localizedDescription) // Handle errors
                }
            }
        }
    }

    // Delete a specific friend request
    func deleteRequest(childId: String, docID: String) {
        let db = Firestore.firestore()
        
        // Remove the friend request document from Firestore
        db.collection("Children2").document(childId).collection("friendRequests").document(docID).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    // Remove a friend from a user's friend list
    func removeFriend(childId: String, docID: String) {
        let db = Firestore.firestore()
        
        // Remove the friend document from Firestore
        db.collection("Children2").document(childId).collection("friends").document(docID).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
