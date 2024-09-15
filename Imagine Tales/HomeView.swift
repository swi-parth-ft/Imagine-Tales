//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

// Struct for each story text item
struct StoryTextItem: Codable, Hashable {
    var image: String
    var text: String
}

// Struct for the story document
struct Story: Codable, Hashable, Identifiable {
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
    @Published var genre: String = "Following"
    @Published var status = ""
    var tempStories: [Story] = []
    
    @MainActor
    func getStories(childId: String) async throws {
        if genre == "Following" {
            stories = []
            do {
                    let friendDocuments = try await Firestore.firestore().collection("Children2").document(childId).collection("friends").getDocuments().documents
                    let friendIds = friendDocuments.map { $0.documentID }

                for friendId in friendIds {
                /*    let storyDocuments: Void = try await*/ Firestore.firestore().collection("Story").whereField("childId", isEqualTo: friendId).getDocuments() { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                            return
                        }
                        
                        self.tempStories = querySnapshot?.documents.compactMap { document in
                            try? document.data(as: Story.self)
                        } ?? []
                    self.stories.append(contentsOf: self.tempStories.filter { tempStory in
                        !self.stories.contains(where: { $0.id == tempStory.id })
                    })
                      //  self.stories.append(contentsOf: self.tempStories)
                        print(self.stories)
                    }
                }
                    
                } catch {
                    print("Error fetching data: \(error.localizedDescription)")
                }
        } else {
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
    


    func getProfileImage(documentID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2") // Replace with your collection name

        collectionRef.document(documentID).getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
                return
            }

            if let document = document, document.exists {
                let profileImage = document.get("profileImage") as? String
                completion(profileImage)
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
}

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @Binding var reload: Bool
    
    let genres = [
        "Following",
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
    @State private var isSearching = false
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(genres, id: \.self) { category in
                                Button(action: {
                                    withAnimation {
                                        viewModel.genre = category
                                        Task {
                                            do {
                                                try await viewModel.getStories(childId: childId)
                                                reload.toggle()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
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
                    if viewModel.stories.isEmpty {
                        ContentUnavailableView {
                            Label("No Stories Yet", systemImage: "book.fill")
                        } description: {
                            Text("It looks like there's no stories posted yet.")
                        } actions: {
//                                    Button {
//                                        /// Function that creates a new note
//                                    } label: {
//                                        Label("Create a new note", systemImage: "plus")
//                                    }
                        }
                        .listRowBackground(Color.clear)
                    }
                    StoryListView(stories: viewModel.stories, reload: $reload, childId: childId)
                    
                        .onAppear {
                            Task {
                                do {
                                    try await viewModel.getStories(childId: childId)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        }
                    
                }
                .navigationTitle("Imagine Tales")
                
                .onChange(of: reload) {
                    Task {
                        do {
                            try await viewModel.getStories(childId: childId)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
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
    @State private var imgUrl = ""
    @State private var retryCount = 0
    @State private var maxRetryAttempts = 3 // Set max retry attempts
    @State private var retryDelay = 2.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                
               
                VStack(alignment: .center) {
                    VStack(spacing: -20) {
                        // Title
                        HStack(alignment: .center) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60)
                                AsyncDp(urlString: imgUrl, size: 50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
                            }
                                .padding(.bottom, 30)
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
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal)
                        NavigationLink(destination: StoryFromProfileView(story: story)) {
                            ZStack(alignment: .topTrailing) {
                                
                                AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                    switch phase {
                                    case .empty:
                                        GradientRectView(size: 400)
                                           
                                    case .success(let image):
                                        
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 400)
                                            .clipped()
                                            .cornerRadius(30)
                                            .overlay(
                                                // User profile overlay
                                                HStack {
                                                  
                                                   
                                                    Text(story.childUsername)
                                                        .font(.subheadline)
                                                    Spacer()
                                                    if childId != story.childId {
                                                        Image(systemName: viewModel.status == "Friends" ? "person.crop.circle.badge.checkmark" : (viewModel.status == "Pending" ? "clock" : "plus"))
                                                    }
                                                }
                                                    .padding()
                                                    .frame(width: 200, height: 56)
                                                    .background(Color.black.opacity(0.7))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(15)
                                                    .padding()
                                                    .onTapGesture {
                                                        if childId != story.childId {
                                                            if viewModel.status != "Friends" && viewModel.status != "Pending" {
                                                                viewModel.sendFriendRequest(toChildId: story.childId, fromChildId: childId)
                                                            }
                                                        }
                                                        
                                                    }
                                                    .onAppear {
                                                        viewModel.checkFriendshipStatus(childId: childId, friendChildId: story.childId)
                                                        
                                                        viewModel.getProfileImage(documentID: story.childId) { profileImage in
                                                            if let imageUrl = profileImage {
                                                                imgUrl = imageUrl
                                                            } else {
                                                                print("Failed to retrieve profile image.")
                                                            }
                                                        }
                                                    }
                                                
                                                , alignment: .topTrailing
                                            )
                                            .padding()
                                            .shadow(radius: 5)
                                        
                                        
                                        
                                    case .failure(_):
                                        
                                                Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 500)
                                                        .cornerRadius(10)
                                                        .padding()
                                                        .onAppear {
                                                            if retryCount < maxRetryAttempts {
                                                                        // Retry logic with delay
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                                            retryCount += 1
                                                                        }
                                                                    }
                                                        }
                                                
                                        
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width, height: 400)
                                .cornerRadius(10)
                                .id(retryCount)
                                
                            }
                            
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("The Minions hatch a clever plan to steal the world’s biggest banana, but things go hilariously wrong when they encounter a banana-loving monkey!")
                                .font(.body)
                               // .padding(.horizontal)
                                .frame(width: UIScreen.main.bounds.width * 0.7)
                            
                            // Text(viewModel.status)
                            
                        }
                        HStack {
                            Spacer()
                            
                            // Like button with count
                            HStack(spacing: 5) {
                                Button(action: {
                                    viewModel.likeStory(childId: childId, storyId: story.id)
                                    withAnimation {
                                        isLiked.toggle()
                                    }
                                    // reload.toggle()
                                    
                                }) {
                                    if isLiked {
                                        Image("hearts")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 44)
                                    } else {
                                        Image(systemName: "heart")
                                            .tint(.red)
                                            .font(.system(size: 24))
                                            .frame(width: 44, height: 44)
                                    }
                                }
                                
                                Text("\(isLiked ? story.likes + 1 : story.likes)")
                            }
                            .padding(.trailing)
                            .font(.system(size: 24))
                            
                            // Share button
                            Image(systemName: "paperplane")
                              
                                .font(.system(size: 24))
                        }
                        .padding()
                    }
                   
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
}

#Preview {
    HomeView(reload: .constant(false))
}
