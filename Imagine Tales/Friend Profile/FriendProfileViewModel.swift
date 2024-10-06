//
//  FriendProfileViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/6/24.
//
import FirebaseFirestore

final class FriendProfileViewModel: ObservableObject {
    @Published var child: UserChildren?
    @Published var numberOfFriends = 0
    @Published var story: [Story] = []
    @Published var profileImage = ""
    @Published var isFriendRequest = false
    @Published var storyCount: Int = 0
    @Published var status = ""
    private var lastDocument: DocumentSnapshot? = nil
    private let limit = 10  // Set a limit of 10 stories per batch
    
    func getStory(childId: String) throws {
       
        Firestore.firestore().collection("Story").whereField("childId", isEqualTo: childId).whereField("status", isEqualTo: "Approve").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.story = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Story.self)
            } ?? []
            
            self.story.sort(by: { $0.dateCreated! > $1.dateCreated! })
            
        }
    }
    
    func getStoryCount(childId: String) {
            let db = Firestore.firestore()
            let collectionRef = db.collection("Story")

            // Perform a filtered aggregation query based on childId
            collectionRef.whereField("childId", isEqualTo: childId).whereField("status", isEqualTo: "Approve")
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
            let (newStories, lastDoc) = try await StoriesManager.shared.getAllMyFriendsStories(count: limit, childId: childId, lastDocument: lastDocument)
            
            // Update UI in main thread
            DispatchQueue.main.async {
                for newStory in newStories {
                    if !self.story.contains(where: { $0.id == newStory.id }) {
                        self.story.append(newStory)
                    }
                }
              //  self.story.append(contentsOf: newStories)
                self.lastDocument = lastDoc // Update last document for pagination
            }
        } catch {
            print("Error fetching stories: \(error.localizedDescription)")
        }
    }

    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                self.child = document
                self.profileImage = document.profileImage
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    func getFriendsCount(childId: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2").document(childId).collection("friends")
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let documentCount = querySnapshot?.count ?? 0
                print("Number of documents: \(documentCount)")
                self.numberOfFriends = documentCount
            }
        }
    }
    
    func removeFriend(childId: String, docID: String) {
        
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friends").document(docID).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
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
    
    func checkFriendRequest(childId: String, friendId: String) {
            // Assuming currentUserId is the user's ID whose friend requests you are checking
            let db = Firestore.firestore()
            let docRef = db.collection("Children2")
            .document(childId)
                .collection("friendRequests")
                .document(friendId)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Document exists
                    self.isFriendRequest = true
                } else {
                    // Document does not exist
                    self.isFriendRequest = false
                }
            }
        }
}
