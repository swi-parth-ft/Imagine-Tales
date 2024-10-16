//
//  ParentViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging

// ViewModel for managing parent-related data and interactions
final class ParentViewModel: ObservableObject {
    
    @Published var children: [UserChildren] = [] // List of children associated with the parent
    @Published var story: [Story] = [] // List of stories associated with the children
    @Published var name: String = "" // Parent's name
    @Published var age: String = "" // Parent's age
    @Published var parent: UserModel? // Current parent user model
    @Published var username: String = "" // Parent's username
    @AppStorage("dpurl") private var dpUrl = "" // Profile image URL for storage
    var childId = "" // Selected child's ID
    @Published var numberOfFriends = 0 // Count of friends for the selected child
    @Published var imageUrl = "" // URL for the child's image
    @Published var comment = "" // Parent's review comment
    @Published var storyCount: Int = 0
    @Published var parentId = ""
    // Fetch reviews and comments for a specific story
    func fetchStoryAndReview(storyID: String) {
        let db = Firestore.firestore()
        
        db.collection("reviews").whereField("storyID", isEqualTo: storyID).getDocuments { snapshot, error in
            if let snapshot = snapshot, let document = snapshot.documents.first {
                let reviewNotes = document.data()["parentReviewNotes"] as? String // Get review notes from document
                self.comment = reviewNotes ?? "" // Update comment state
            } else {
                self.comment = "" // Reset comment if no document found
            }
        }
    }

    // Add a review for a specific story
    func addReview(storyID: String, reviewNotes: String) {
        let db = Firestore.firestore()
        
        let reviewData: [String: Any] = [
            "storyID": storyID,
            "parentReviewNotes": reviewNotes // Data to be added to Firestore
        ]
        
        db.collection("reviews").addDocument(data: reviewData) { error in
            if let error = error {
                print("Error adding review: \(error)") // Error handling
            } else {
                print("Review successfully added") // Success message
            }
        }
    }

