//
//  HomeViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import FirebaseFirestore
import FirebaseStorage

// ViewModel for managing home screen data and interactions
final class HomeViewModel: ObservableObject {
    // Published properties for dynamic UI updates
    @Published var stories: [Story] = []               // List of fetched stories
    @Published var genre: String = "Following"         // Currently selected genre
    @Published var status = ""                         // Status of friendship (e.g., Pending, Friends)
    @Published var friendUsernames = [String]()        // List of friend usernames
    @Published var friends = [UserChildren]()          // List of friend objects (children)
    var tempStories: [Story] = []                      // Temporary storage for fetched stories
    @Published var child: UserChildren?                // Current child profile
    
    let db = Firestore.firestore()                     // Firestore instance for database interactions
    
    // Fetch child profile by child ID from Firestore
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        // Retrieve the document as UserChildren model
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                self.child = document
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // Function to add a shared story between users
    func addSharedStory(childId: String, fromId: String, toId: String, storyId: String) {
        let sharedStoriesRef = db.collection("Children2").document(childId).collection("sharedStories")
        let newSharedStory = sharedStoriesRef.document()
        
        // Set the shared story data with fromId, toId, and storyId fields
        newSharedStory.setData([
            "id" : newSharedStory.documentID,
            "fromid": fromId,
            "toid": toId,
            "storyid": storyId
        ]) { error in
            if let error = error {
                print("Error adding shared story: \(error)")
            } else {
                print("Shared story successfully added!")
            }
        }
    }
    
    // Fetch stories based on selected genre or 'Following' list
    @MainActor
    func getStories(childId: String) async throws {
        if genre == "Following" {
            stories = []  // Clear current stories
            do {
                // Fetch friends of the child
                let friendDocuments = try await Firestore.firestore().collection("Children2").document(childId).collection("friends").getDocuments().documents
                let friendIds = friendDocuments.map { $0.documentID }
                
                // Fetch stories from friends
                for friendId in friendIds {
                    Firestore.firestore().collection("Story").whereField("childId", isEqualTo: friendId).getDocuments() { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                            return
                        }
                        // Filter and append unique stories
                        self.tempStories = querySnapshot?.documents.compactMap { document in
                            try? document.data(as: Story.self)
                        } ?? []
                        self.stories.append(contentsOf: self.tempStories.filter { tempStory in
                            !self.stories.contains(where: { $0.id == tempStory.id })
                        })
                        
                        self.stories.sort(by: { $0.dateCreated! > $1.dateCreated! })
                        
                        print(self.stories)
                    }
                }
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        } else {
            // Fetch stories based on genre and approval status
            Firestore.firestore().collection("Story").whereField("status", isEqualTo: "Approve").whereField("genre", isEqualTo: genre).getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                self.stories = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Story.self)
                } ?? []
                
