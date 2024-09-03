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
    @Published var child: UserChildren?
    @Published var children: [UserChildren] = []
    
    
    func fetchFriends(childId: String) {
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    self.friends = snapshot.documents.compactMap { $0["friendUserId"] as? String }
                    self.fetchChildren()
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
    
    func fetchChildren() {
            let db = Firestore.firestore()
            
            // Clear the existing array
            self.children.removeAll()
            
            for childId in friends {
                let docRef = db.collection("Children2").document(childId)
                
                docRef.getDocument(as: UserChildren.self) { result in
                    switch result {
                    case .success(let document):
                        self.children.append(document)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    
    func deleteRequest(childId: String, docID: String) {
        
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friendRequests").document(docID).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
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
    
    
}
struct FriendsView: View {
    @StateObject var viewModel = FriendsViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    let bookBackgroundColors: [Color] = [
        Color(red: 255/255, green: 235/255, blue: 190/255),  // More vivid Beige
        Color(red: 220/255, green: 220/255, blue: 220/255),  // More vivid Light Gray
        Color(red: 255/255, green: 230/255, blue: 240/255),  // More vivid Lavender Blush
        Color(red: 255/255, green: 255/255, blue: 245/255),  // More vivid Mint Cream
        Color(red: 230/255, green: 255/255, blue: 230/255),  // More vivid Honeydew
        Color(red: 230/255, green: 248/255, blue: 255/255),  // More vivid Alice Blue
        Color(red: 255/255, green: 250/255, blue: 230/255),  // More vivid Seashell
        Color(red: 255/255, green: 250/255, blue: 215/255),  // More vivid Old Lace
        Color(red: 255/255, green: 250/255, blue: 200/255)   // More vivid Cornsilk
    ]
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: bookBackgroundColors
                ).ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            VStack {
                                ForEach(viewModel.children) { friend in
                                    NavigationLink(destination: FriendProfileView(friendId: friend.id,dp: friend.profileImage)) {
                                        ZStack {
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .cornerRadius(20)
                                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                            VStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.white)
                                                        .frame(width: 170)
                                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                    AsyncDp(urlString: friend.profileImage, size: 150)
                                                }
                                                .padding()
                                                Text(friend.username)
                                                    .foregroundStyle(.black)
                                            }
                                            .padding()
                                        }
                                        .padding()
                                    }
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        viewModel.fetchFriends(childId: childId)
                    }

                }
            }
            .navigationTitle("Friends")
        }
    }
}

struct FriendRequestView: View {
    @StateObject var viewModel = FriendsViewModel()
    @AppStorage("childId") var childId: String = "Default value"
    
    var body: some View {
       
            ZStack {
                VisualEffectBlur(blurStyle: .systemThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                VStack {
                    
                    
                    List(viewModel.friendRequests, id: \.requestId) { request in
                        HStack {
                            if let username = viewModel.child?.username {
                                Text("\(username)")
                            } else {
                                Text("")
                            }
                            Spacer()
                            
                            // Encapsulate each button in a ZStack and give fixed width
                            ZStack {
                                Button(action: {
                                    viewModel.respondToFriendRequest(childId: childId, requestId: request.requestId, response: "accepted", friendUserId: request.fromUserId)
                                    viewModel.deleteRequest(childId: childId, docID: request.fromUserId)
                                }) {
                                    Text("Accept")
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: 110)
                                        .background(Color.green.opacity(0.2)) // For visual debugging
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .contentShape(Rectangle()) // Ensure the button only responds to touches on its visible area
                            
                            ZStack {
                                Button(action: {
                                    viewModel.respondToFriendRequest(childId: childId, requestId: request.requestId, response: "denied", friendUserId: request.fromUserId)
                                    viewModel.deleteRequest(childId: childId, docID: request.fromUserId)
                                }) {
                                    Text("Deny")
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: 110)
                                        .background(Color.red.opacity(0.2)) // For visual debugging
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 10)
                        }
                        .onAppear {
                            viewModel.fetchChild(ChildId: request.fromUserId)
                        }
                        //                    .padding(.vertical, 10)
                        .listRowBackground(Color.white.opacity(0.5))
                    }
                    .onAppear {
                        viewModel.fetchFriendRequests(childId: childId)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
     
    }
}

#Preview {
    FriendsView()
}
