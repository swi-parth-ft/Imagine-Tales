//
//  SearchView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//


import SwiftUI
import Firebase
import FirebaseFirestore

struct SearchView: View {
    @State private var searchText = ""
    @State private var children: [UserChildren] = []
    @State private var selectedFriend: UserChildren? = nil
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
  
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#8AC640").ignoresSafeArea()
                
                VStack {
                    
                    TextField("Search...", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(22)
                    if children.isEmpty {
                        ContentUnavailableView("No Results", systemImage: "person.crop.badge.magnifyingglass.fill", description: Text("Try searching with username."))
                    }
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            
                                ForEach(children) { friend in
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
                                        .onTapGesture {
                                            selectedFriend = friend
                                        }
                                  
                                        
                                    }
                                    .padding()
                                    
                                }
                            
                        }
                    }
                    .fullScreenCover(item: $selectedFriend) { friend in
                                      FriendProfileView(friendId: friend.id, dp: friend.profileImage)
                                  }
                    .onChange(of: searchText) {
                        performSearch(query: searchText)
                    }
                }
                .padding()
            }
        }
    }

    func performSearch(query: String) {
        let db = Firestore.firestore()
        db.collection("Children2")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let documents = snapshot?.documents ?? []
                    // Client-side filtering for partial and case-insensitive search
                    children = documents.compactMap { document -> UserChildren? in
                        if let data = try? document.data(as: UserChildren.self) {
                            // Perform case-insensitive and partial search on the desired field
                            if data.username.lowercased().contains(query.lowercased()) {
                                return data
                            }
                        }
                        return nil
                    }
                }
            }
    }
}

#Preview {
    SearchView()
}
