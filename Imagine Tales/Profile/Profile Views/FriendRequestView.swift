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
    @StateObject var homeViewModel = HomeViewModel() 
    @AppStorage("childId") var childId: String = "Default value" // User's child ID for data retrieval
    @State private var selectedFriend: UserChildren? // Track the selected friend
    @State private var selectedStory: Story?
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingProfile = false
    @State private var notificationFriendId = ""
    @State private var notificationDp = ""
    
    func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm, d MMMM"
            
            // Customize the month to display as a shortened version (e.g., "Sept")
            dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm, d MMM")
            
            return dateFormatter.string(from: date)
        }
    
    func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    @State private var showingTodaysNoti = true
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    // Check if there are no friend requests
                    
                    if viewModel.children.isEmpty && viewModel.notifications.isEmpty {
                        ContentUnavailableView("No New Notifications",
                                               systemImage: "bell",
                                               description: Text("You currently don't have any new friend requests or notifications."))
                        .listRowBackground(Color.white.opacity(0))
                    } else {
                        HStack {
                            Button {
                                withAnimation {
                                    showingTodaysNoti = true
                                }
                            } label: {
                                Text("Today")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(!showingTodaysNoti ? .clear : colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(16)
                                
                            }
                            Button {
                                withAnimation {
                                    showingTodaysNoti = false
                                }
                            } label: {
                                Text("Older")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(showingTodaysNoti ? .clear : colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(16)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                        List {
                            if !viewModel.children.isEmpty {
                                Section("Friend Requests") {
                                    
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
                                            .onTapGesture {
                                                selectedFriend = friend
                                            }
                                            
                                            Text("\(friend.username)") // Display friend's username
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            // Button to accept the friend request
                                            
                                            Text("Accept")
                                                .foregroundStyle(.white)
                                                .padding()
                                                .frame(width: 120)
                                                .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61")) // Button color
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    var requestId = ""
                                                    if let request = viewModel.friendRequests.first(where: { $0.fromUserId == friend.id }) {
                                                        requestId = request.requestId
                                                        print("Request ID: \(requestId)")
                                                    } else {
                                                        print("No request found for the given user ID.")
                                                    }
                                                    viewModel.respondToFriendRequest(childId: childId, requestId: requestId, response: "accepted", friendUserId: friend.id)
                                                    viewModel.deleteRequest(childId: childId, docID: friend.id)
                                                    homeViewModel.sendRequestRespoceNotification(fromId: childId, toUserId: friend.id, fromChildUsername: viewModel.child?.username ?? "", fromChildProfilePic: viewModel.child?.profileImage ?? "", status: "Accepted")
                                                    Drops.show(Drop(title: "You're now friends with \(friend.username)!"))
                                                }
                                            
                                            
                                            // Button to deny the friend request
                                            
                                            Text("Deny")
                                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                .padding()
                                                .frame(width: 120)
                                                .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#D0FFD0")) // Button color
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    var requestId = ""
                                                    if let request = viewModel.friendRequests.first(where: { $0.fromUserId == friend.id }) {
                                                        requestId = request.requestId
                                                        print("Request ID: \(requestId)")
                                                    } else {
                                                        print("No request found for the given user ID.")
                                                    }
                                                    viewModel.respondToFriendRequest(childId: childId, requestId: requestId, response: "denied", friendUserId: friend.id)
                                                    viewModel.deleteRequest(childId: childId, docID: friend.id)
                                                    homeViewModel.sendRequestRespoceNotification(fromId: childId, toUserId: friend.id, fromChildUsername: viewModel.child?.username ?? "", fromChildProfilePic: viewModel.child?.profileImage ?? "", status: "Denied")
                                                    Drops.show(Drop(title: "Request from \(friend.username) denied!"))
                                                }
                                            
                                        }
                                        .padding()
                                        .listRowBackground(Color.white.opacity(0))
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                        .listRowSeparator(.hidden) // Hide row separator
                                        .cornerRadius(16)
                                    }
                                }
                            }
                            
                            if !viewModel.notifications.isEmpty {
                                Section("Notifications") {
                                    if showingTodaysNoti {
                                        if viewModel.notifications.filter({ isToday($0.timeStamp) }).isEmpty {
                                            ContentUnavailableView("No New Notifications",
                                                                   systemImage: "bell",
                                                                   description: Text("You currently don't have any new friend requests or notifications."))
                                            .listRowBackground(Color.white.opacity(0))
                                        }
                                    }
                                    ForEach(showingTodaysNoti ? viewModel.notifications.filter { isToday($0.timeStamp) } : viewModel.notifications.filter { !isToday($0.timeStamp) }) { noti in
                                        
                                        
                                        
                                        if noti.type == "status" {
                                            HStack(alignment: .center) {
                                                
                                                Image(systemName: noti.storyStatus == "Approved" ? "checkmark.circle.fill" : "xmark.circle.fill" )
                                                    .font(.system(size: 50))
                                                    .foregroundStyle(noti.storyStatus == "Approved" ? .green : .red )
                                                
                                                Text("Your story \(noti.storyTitle) is \(noti.storyStatus ?? "")")
                                                
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
                                        else if noti.type == "share" {
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
                                                .onTapGesture {
                                                    let friend = UserChildren(id: noti.fromId, parentId: "", name: "", age: "", dateCreated: Date(), username: "", profileImage: noti.fromChildProfileImage)
                                                    selectedFriend = friend
                                                    
                                                }
                                                
                                                Image(systemName: "paperplane")
                                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                    .font(.system(size: 20))
                                                
                                                
                                                Text("\(noti.fromChildUsername) shared \(noti.storyTitle.trimmingCharacters(in: .newlines)). \(formatDate(noti.timeStamp))")
                                                
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
                                        else if noti.type == "Comment" {
                                            HStack(alignment: .center) {
                                                
                                                Image(systemName: "message.badge.filled.fill" )
                                                    .font(.system(size: 40))
                                                    .foregroundStyle(.blue)
                                                
                                                Text("Your story \(noti.storyTitle) has a new Comment.")
                                                
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
                                        else if noti.type == "response" {
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
                                                .onTapGesture {
                                                    let friend = UserChildren(id: noti.fromId, parentId: "", name: "", age: "", dateCreated: Date(), username: "", profileImage: noti.fromChildProfileImage)
                                                    selectedFriend = friend
                                                    
                                                }
                                                
                                                
                                                Text("\(noti.fromChildUsername) \(noti.storyStatus ?? "") your friend request.")
                                                
                                                Spacer()
                                              
                                                
                                                
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
                                        else {
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
                                                .onTapGesture {
                                                    let friend = UserChildren(id: noti.fromId, parentId: "", name: "", age: "", dateCreated: Date(), username: "", profileImage: noti.fromChildProfileImage)
                                                    selectedFriend = friend
                                                    
                                                }
                                                if noti.type == "Liked" {
                                                    Image(systemName: "heart.fill")
                                                        .foregroundStyle(.red)
                                                        .font(.system(size: 20))
                                                } else if noti.type == "Unliked" {
                                                    Image(systemName: "heart")
                                                        .foregroundStyle(.red)
                                                        .font(.system(size: 20))
                                                } else if noti.type == "Saved" {
                                                    Image(systemName: "bookmark.fill")
                                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                        .font(.system(size: 20))
                                                } else if noti.type == "Unsaved" {
                                                    Image(systemName: "bookmark")
                                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                        .font(.system(size: 20))
                                                }
                                                
                                                Text("\(noti.fromChildUsername) \(noti.type) your story, \(noti.storyTitle.trimmingCharacters(in: .newlines)) \(formatDate(noti.timeStamp))")
                                                
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
                viewModel.fetchChild(ChildId: childId)
                viewModel.fetchFriendRequests(childId: childId) // Fetch friend requests when the view appears
                viewModel.fetchNotifications(for: childId)
            }
        }
    }
}
