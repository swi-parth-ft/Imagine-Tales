//
//  FriendRequestView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

struct FriendRequestView: View {
    @StateObject var viewModel = FriendsViewModel() // ViewModel for managing friend requests
    @AppStorage("childId") var childId: String = "Default value" // User's child ID for data retrieval
    @State private var selectedFriend: UserChildren? // Track the selected friend
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#8AC640").ignoresSafeArea() // Background color for friend requests
                VStack {
                    // Check if there are no friend requests
                    if viewModel.children.isEmpty {
                        ContentUnavailableView("No New Friend Requests",
                                               systemImage: "person.crop.circle.badge.exclamationmark",
                                               description: Text("You currently don't have any new friend requests."))
                    } else {
                        ScrollView {
                            Text("Friend Requests")
                                .font(.title)
                                .padding(.top)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.children) { friend in
                                    NavigationLink(destination: FriendProfileView(friendId: friend.id, dp: friend.profileImage)) {
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
                                                    // Assuming there's an AsyncDp for async loading of images
                                                    Image(friend.profileImage.removeJPGExtension())
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 150, height: 150)
                                                        .cornerRadius(75)
                                                }
                                                .padding()
                                                
                                                Text("\(friend.username)") // Display friend's username
                                                    .foregroundStyle(.black)
                                                
                                                // Button to accept the friend request
                                                Button(action: {
                                                    var requestId = ""
                                                    if let request = viewModel.friendRequests.first(where: { $0.fromUserId == friend.id }) {
                                                        requestId = request.requestId
                                                        print("Request ID: \(requestId)")
                                                    } else {
                                                        print("No request found for the given user ID.")
                                                    }
                                                    viewModel.respondToFriendRequest(childId: childId, requestId: requestId, response: "accepted", friendUserId: friend.id)
                                                    viewModel.deleteRequest(childId: childId, docID: friend.id)
                                                }) {
                                                    Text("Accept")
                                                        .foregroundStyle(.white)
                                                        .padding()
                                                        .frame(width: 200)
                                                        .background(Color(hex: "#FF6F61")) // Button color
                                                        .cornerRadius(8)
                                                }
                                                
                                                // Button to deny the friend request
                                                Button(action: {
                                                    var requestId = ""
                                                    if let request = viewModel.friendRequests.first(where: { $0.fromUserId == friend.id }) {
                                                        requestId = request.requestId
                                                        print("Request ID: \(requestId)")
                                                    } else {
                                                        print("No request found for the given user ID.")
                                                    }
                                                    viewModel.respondToFriendRequest(childId: childId, requestId: requestId, response: "denied", friendUserId: friend.id)
                                                    viewModel.deleteRequest(childId: childId, docID: friend.id)
                                                }) {
                                                    Text("Deny")
                                                        .foregroundStyle(.black)
                                                        .padding()
                                                        .frame(width: 200)
                                                        .background(Color(hex: "#D0FFD0")) // Button color
                                                        .cornerRadius(8)
                                                }
                                            }
                                            .padding()
                                        }
                                        .onTapGesture {
                                            selectedFriend = friend // Set the selected friend
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .fullScreenCover(item: $selectedFriend) { friend in
                            FriendProfileView(friendId: friend.id, dp: friend.profileImage) // Show friend's profile in full screen
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchFriendRequests(childId: childId) // Fetch friend requests when the view appears
            }
        }
    }
}
