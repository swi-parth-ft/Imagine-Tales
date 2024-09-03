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
                    
                    TextField("Search...", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(22)
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
