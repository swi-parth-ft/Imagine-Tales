//
//  FriendRequestView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import Drops

struct FriendRequestView: View {
    @StateObject var viewModel = FriendsViewModel() // ViewModel for managing friend requests
    @AppStorage("childId") var childId: String = "Default value" // User's child ID for data retrieval
    @State private var selectedFriend: UserChildren? // Track the selected friend
    @State private var selectedStory: Story?
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @Environment(\.colorScheme) var colorScheme
    
    func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm, d MMMM"
            
            // Customize the month to display as a shortened version (e.g., "Sept")
            dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm, d MMM")
            
            return dateFormatter.string(from: date)
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    // Check if there are no friend requests
                    
                            
                            List {
                                Section("Friend Requests") {
                                    if viewModel.children.isEmpty {
                                        ContentUnavailableView("No New Friend Requests",
                                                               systemImage: "person.crop.circle.badge.exclamationmark",
                                                               description: Text("You currently don't have any new friend requests."))
                                        .listRowBackground(Color.white.opacity(0))
                                    }
                                    ForEach(viewModel.children, id: \.id) { friend in
                                        
                                        
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : .white)
                                                    .frame(width: 70)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                // Assuming there's an AsyncDp for async loading of images
                                                Image(friend.profileImage.removeJPGExtension())
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(75)
                                            }
                                            .padding(.trailing)
                                            
                                            Text("\(friend.username)") // Display friend's username
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
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
                                                Drops.show(Drop(title: "You're now friends with \(friend.username)!"))
                                                
                                            }) {
                                                Text("Accept")
                                                    .foregroundStyle(.white)
                                                    .padding()
                                                    .frame(width: 120)
                                                    .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61")) // Button color
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
                                                Drops.show(Drop(title: "Request from \(friend.username) denied!"))
                                            }) {
                                                Text("Deny")
                                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                    .padding()
                                                    .frame(width: 120)
                                                    .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#D0FFD0")) // Button color
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding()
                                        .listRowBackground(Color.white.opacity(0))
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                        .listRowSeparator(.hidden) // Hide row separator
                                        .cornerRadius(16)
                                    }
                                }
                                
                                Section("Notifications") {
                                    if viewModel.notifications.isEmpty {
                                        ContentUnavailableView("No New Notifications",
                                                               systemImage: "bell.fill",
                                                               description: Text("You currently don't have any new Notifications."))
                                        .listRowBackground(Color.white.opacity(0))
                                    }
                                    ForEach(viewModel.notifications) { noti in
                                        HStack(alignment: .center) {
                                            ZStack {
                                                Circle()
                                                    .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : .white)
                                                    .frame(width: 70)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                // Assuming there's an AsyncDp for async loading of images
                                                Image(noti.fromChildProfileImage.removeJPGExtension())
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(75)
                                            }
                                            .padding(.trailing)
                                                Text("\(noti.fromChildUsername) \(noti.type) your story, \(noti.storyTitle) \(formatDate(noti.timeStamp))")
                                            
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : .white)
                                                    .frame(width: 50)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                Image(systemName: "book.pages")
                                                    .font(.system(size: 16))
                                            }
                                            .onTapGesture {
                                                viewModel.getStoryById(storyId: noti.storyId) { story, error in
                                                    if let error = error {
                                                            print("Error fetching document: \(error.localizedDescription)")
                                                        } else if let story = story {
                                                            selectedStory = story
                                                        } else {
                                                            print("Document does not exist")
                                                        }
                                                }
                                            }
                                                
                                            
                                        }
                                        .padding()
                                        .listRowBackground(Color.white.opacity(0))
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                        .listRowSeparator(.hidden) // Hide row separator
                                        .cornerRadius(16)
                                        .swipeActions {
                                           
                                            Button(role: .destructive) {
                                                viewModel.deleteNotification(withId: noti.id)
                                                viewModel.fetchNotifications(for: childId)
                                            } label: {
                                                Label("Delete", systemImage: "trash")

                                            }
                                            .tint(.red)
                                            .foregroundColor(.white)
                                            
                                        }
                                    }
                                }
                            
                                
                            }
                            .scrollContentBackground(.hidden)
                           
                            

                        
                        .fullScreenCover(item: $selectedFriend) { friend in
                            FriendProfileView(friendId: friend.id, dp: friend.profileImage) // Show friend's profile in full screen
                        }
                        .fullScreenCover(item: $selectedStory) { story in
                            StoryFromProfileView(story: story)
                        }
                    
                }
            }
            .onAppear {
                viewModel.fetchFriendRequests(childId: childId) // Fetch friend requests when the view appears
                viewModel.fetchNotifications(for: childId)
            }
        }
    }
}
