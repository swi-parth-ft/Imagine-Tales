import SwiftUI
import Drops

// Main list view for displaying stories
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
        }
    }
}

// Single row view for displaying individual story
struct StoryRowView: View {
    var story: Story
    var childId: String
    @StateObject var viewModel = HomeViewModel()
    @State private var isLiked = false
    @State private var isSaved = false
    @State private var imgUrl = ""
    @State private var showShareList = false
    @State private var searchQuery = ""
    @State private var isShowingProfile = false
    @Binding var reload: Bool
    @Environment(\.colorScheme) var colorScheme
    // Filtered friends based on search query
    var filteredFriends: [UserChildren] {
        searchQuery.isEmpty ? viewModel.friends : viewModel.friends.filter { $0.username.localizedCaseInsensitiveContains(searchQuery) }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    // User profile image
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white)
                            .frame(width: 60)
                        Image(imgUrl.removeJPGExtension())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
                    }
                    .onTapGesture { isShowingProfile.toggle() }

                    // Story title
                    VStack {
                        Spacer()
                        Text(story.title)
                            .font(.system(size: 24))
                            .padding(.leading, 16)
                        Spacer()
                    }
                    .frame(height: 60)
                            
                    
                    Spacer()

                    // Save button
                    Button(action: {
                        viewModel.toggleSaveStory(childId: childId, storyId: story.id)
                        viewModel.sendLikeNotification(fromUserId: childId, toUserId: story.childId, storyId: story.id, storyTitle: story.title, type: isSaved ? "Unsaved" : "Saved")
                        Drops.show(Drop(title: isSaved ? "Story Unsaved" : "Story Saved", icon: UIImage(systemName: isSaved ? "bookmark" : "bookmark.fill")))
                        isSaved.toggle()
                    }) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .symbolEffect(.bounce, value: isSaved)
                            .font(.system(size: 24))
                    }
                    .tint(.primary)
                }
                .padding(.horizontal)

                // Story image
                NavigationLink(destination: StoryFromProfileView(story: story)) {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 400)
                                    .cornerRadius(30)
                                    .overlay(userProfileOverlay(), alignment: .topTrailing)
                                    .shadow(radius: 5)
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 400)
                                    .cornerRadius(10)
                                    .padding()
                            default:
                                MagicView()
                                    .frame(height: 400)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 400)
                        .cornerRadius(10)
                    }
                }

                // Story summary and actions
                HStack {
                    Text(story.summary ?? "The Minions hatch a clever plan to steal the world’s biggest banana, but things go hilariously wrong when they encounter a banana-loving monkey!")
                        .font(.body)
                        .frame(width: UIScreen.main.bounds.width * 0.7)

                    Spacer()

                    // Like button with count
                    HStack(spacing: 5) {
                        Button(action: {
                            viewModel.likeStory(childId: childId, storyId: story.id)
                            
                            viewModel.sendLikeNotification(fromUserId: childId, toUserId: story.childId, storyId: story.id, storyTitle: story.title, type: isLiked ? "Unliked" : "Liked")
                            Drops.show(Drop(title: isLiked ? "Unliked" : "Liked", icon: UIImage(systemName: isLiked ? "heart" : "heart.fill")))
                            isLiked.toggle()
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .tint(.red)
                                .font(.system(size: 24))
                                .frame(width: 44, height: 44)
                                .scaleEffect(isLiked ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: isLiked)
                        }
                        .symbolEffect(.bounce, value: isLiked)

                        Text("\(isLiked ? story.likes + 1 : story.likes)")
                    }
                    .padding(.trailing)
                    .font(.system(size: 24))

                    // Share button
                    Image(systemName: "paperplane")
                        .symbolEffect(.rotate, value: showShareList)
                        .font(.system(size: 24))
                        .onTapGesture { showShareList.toggle() }
                        .popover(isPresented: $showShareList) { sharePopover().frame(width: 300, height: 500) }
                }
                .padding(.horizontal)
            }
            .onAppear {
                setupStoryDetails()
                viewModel.fetchChild(ChildId: childId)
            }
            .fullScreenCover(isPresented: $isShowingProfile, onDismiss: { reload.toggle() }) {
                FriendProfileView(friendId: story.childId, dp: imgUrl)
            }
        }
    }

    // Helper function for setting up story details
    private func setupStoryDetails() {
        viewModel.checkIfChildLikedStory(childId: childId, storyId: story.id) { isLiked = $0 }
        viewModel.checkIfChildSavedStory(childId: childId, storyId: story.id) { isSaved = $0 }
        viewModel.checkFriendshipStatus(childId: childId, friendChildId: story.childId)
        viewModel.getProfileImage(documentID: story.childId) { imgUrl = $0 ?? "" }
    }

    // User profile overlay for the story image
    @ViewBuilder
    private func userProfileOverlay() -> some View {
        HStack {
            Text(story.childUsername)
                .font(.subheadline)
            Spacer()
            if childId != story.childId {
                Image(systemName: viewModel.status == "Friends" ? "person.crop.circle.badge.checkmark" :
                      (viewModel.status == "Pending" ? "clock" : "plus"))
                    
            }
        }
        .onTapGesture {
            if viewModel.status != "Friends" && viewModel.status != "Pending" {
                viewModel.sendFriendRequest(toChildId: story.childId, fromChildId: childId)
                Drops.show(Drop(title: "Friend Request sent to \(story.childUsername)!", icon: UIImage(systemName: "plus")))
            }
            viewModel.checkFriendshipStatus(childId: childId, friendChildId: story.childId)
        }
        .padding()
        .frame(width: 200, height: 56)
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(15)
        .padding()
    }

    // Share popover content
    @ViewBuilder
    private func sharePopover() -> some View {
        
        ZStack {
            
            BackGroundMesh().ignoresSafeArea()
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
