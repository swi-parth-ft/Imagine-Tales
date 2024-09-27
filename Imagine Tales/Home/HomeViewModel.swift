//
//  HomeViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//
import FirebaseFirestore
import FirebaseStorage

final class HomeViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var genre: String = "Following"
    @Published var status = ""
    @Published var friendUsernames = [String]()
    @Published var friends = [UserChildren]()
    var tempStories: [Story] = []
    @Published var child: UserChildren?
    
    let db = Firestore.firestore()
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                self.child = document
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    // Function to add a shared story
    func addSharedStory(childId: String, fromId: String, toId: String, storyId: String) {
        // Access the specific child document in the 'Children2' collection
        let sharedStoriesRef = db.collection("Children2").document(childId).collection("sharedStories")
        
        // Create a new document in 'sharedStories'
        let newSharedStory = sharedStoriesRef.document()
        
        // Set data with fromId, toId, and storyId
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
    
    @MainActor
    func getStories(childId: String) async throws {
        if genre == "Following" {
            stories = []
            do {
                    let friendDocuments = try await Firestore.firestore().collection("Children2").document(childId).collection("friends").getDocuments().documents
                    let friendIds = friendDocuments.map { $0.documentID }

                for friendId in friendIds {
                /*    let storyDocuments: Void = try await*/ Firestore.firestore().collection("Story").whereField("childId", isEqualTo: friendId).getDocuments() { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                            return
                        }
                        
                        self.tempStories = querySnapshot?.documents.compactMap { document in
                            try? document.data(as: Story.self)
                        } ?? []
                    self.stories.append(contentsOf: self.tempStories.filter { tempStory in
                        !self.stories.contains(where: { $0.id == tempStory.id })
                    })
                      //  self.stories.append(contentsOf: self.tempStories)
                        print(self.stories)
                    }
                }
                    
                } catch {
                    print("Error fetching data: \(error.localizedDescription)")
                }
        } else {
            Firestore.firestore().collection("Story").whereField("status", isEqualTo: "Approve").whereField("genre", isEqualTo: genre).getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                self.stories = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Story.self)
                } ?? []
                print(self.stories)
                
            }
        }
    }
    
    func likeStory(childId: String, storyId: String) {
        let db = Firestore.firestore()
        let storyRef = db.collection("Story").document(storyId)
        let likesRef = storyRef.collection("likes")
        let query = likesRef.whereField("childId", isEqualTo: childId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking likes: \(error)")
                return
            }
            
            if let snapshot = snapshot, snapshot.isEmpty {
                // Child has not liked this story, proceed to like it
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
                // Child has already liked this story, proceed to dislike it
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
    
    func checkIfChildLikedStory(childId: String, storyId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let storyRef = db.collection("Story").document(storyId)
        let likesRef = storyRef.collection("likes")
        
        likesRef.whereField("childId", isEqualTo: childId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking if child liked the story: \(error)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func toggleSaveStory(childId: String, storyId: String) {
        let db = Firestore.firestore()
        let childRef = db.collection("Children2").document(childId)
        let savedStoriesRef = childRef.collection("savedStories")
        let query = savedStoriesRef.whereField("storyId", isEqualTo: storyId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking saved stories: \(error)")
                return
            }
            
            if let snapshot = snapshot, snapshot.isEmpty {
                // Story is not saved, proceed to save it
                let saveData: [String: Any] = ["storyId": storyId, "timestamp": Timestamp()]
                savedStoriesRef.addDocument(data: saveData) { error in
                    if let error = error {
                        print("Error saving story: \(error)")
                    } else {
                        print("Story saved successfully!")
                    }
                }
            } else {
                // Story is already saved, proceed to unsave it
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
    
    func checkIfChildSavedStory(childId: String, storyId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let childRef = db.collection("Children2").document(childId)
        let savedStoriesRef = childRef.collection("savedStories")
        
        savedStoriesRef.whereField("storyId", isEqualTo: storyId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking if child saved the story: \(error)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func sendFriendRequest(toChildId: String, fromChildId: String) {
            let db = Firestore.firestore()
            let friendRequestData: [String: Any] = [
                "fromUserId": fromChildId,
                "status": "pending"
            ]
            
        // Use toChildId as the document ID for the friend request
        let requestRef = db.collection("Children2").document(toChildId).collection("friendRequests").document(fromChildId)
            
            // Set the data for the friend request document
            requestRef.setData(friendRequestData) { error in
                if let error = error {
                    print("Error sending friend request: \(error.localizedDescription)")
                } else {
                    print("Friend request sent successfully!")
                }
            }
        }
    
    func checkFriendshipStatus(childId: String, friendChildId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Children2").document(childId)
        let friendRequestRef = db.collection("Children2").document(friendChildId).collection("friendRequests").document(childId)
          
          // Check if already friends
          userRef.collection("friends").document(friendChildId).getDocument { [weak self] (document, error) in
              if let document = document, document.exists {
                  self?.status = "Friends"
                  return
              }
              
              // Check for pending requests
              friendRequestRef.getDocument { [weak self] (document, error) in
                  if let document = document, document.exists  {
                      self?.status = "Pending"
                  } else {
                      self?.status = "Send Request"
                  }
              }
          }
      }
    
    func fetchFriends(childId: String) {
        self.friends.removeAll()
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    self.friendUsernames = snapshot.documents.compactMap { $0["friendUserId"] as? String }
                    
                    self.fetchChildren()
                }
            }
        }
    }
    
    func fetchChildren() {
            let db = Firestore.firestore()
            
            // Clear the existing array
        self.friends.removeAll()
            
            for childId in friendUsernames {
                let docRef = db.collection("Children2").document(childId)
                
                docRef.getDocument(as: UserChildren.self) { result in
                    switch result {
                    case .success(let document):
                        self.friends.append(document)
                        print(self.friends)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }

    func getProfileImage(documentID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2") // Replace with your collection name

        collectionRef.document(documentID).getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
                return
            }

            if let document = document, document.exists {
                let profileImage = document.get("profileImage") as? String
                completion(profileImage)
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
}