                self.stories.sort(by: { $0.dateCreated! > $1.dateCreated! })
                print(self.stories)
            }
        }
    }
    
    // Function to like or dislike a story
    func likeStory(childId: String, storyId: String) {
        let storyRef = db.collection("Story").document(storyId)
        let likesRef = storyRef.collection("likes")
        let query = likesRef.whereField("childId", isEqualTo: childId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking likes: \(error)")
                return
            }
            // If story is not liked, like it
            if let snapshot = snapshot, snapshot.isEmpty {
                let likeData: [String: Any] = ["childId": childId, "timestamp": Timestamp()]
                likesRef.addDocument(data: likeData) { error in
                    if let error = error {
                        print("Error liking story: \(error)")
                    } else {
                        storyRef.updateData(["likes": FieldValue.increment(Int64(1))]) { error in
                            if let error = error {
                                print("Error updating like count: \(error)")
                            } else {
                                print("Story liked successfully!")
                            }
                        }
                    }
                }
            } else {
                // If already liked, dislike the story
                if let document = snapshot?.documents.first {
                    document.reference.delete() { error in
                        if let error = error {
                            print("Error disliking story: \(error)")
                        } else {
                            storyRef.updateData(["likes": FieldValue.increment(Int64(-1))]) { error in
                                if let error = error {
                                    print("Error updating like count: \(error)")
                                } else {
                                    print("Story disliked successfully!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Check if a child liked the story
    func checkIfChildLikedStory(childId: String, storyId: String, completion: @escaping (Bool) -> Void) {
        let likesRef = db.collection("Story").document(storyId).collection("likes")
        
        likesRef.whereField("childId", isEqualTo: childId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking if child liked the story: \(error)")
                completion(false)
                return
            }
            completion(snapshot?.isEmpty == false)
        }
    }
    
    // Toggle save/unsave status of a story
    func toggleSaveStory(childId: String, storyId: String) {
        let savedStoriesRef = db.collection("Children2").document(childId).collection("savedStories")
        let query = savedStoriesRef.whereField("storyId", isEqualTo: storyId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking saved stories: \(error)")
                return
            }
            if snapshot?.isEmpty == true {
                // Save the story if not already saved
                let saveData: [String: Any] = ["storyId": storyId, "timestamp": Timestamp()]
                savedStoriesRef.addDocument(data: saveData) { error in
                    if let error = error {
                        print("Error saving story: \(error)")
                    } else {
                        print("Story saved successfully!")
                    }
                }
            } else {
                // Unsave the story if already saved
                if let document = snapshot?.documents.first {
                    document.reference.delete() { error in
                        if let error = error {
                            print("Error unsaving story: \(error)")
                        } else {
                            print("Story unsaved successfully!")
                        }
                    }
                }
            }
        }
    }
    
    // Check if a child has saved the story
    func checkIfChildSavedStory(childId: String, storyId: String, completion: @escaping (Bool) -> Void) {
        let savedStoriesRef = db.collection("Children2").document(childId).collection("savedStories")
        
        savedStoriesRef.whereField("storyId", isEqualTo: storyId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking if child saved the story: \(error)")
                completion(false)
                return
            }
            completion(snapshot?.isEmpty == false)
        }
    }
    
    // Send a friend request from one child to another
    func sendFriendRequest(toChildId: String, fromChildId: String) {
        let friendRequestData: [String: Any] = [
            "fromUserId": fromChildId,
            "status": "pending"
        ]
        let requestRef = db.collection("Children2").document(toChildId).collection("friendRequests").document(fromChildId)
        
        requestRef.setData(friendRequestData) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
            } else {
                print("Friend request sent successfully!")
            }
        }
    }
    
    // Function to check the friendship status between two children
    func checkFriendshipStatus(childId: String, friendChildId: String) {
        let db = Firestore.firestore() // Reference to Firestore
        let userRef = db.collection("Children2").document(childId) // Access the document of the current child in the 'Children2' collection
        let friendRequestRef = db.collection("Children2").document(friendChildId).collection("friendRequests").document(childId) // Access the friend requests for the other child
        
        // Step 1: Check if the users are already friends
        userRef.collection("friends").document(friendChildId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                // If the document exists, it means they are already friends
                self?.status = "Friends" // Update the status to 'Friends'
                return // Exit the function if they are already friends
            }
            
            // Step 2: If they are not friends, check if a friend request is pending
            friendRequestRef.getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    // If a friend request exists, the status is 'Pending'
                    self?.status = "Pending"
                } else {
                    // If no friend request exists, the status is 'Send Request'
                    self?.status = "Send Request"
                }
            }
        }
    }
    
    // Function to fetch all friends of a child
    func fetchFriends(childId: String) {
        self.friends.removeAll() // Clear the current list of friends to avoid duplication
        let db = Firestore.firestore() // Reference to Firestore
        
        // Listen for changes in the 'friends' sub-collection of the current child
        db.collection("Children2").document(childId).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                // Handle any errors that occur during fetching
                print("Error fetching friends: \(error.localizedDescription)")
            } else {
                // If snapshot exists, process the data
                if let snapshot = snapshot {
                    // Extract the 'friendUserId' from each document and store it in the 'friendUsernames' array
                    self.friendUsernames = snapshot.documents.compactMap { $0["friendUserId"] as? String }
                    
                    // Once the friend usernames are fetched, fetch the full details of each child
                    self.fetchChildren()
                }
            }
        }
    }
    
    // Function to fetch details of friends using their usernames
    func fetchChildren() {
        let db = Firestore.firestore() // Reference to Firestore
        
        // Clear the existing friends list before fetching new data
        self.friends.removeAll()
        
        // Iterate through each friend username to fetch their corresponding document from Firestore
        for childId in friendUsernames {
            let docRef = db.collection("Children2").document(childId) // Reference the document of each friend
            
            // Fetch the document and decode it into a 'UserChildren' object
            docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    // If successful, append the friend's data to the 'friends' array
                    self.friends.append(document)
                    print(self.friends) // Log the fetched friends
                case .failure(let error):
                    // If there is an error, print it
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // Function to get the profile image of a user
    // The completion handler returns the URL of the profile image if available, otherwise returns nil
    func getProfileImage(documentID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore() // Reference to Firestore
        let collectionRef = db.collection("Children2") // Access the 'Children2' collection where user data is stored
        
        // Fetch the document for the specific child/user
        collectionRef.document(documentID).getDocument { document, error in
            if let error = error {
                // Log an error if the document retrieval fails
                print("Error getting document: \(error)")
                completion(nil) // Return nil if there is an error
                return
            }
            
            // If the document exists, try to retrieve the 'profileImage' field
            if let document = document, document.exists {
                let profileImage = document.get("profileImage") as? String
                completion(profileImage) // Return the profile image URL if available
            } else {
                // Handle case where the document does not exist
                print("Document does not exist")
                completion(nil) // Return nil if the document doesn't exist
            }
        }
    }
}