    // Get the number of friends for a specific child
    func getFriendsCount(childId: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2").document(childId).collection("friends")
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)") // Error handling
            } else {
                let documentCount = querySnapshot?.count ?? 0 // Count documents in the collection
                print("Number of documents: \(documentCount)")
                self.numberOfFriends = documentCount // Update the number of friends
            }
        }
    }
    
    // Delete a child from the children list and Firestore
    func deleteChild(at offsets: IndexSet) {
        offsets.forEach { index in
            let childToDelete = children[index] // Identify child to delete
            if let indexToRemove = children.firstIndex(where: { $0.id == childToDelete.id }) {
                deleteChildFromFirebase(child: children[indexToRemove]) // Delete from Firebase
                do {
                    try getChildren() // Refresh the children list
                } catch {
                    print(error.localizedDescription) // Error handling
                }
            }
        }
    }

    // Remove a child document from Firestore
    func deleteChildFromFirebase(child: UserChildren) {
        Firestore.firestore().collection("Children2").document(child.id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)") // Error handling
            } else {
                print("Document successfully removed!") // Success message
            }
        }
    }
    
    // Delete a specific story from Firestore
    func deleteStory(storyId: String) {
        Firestore.firestore().collection("Story").document(storyId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)") // Error handling
            } else {
                print("Document successfully removed!") // Success message
            }
        }
    }
    
    // Log out the user
    func logOut() throws {
        try AuthenticationManager.shared.signOut() // Call sign-out method from AuthenticationManager
    }
    
    // Fetch children associated with the logged-in parent
    func getChildren() throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // Get authenticated user
        self.parentId = authDataResult.uid
        Firestore.firestore().collection("Children2").whereField("parentId", isEqualTo: authDataResult.uid).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)") // Error handling
                return
            }
            
            self.children = querySnapshot?.documents.compactMap { document in
                try? document.data(as: UserChildren.self) // Map documents to UserChildren model
            } ?? []
            print(self.children) // Print fetched children
        }
    }
    
    // Fetch stories for a specific child
    func getStory(childId: String) throws {
        Firestore.firestore().collection("Story").whereField("childId", isEqualTo: childId).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)") // Error handling
                return
            }
            
            self.story = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Story.self) // Map documents to Story model
            } ?? []
            self.story.sort(by: { $0.dateCreated! > $1.dateCreated! })
            print(self.story) // Print fetched stories
        }
    }
    private var lastDocument: DocumentSnapshot? = nil
    private let limit = 10  // Set a limit of 10 stories per batch
    
    // Function to load stories with pagination
    @MainActor
    func getStorie(isLoadMore: Bool = false, childId: String) async {
        // Reset the stories and pagination if not loading more
        if !isLoadMore {
            story = []
            lastDocument = nil
        }
        
        do {
            // Fetch a batch of stories from Firestore
            let (newStories, lastDoc) = try await StoriesManager.shared.getAllMyStories(count: limit, childId: childId, lastDocument: lastDocument)
            
            // Update UI in main thread
            DispatchQueue.main.async {
                for newStory in newStories {
                    if !self.story.contains(where: { $0.id == newStory.id }) {
                        self.story.append(newStory)
                        }
                    }
               // self.story.append(contentsOf: newStories)
                self.lastDocument = lastDoc // Update last document for pagination
            }
        } catch {
            print("Error fetching stories: \(error.localizedDescription)")
        }
    }
    
    func countDocumentsWithChildId(childId: String) {
            let db = Firestore.firestore()
            let collectionRef = db.collection("Story")

            // Perform a filtered aggregation query based on childId
            collectionRef.whereField("childId", isEqualTo: childId)
                .count
                .getAggregation(source: .server) { (snapshot, error) in
                    if let error = error {
                        print("Error fetching document count: \(error.localizedDescription)")
                        return
                    }

                    if let snapshot = snapshot {
                        self.storyCount = Int(truncating: snapshot.count)
                    }
                }
        }
    
    // Fetch parent details from Firestore
    func fetchParent() throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // Get authenticated user
        let docRef = Firestore.firestore().collection("users").document(authDataResult.uid)
        
        docRef.getDocument(as: UserModel.self) { result in
            switch result {
            case .success(let document):
                self.parent = document // Set parent user model
            case .failure(let error):
                print(error.localizedDescription) // Error handling
            }
        }
    }
    
    // Add a new child to the database
    func addChild() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // Get authenticated user
        
        let _ = try await UserManager.shared.addChild(userId: authDataResult.uid, name: name, age: age) // Add child with basic info
        let _ = try await UserManager.shared.addChild2(userId: authDataResult.uid, name: name, age: age, username: username, imageUrl: imageUrl) // Add child with additional info
    }
    
    // Update story status in Firestore
    func reviewStory(status: String, id: String) throws {
        Firestore.firestore().collection("Story").document(id).updateData(["status": status]) // Update document status
    }
    
    // Fetch profile image URL from Firebase Storage
    func fetchProfileImage(dp: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Assuming the profilePicture field contains "1.jpg", "2.jpg", etc.
        let imageRef = storageRef.child("profileImages/\(dp)") // Reference to the image in storage
        
        // Fetch the download URL
        imageRef.downloadURL { url, error in
            if let error = error {
                print("Error fetching image URL: \(error)") // Error handling
                return
            }
            if let url = url {
                self.dpUrl = url.absoluteString // Update the profile image URL
            }
        }
    }
    
    func updateNameInFirestore(userId: String, newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        // Reference to the specific document
        let documentRef = db.collection("users").document(userId)
        
        // Update the name field
        documentRef.updateData(["name": newName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Fetch the FCM token and update Firestore with the selected child's token
    func removeFCMToken(childId: String) {
        if let fcmToken = Messaging.messaging().fcmToken {
            Firestore.firestore().collection("Children2").document(childId).updateData([
                "fcmToken": ""
            ]) { error in
                if let error = error {
                    print("Error updating FCM token: \(error)")
                } else {
                    print("FCM token updated for \(childId)")
                }
            }
        }
    }
    
    // Fetch the FCM token and update Firestore with the selected child's token
    func AddFCMToken(childId: String) {
        if let fcmToken = Messaging.messaging().fcmToken {
            let currentChildId = childId // Get the active child ID from your app logic
            
            let childRef = Firestore.firestore().collection("Children2").document(currentChildId)

                // Check if the child document exists
                childRef.getDocument { (document, error) in
                    if let error = error {
                        print("Error fetching child document: \(error.localizedDescription)")
                        return
                    }

                    // If the document does not exist, create it with the fcmToken
                    if let document = document, document.exists {
                        // Document exists, update the fcmToken
                        childRef.updateData([
                            "fcmToken": fcmToken
                        ]) { error in
                            if let error = error {
                                print("Error updating FCM token: \(error.localizedDescription)")
                            } else {
                                print("FCM token updated successfully for child ID: \(currentChildId)")
                            }
                        }
                    } else {
                        // Document does not exist, create it with the fcmToken
                        let childData: [String: Any] = [
                            "fcmToken": fcmToken // Initialize the fcmToken field
                        ]
                        childRef.setData(childData) { error in
                            if let error = error {
                                print("Error creating child document: \(error.localizedDescription)")
                            } else {
                                print("Child document created successfully with FCM token for ID: \(currentChildId)")
                            }
                        }
                    }
                }
        }
    }
    
    // Fetch the FCM token and update Firestore with the selected parent's token
    func removeFCMTokenParent(parentId: String) {
        if let fcmToken = Messaging.messaging().fcmToken {
            Firestore.firestore().collection("users").document(parentId).updateData([
                "fcmToken": ""
            ]) { error in
                if let error = error {
                    print("Error updating FCM token: \(error)")
                } else {
                    print("FCM token updated for \(parentId)")
                }
            }
        }
    }
    
    // Fetch the FCM token and update Firestore with the selected parent's token
    func AddFCMTokenParent(parentId: String) {
        if let fcmToken = Messaging.messaging().fcmToken {
            
            
            let parentRef = Firestore.firestore().collection("users").document(parentId)

                // Check if the child document exists
            parentRef.getDocument { (document, error) in
                    if let error = error {
                        print("Error fetching parent document: \(error.localizedDescription)")
                        return
                    }

                    // If the document does not exist, create it with the fcmToken
                    if let document = document, document.exists {
                        // Document exists, update the fcmToken
                        parentRef.updateData([
                            "fcmToken": fcmToken
                        ]) { error in
                            if let error = error {
                                print("Error updating FCM token: \(error.localizedDescription)")
                            } else {
                                print("FCM token updated successfully for parent ID: \(parentId)")
                            }
                        }
                    } else {
                        // Document does not exist, create it with the fcmToken
                        let parentData: [String: Any] = [
                            "fcmToken": fcmToken // Initialize the fcmToken field
                        ]
                        parentRef.setData(parentData) { error in
                            if let error = error {
                                print("Error creating parent document: \(error.localizedDescription)")
                            } else {
                                print("Parent document created successfully with FCM token for ID: \(parentId)")
                            }
                        }
                    }
                }
        }
    }
}
