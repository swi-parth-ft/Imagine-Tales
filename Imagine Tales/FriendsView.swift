//
//  FriendsView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/30/24.
//

import SwiftUI
import FirebaseFirestore

final class FriendsViewModel: ObservableObject {
    
    @Published var friends = [String]()
    @Published var friendRequests = [(requestId: String, fromUserId: String)]()
    
    func fetchFriends(childId: String) {
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    self.friends = snapshot.documents.compactMap { $0["friendUserId"] as? String }
                }
            }
        }
    }
    
    func fetchFriendRequests(childId: String) {
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friendRequests").whereField("status", isEqualTo: "pending").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching friend requests: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    self.friendRequests = snapshot.documents.compactMap {
                        let requestId = $0.documentID
                        let fromUserId = $0["fromUserId"] as? String ?? ""
                        return (requestId: requestId, fromUserId: fromUserId)
                    }
                }
            }
        }
    }
    
    func respondToFriendRequest(childId: String, requestId: String, response: String, friendUserId: String) {
        let db = Firestore.firestore()
        
        // Update the friend request status
        db.collection("Children2").document(childId).collection("friendRequests").document(requestId).updateData([
            "status": response
        ]) { error in
            if let error = error {
                print("Error updating friend request: \(error.localizedDescription)")
            } else {
                print("Friend request updated to \(response) successfully!")
                
                if response == "accepted" {
                    // Add both users as friends to each other's friend collection
                    self.addFriends(forUserId: childId, friendUserId: friendUserId)
                    self.addFriends(forUserId: friendUserId, friendUserId: childId)
                }
            }
        }
    }
    
    func addFriends(forUserId userId: String, friendUserId: String) {
        let db = Firestore.firestore()
        
        let userFriendData: [String: Any] = [
            "friendUserId": friendUserId,
            "addedDate": Date()
        ]
        
        db.collection("Children2").document(userId).collection("friends").document(friendUserId).setData(userFriendData) { error in
                if let error = error {
                    print("Error adding friend: \(error.localizedDescription)")
                } else {
                    print("Friend added successfully!")
                }
            }
    }
    
    
}
struct FriendsView: View {
    @StateObject var viewModel = FriendsViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        VStack {
            Text("Friend Requests")
                .font(.largeTitle)
                .padding()
            
            List(viewModel.friendRequests, id: \.requestId) { request in
                HStack {
                    Text("From: \(request.fromUserId)")
                    Spacer()
                    
                    // Encapsulate each button in a ZStack and give fixed width
                    ZStack {
                        Button(action: {
                            viewModel.respondToFriendRequest(childId: childId, requestId: request.requestId, response: "accepted", friendUserId: request.fromUserId)
                        }) {
                            Text("Accept")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.2)) // For visual debugging
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .contentShape(Rectangle()) // Ensure the button only responds to touches on its visible area
                    
                    ZStack {
                        Button(action: {
                            viewModel.respondToFriendRequest(childId: childId, requestId: request.requestId, response: "denied", friendUserId: request.fromUserId)
                        }) {
                            Text("Deny")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.2)) // For visual debugging
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 10)
                }
                .padding(.vertical, 10) // Add vertical padding for better button spacing
            }
            .onAppear {
                viewModel.fetchFriendRequests(childId: childId)
            }
            
            VStack {
                Text("Friends")
                    .font(.largeTitle)
                    .padding()
                
                List(viewModel.friends, id: \.self) { friend in
                    Text(friend)
                }
                .onAppear {
                    viewModel.fetchFriends(childId: childId)
                }
            }
        }
    }
}

#Preview {
    FriendsView()
}
