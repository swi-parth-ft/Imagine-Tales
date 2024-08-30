//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI
import FirebaseFirestore

// Struct for each story text item
struct StoryTextItem: Codable, Hashable {
    var image: String
    var text: String
}

// Struct for the story document
struct Story: Codable, Hashable {
    let id: String
    var parentId: String
    var childId: String
    var storyText: [StoryTextItem]
    var title: String
    var status: String
    var genre: String
    var childUsername: String
    var likes: Int
}

final class HomeViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var genre: String = "Adventure"
    @Published var status = ""
    
    func getStories() throws {
        
        Firestore.firestore().collection("Story").whereField("status", isEqualTo: "Approve").whereField("genre", isEqualTo: genre).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.stories = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Story.self)
            } ?? []
            print(self.stories)
            
        }
    }
    
    func likeStory(childId: String, storyId: String) {
        let db = Firestore.firestore()
        let storyRef = db.collection("Story").document(storyId)
        let likesRef = storyRef.collection("likes")
        let query = likesRef.whereField("childId", isEqualTo: childId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking likes: \(error)")
                return
            }
            
            if let snapshot = snapshot, snapshot.isEmpty {
                // Child has not liked this story, proceed to like it
                let likeData: [String: Any] = ["childId": childId, "timestamp": Timestamp()]
                likesRef.addDocument(data: likeData) { error in
                    if let error = error {
                        print("Error liking story: \(error)")
                    } else {
                        storyRef.updateData(["likes": FieldValue.increment(Int64(1))]) { error in
                            if let error = error {
                                print("Error updating like count: \(error)")
                            } else {
                                print("Story liked successfully!")
                            }
                        }
                    }
                }
            } else {
                // Child has already liked this story, proceed to dislike it
                if let document = snapshot?.documents.first {
                    document.reference.delete() { error in
                        if let error = error {
                            print("Error disliking story: \(error)")
                        } else {
                            storyRef.updateData(["likes": FieldValue.increment(Int64(-1))]) { error in
                                if let error = error {
                                    print("Error updating like count: \(error)")
                                } else {
                                    print("Story disliked successfully!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkIfChildLikedStory(childId: String, storyId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let storyRef = db.collection("Story").document(storyId)
        let likesRef = storyRef.collection("likes")
        
        likesRef.whereField("childId", isEqualTo: childId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking if child liked the story: \(error)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func toggleSaveStory(childId: String, storyId: String) {
        let db = Firestore.firestore()
        let childRef = db.collection("Children2").document(childId)
        let savedStoriesRef = childRef.collection("savedStories")
        let query = savedStoriesRef.whereField("storyId", isEqualTo: storyId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking saved stories: \(error)")
                return
            }
            
            if let snapshot = snapshot, snapshot.isEmpty {
                // Story is not saved, proceed to save it
                let saveData: [String: Any] = ["storyId": storyId, "timestamp": Timestamp()]
                savedStoriesRef.addDocument(data: saveData) { error in
                    if let error = error {
                        print("Error saving story: \(error)")
                    } else {
                        print("Story saved successfully!")
                    }
                }
            } else {
                // Story is already saved, proceed to unsave it
                if let document = snapshot?.documents.first {
                    document.reference.delete() { error in
                        if let error = error {
                            print("Error unsaving story: \(error)")
                        } else {
                            print("Story unsaved successfully!")
                        }
                    }
                }
            }
        }
    }
    
    func checkIfChildSavedStory(childId: String, storyId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let childRef = db.collection("Children2").document(childId)
        let savedStoriesRef = childRef.collection("savedStories")
        
        savedStoriesRef.whereField("storyId", isEqualTo: storyId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking if child saved the story: \(error)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func sendFriendRequest(toChildId: String, fromChildId: String) {
            let db = Firestore.firestore()
            let friendRequestData: [String: Any] = [
                "fromUserId": fromChildId,
                "status": "pending"
            ]
            
        // Use toChildId as the document ID for the friend request
        let requestRef = db.collection("Children2").document(toChildId).collection("friendRequests").document(fromChildId)
            
            // Set the data for the friend request document
            requestRef.setData(friendRequestData) { error in
                if let error = error {
                    print("Error sending friend request: \(error.localizedDescription)")
                } else {
                    print("Friend request sent successfully!")
                }
            }
        }
    
    func checkFriendshipStatus(childId: String, friendChildId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Children2").document(childId)
        let friendRequestRef = db.collection("Children2").document(friendChildId).collection("friendRequests").document(childId)
          
          // Check if already friends
          userRef.collection("friends").document(friendChildId).getDocument { [weak self] (document, error) in
              if let document = document, document.exists {
                  self?.status = "Friends"
                  return
              }
              
              // Check for pending requests
              friendRequestRef.getDocument { [weak self] (document, error) in
                  if let document = document, document.exists  {
                      self?.status = "Pending"
                  } else {
                      self?.status = "Send Request"
                  }
              }
          }
      }
}

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @Binding var reload: Bool
    
    let genres = [
        "Adventure",
        "Fantasy",
        "Mystery",
        "Romance",
        "Science Fiction",
        "Horror",
        "Thriller",
        "Historical",
        "Comedy",
        "Drama",
        "Detective",
        "Dystopian",
        "Fairy Tale",
        "Magical Realism",
        "Biography",
        "Coming-of-Age",
        "Action",
        "Paranormal",
        "Supernatural",
        "Western"
    ]
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(genres, id: \.self) { category in
                            Button(action: {
                                withAnimation {
                                    viewModel.genre = category
                                    do {
                                        try viewModel.getStories()
                                        reload.toggle()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }) {
                                Text(category)
                                    .padding()
                                    .background(category == viewModel.genre ? Color.green : Color.clear)
                                    .foregroundColor(category == viewModel.genre ? .white : .black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: category == viewModel.genre ? 0 : 1)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                StoryListView(stories: viewModel.stories, reload: $reload, childId: childId)
                
                    .onAppear {
                        do {
                            try viewModel.getStories()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
            }
            .onChange(of: reload) {
                do {
                    try viewModel.getStories()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct StoryListView: View {
    var stories: [Story]
    @Binding var reload: Bool
    var childId: String
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(stories, id: \.id) { story in
                        StoryRowView(story: story, childId: childId, reload: $reload)
                    }
                }
            }
            .padding(.bottom, 50)
        }
    }
}

import SwiftUI

struct StoryRowView: View {
    var story: Story
    var childId: String
    @StateObject var viewModel = HomeViewModel()
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var isSaved = false
    @Binding var reload: Bool
    @State private var likeObserver = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                VStack(spacing: -20) {
                    // Title
                    HStack(alignment: .top) {
                        
                        Text(story.title)
                            .font(.system(size: 24))
                        // Adjust font weight if needed
                            .padding(.leading, 16) // Add padding to align the text properly
                        
                        Spacer() // Spacer to push icons to the right
                        
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.toggleSaveStory(childId: childId, storyId: story.id)
                                isSaved.toggle()
                                reload.toggle()
                            }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .padding(.horizontal)
                    NavigationLink(destination: StoryFromProfileView(story: story)) {
                        ZStack(alignment: .topTrailing) {
                            
                            AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                switch phase {
                                case .empty:
                                    GradientRectView()
                                case .success(let image):
                                    
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 500)
                                        .clipped()
                                        .cornerRadius(30)
                                        .overlay(
                                            // User profile overlay
                                            HStack {
                                                Image(systemName: "person.crop.circle")
                                                Text(story.childUsername)
                                                    .font(.subheadline)
                                                Spacer()
                                                Image(systemName: viewModel.status == "Friends" ? "person.crop.circle.badge.checkmark" : (viewModel.status == "Pending" ? "clock" : "plus"))
                                            }
                                                .padding(5)
                                                .frame(width: 200)
                                                .background(Color.black.opacity(0.7))
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                                .padding()
                                                .onTapGesture {
                                                    if viewModel.status != "Friends" && viewModel.status != "Pending" {
                                                        viewModel.sendFriendRequest(toChildId: story.childId, fromChildId: childId)
                                                    }
                                                    
                                                }
                                            , alignment: .topTrailing
                                        )
                                        .padding()
                                    
                                    
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 500)
                                        .cornerRadius(10)
                                        .padding()
                                    
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 500)
                            .cornerRadius(10)
                            
                        }
                        
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("The Minions hatch a clever plan to steal the world’s biggest banana, but things go hilariously wrong when they encounter a banana-loving monkey!")
                            .font(.body)
                            .padding(.horizontal)
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                        
                        Text(viewModel.status)
                            .onAppear {
                                viewModel.checkFriendshipStatus(childId: childId, friendChildId: story.childId)
                            }
                    }
                    HStack {
                        Spacer()
                        
                        // Like button with count
                        HStack(spacing: 5) {
                            Button(action: {
                                viewModel.likeStory(childId: childId, storyId: story.id)
                                
                                isLiked.toggle()
                               // reload.toggle()
                                
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .tint(.red)
                            }
                            
                            Text("\(isLiked ? story.likes + 1 : story.likes)")
                        }
                        .padding(.trailing)
                        .font(.system(size: 20))
                        
                        // Share button
                        Image(systemName: "paperplane")
                            .font(.system(size: 20))
                    }
                    .padding()
                }
                .padding()
            }
            .padding(.vertical)
            .onAppear {
                viewModel.checkIfChildLikedStory(childId: childId, storyId: story.id) { hasLiked in
                    isLiked = hasLiked
                    if isLiked {
                        likeObserver = true
                    }
                }
                
                viewModel.checkIfChildSavedStory(childId: childId, storyId: story.id) { hasSaved in
                    isSaved = hasSaved
                    print(isSaved)
                }
            }
        }
    }
}

#Preview {
    HomeView(reload: .constant(false))
}
