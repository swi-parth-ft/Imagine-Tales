//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI

import Drops



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
            .onAppear {
                viewModel.fetchChild(ChildId: childId)
                viewModel.fetchFriends(childId: childId)
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
//            .padding(.bottom, 50)
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
    @State private var showShareList = false
    @State private var searchQuery = ""
    @State private var isShowingProfile = false
    
    var filteredFriends: [UserChildren] {
            if searchQuery.isEmpty {
                return viewModel.friends
            } else {
                return viewModel.friends.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
            }
        }
    
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
                             //   AsyncDp(urlString: imgUrl, size: 50)
                                Image(imgUrl.removeJPGExtension())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
                            }
                                .padding(.bottom, 30)
                                .onTapGesture {
                                    isShowingProfile.toggle()
                                }
                            Text(story.title)
                                .font(.system(size: 24))
                            // Adjust font weight if needed
                                .padding(.leading, 16) // Add padding to align the text properly
                            
                            Spacer() // Spacer to push icons to the right
                            
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    viewModel.toggleSaveStory(childId: childId, storyId: story.id)
                                    
                                    let drop = Drop(title: isSaved ? "Story Unsaved" : "Story Saved", icon: UIImage(systemName: isSaved ? "bookmark" : "bookmark.fill"))
                                    Drops.show(drop)
                                    isSaved.toggle()
                                  //  reload.toggle()
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
                                                                let drop = Drop(title: "Friend Request to sent \(story.childUsername)!", icon: UIImage(systemName: "plus"))
                                                                Drops.show(drop)
                                                            }
                                                        }
                                                        
                                                        viewModel.checkFriendshipStatus(childId: childId, friendChildId: story.childId)
                                                        
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
                            Text(story.summary ?? "The Minions hatch a clever plan to steal the world’s biggest banana, but things go hilariously wrong when they encounter a banana-loving monkey!")
                                .font(.body)
                                .padding(.leading)
                                .frame(width: UIScreen.main.bounds.width * 0.7)
                            
                            // Text(viewModel.status)
                            
                        }
                        HStack {
                            Spacer()
                            
                            // Like button with count
                            HStack(spacing: 5) {
                                Button(action: {
                                    viewModel.likeStory(childId: childId, storyId: story.id)
                                    let drop = Drop(title: isLiked ? "Unlinked" : "Liked", icon: UIImage(systemName: isLiked ? "heart" : "heart.fill" ))
                                    Drops.show(drop)
                                    withAnimation {
                                        isLiked.toggle()
                                    }
                                    // reload.toggle()
                                    
                                }) {
                                    if isLiked {
                                        Image(systemName: "heart.fill")
                                            .tint(.red)
                                            .font(.system(size: 24))
                                            .frame(width: 44, height: 44)
                                            
                                    } else {
                                        Image(systemName: "heart")
                                            .tint(.red)
                                            .font(.system(size: 24))
                                            .frame(width: 44, height: 44)
                                    }
                                }
                                .symbolEffect(.bounce, value: isLiked)
                                
                                Text("\(isLiked ? story.likes + 1 : story.likes)")
                            }
                            .padding(.trailing)
                            .font(.system(size: 24))
                            
                            // Share button
                            Image(systemName: "paperplane")
                              
                                .font(.system(size: 24))
                                .onTapGesture {
                                    withAnimation {
                                        showShareList.toggle()
                                    }
                                }
                                .popover(isPresented: $showShareList) {
                                    ZStack {
                                        Color(hex: "#8AC640").ignoresSafeArea()
                                        VStack {
                                            
                                            List {
                                                Section("Share with Friends") {
                                                    TextField("Search Friends", text: $searchQuery)
                                                        .listRowBackground(Color.white.opacity(0.4))
                                                    ForEach(filteredFriends) { friend in
                                                        HStack {
                                                            ZStack {
                                                                Circle()
                                                                    .fill(Color.white)
                                                                    .frame(width: 50)
                                                                Image(friend.profileImage.removeJPGExtension())
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 40, height: 40)
                                                                    .cornerRadius(50)
                                                            }
                                                       
                                                            Text(friend.username)
                                                                .foregroundStyle(.black)
                                                            
                                                       
                                                            
                                                        }
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            viewModel.addSharedStory(childId: friend.id, fromId: viewModel.child?.username ?? "", toId: friend.id, storyId: story.id)
                                                            let drop = Drop(title: "Shared Story with \(friend.username)")
                                                           
                                                            Drops.show(drop)
                                                            
                                                        }
                                                        
                                                        .listRowBackground(Color.white.opacity(0.4))
                                                     
                                                    }
                                                }
                                            }
                                            .searchable(text: $searchQuery, prompt: "Search Friends")
                                            .scrollContentBackground(.hidden)
                                            .frame(width: 300, height: 500)
                                            .onAppear {
                                                viewModel.fetchChild(ChildId: childId)
                                                viewModel.fetchFriends(childId: childId)
                                            }
                                        }
                                    }
                                }
                            
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
                    
                    viewModel.checkFriendshipStatus(childId: childId, friendChildId: story.childId)
                }
                
            }
            .fullScreenCover(isPresented: $isShowingProfile, onDismiss: { reload.toggle() } ) {
                FriendProfileView(friendId: story.childId, dp: imgUrl)
            }
        }
    }
}
extension String {
    func removeJPGExtension() -> String {
        return self.replacingOccurrences(of: ".jpg", with: "")
    }
}
#Preview {
    HomeView(reload: .constant(false))
}
