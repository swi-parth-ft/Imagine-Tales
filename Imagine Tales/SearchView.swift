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
    @State private var stories: [Story] = []
    @State private var selectedFriend: UserChildren? = nil
    @State private var selectedStory: Story? = nil
    @Environment(\.colorScheme) var colorScheme

    @State private var retryCount = 0 // Count for retry attempts when loading images
    @State private var maxRetryAttempts = 3 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retries
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    TextField("Search...", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(22)
                        .tint(.orange)
                    Text("Search Result for \(searchText):")
                        .font(.system(size: 22))
                        .padding()
                    if children.isEmpty {
                        ContentUnavailableView("No Results", systemImage: "person.crop.badge.magnifyingglass.fill", description: Text("Try searching with username."))
                    }
                    ScrollView {
                        if !children.isEmpty {
                            HStack {
                                Text("Creators")
                                    .font(.system(size: 20))
                                Spacer()
                                
                            }
                            .padding()
                        }
                        
                        
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(children) { friend in
                                        NavigationLink(destination: FriendProfileView(friendId: friend.id,dp: friend.profileImage)) {
                                            ZStack {
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white)
                                                            .frame(width: 170)
                                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                        AsyncDp(urlString: friend.profileImage, size: 150)
                                                    }
                                                    .padding()
                                                    
                                                    Text(friend.username)
                                                        .foregroundStyle(.primary)
                                                }
                                            }
                                            .onTapGesture {
                                                selectedFriend = friend
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                }
                            }
                        
                        if !stories.isEmpty {
                            HStack {
                                Text("Stories")
                                    .font(.system(size: 20))
                                Spacer()
                                
                            }
                            .padding()
                        }
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 30) {
                                ForEach(stories) { story in
                                    
                                        ZStack {
                                            // Load the story image asynchronously
                                            AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                                switch phase {
                                                case .empty:
                                                    // Placeholder for loading
                                                    MagicView()
                                                        .frame(width: 300, height: 300)
                                                    
                                                case .success(let image):
                                                    // Successfully loaded image
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 300, height: 300)
                                                        .clipped()
                                                        .cornerRadius(12)
                                                    
                                                case .failure(_):
                                                    // Placeholder for failed load
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 300)
                                                        .cornerRadius(10)
                                                        .padding()
                                                        .onAppear {
                                                            // Retry loading logic
                                                            if retryCount < maxRetryAttempts {
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                                    retryCount += 1
                                                                }
                                                            }
                                                        }
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Add shadow to the image
                                            
                                            VStack {
                                                Spacer()
                                                
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 0)
                                                        .fill(Color.white.opacity(0.8))
                                                        .frame(width: 300, height: 150)
                                                    
                                                    VStack(spacing: 0) {
                                                        
                                                        Text(story.title)
                                                            .font(.system(size: 18))
                                                        Text("By \(story.childUsername)")
                                                            .font(.system(size: 16))
                                                            .padding(.top, -20)
                                                        Button("Read Now") {
                                                            selectedStory = story
                                                        }
                                                        .padding()
                                                        .font(.system(size: 16))
                                                        .background(Color(hex: "#FF6F61"))
                                                        .foregroundStyle(.white)
                                                        .cornerRadius(23)
                                                        .padding(.top)
                                                    }
                                                    .foregroundStyle(.black)
                                                    
                                                }
                                                .padding(.bottom, 10)
                                            }
                                        }
                                    
                                    
                                }
                            }
                        }
                        
                        
                    }
                    .fullScreenCover(item: $selectedFriend) { friend in
                                      FriendProfileView(friendId: friend.id, dp: friend.profileImage)
                                  }
                    .fullScreenCover(item: $selectedStory) { story in
                            StoryFromProfileView(story: story)
                    }
                    .onChange(of: searchText) {
                        performSearch(query: searchText)
                        performSearchForStory(query: searchText)
                        
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
    
    func performSearchForStory(query: String) {
        let db = Firestore.firestore()
        db.collection("Story")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let documents = snapshot?.documents ?? []
                    // Client-side filtering for partial and case-insensitive search
                    stories = documents.compactMap { document -> Story? in
                        if let data = try? document.data(as: Story.self) {
                            // Perform case-insensitive and partial search on the desired field
                            if data.title.lowercased().contains(query.lowercased()) {
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
