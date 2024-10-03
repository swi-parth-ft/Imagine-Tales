//
//  FriendsView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/30/24.
//

import SwiftUI

struct FriendsView: View {
    @StateObject var viewModel = FriendsViewModel() // ViewModel for managing friends
    @AppStorage("childId") var childId: String = "Default Value" // User's child ID for data retrieval
   
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient using a mesh effect
                BackGroundMesh().ignoresSafeArea()
                
                VStack {
                    ScrollView {
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
                                                    .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white)
                                                    .frame(width: 170)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                AsyncDp(urlString: friend.profileImage, size: 150) // Asynchronous loading of friend's profile image
                                            }
                                            .padding()
                                            Text(friend.username) // Displaying the friend's username
                                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                
                                        }
                                        .padding()
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        viewModel.fetchFriends(childId: childId) // Fetch friends when the view appears
                    }
                }
            }
            .navigationTitle("Friends") // Set the navigation title
        }
    }
}



#Preview {
    FriendsView()
}
