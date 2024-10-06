//
//  FriendsShareView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/6/24.
//


import SwiftUI
import Drops

struct FriendsShareView: View {
    @Environment(\.colorScheme) var colorScheme // For light/dark mode detection
    @State private var searchQuery = ""
    
    // You need to provide `viewModel`, `childId`, and `story` as inputs
    @ObservedObject var viewModel: HomeViewModel // Replace with the actual view model type
    let childId: String
    let story: Story // Replace with your actual Story model
    
    var filteredFriends: [UserChildren] {
        if searchQuery.isEmpty {
            return viewModel.friends
        } else {
            return viewModel.friends.filter { $0.username.contains(searchQuery) }
        }
    }
    
    var body: some View {
        ZStack {
            BackGroundMesh().ignoresSafeArea() // Background mesh
            
            VStack {
                List {
                    Section("Share with Friends") {
                        TextField("Search Friends", text: $searchQuery)
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.4))
                        
                        ForEach(filteredFriends) { friend in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white)
                                        .frame(width: 50)
                                    Image(friend.profileImage.removeJPGExtension())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(50)
                                }
                                
                                Text(friend.username)
                                    .foregroundStyle(.primary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.addSharedStory(childId: friend.id, fromId: viewModel.child?.username ?? "", toId: friend.id, storyId: story.id)
                                let drop = Drop(title: "Shared Story with \(friend.username)")
                                Drops.show(drop)
                                
                                viewModel.sendShareNotification(fromId: childId, toUserId: friend.id, storyId: story.id, storyTitle: story.title, fromChildUsername: viewModel.child?.username ?? "", fromChildProfilePic: viewModel.child?.profileImage ?? "")
                            }
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.4))
                        }
                    }
                }
                .searchable(text: $searchQuery, prompt: "Search Friends")
                .scrollContentBackground(.hidden)
                .onAppear {
                    viewModel.fetchChild(ChildId: childId)
                    viewModel.fetchFriends(childId: childId)
                }
            }
        }
    }
}
