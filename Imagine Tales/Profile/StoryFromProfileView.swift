//
//  StoryFromProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseFirestore // Import Firestore for database operations

struct StoryFromProfileView: View {
    var story: Story // The story object passed to this view
    @State private var count = 0 // Index to track the current page of the story
    @State private var currentPage = 0 // Current page (if pagination is used)
    @StateObject var viewModel = ParentViewModel() // ViewModel for parent data
    @StateObject var profileViewModel = ProfileViewModel() // ViewModel for profile data
    
    @State var counter: Int = 0 // Counter for gesture effects
    @State var origin: CGPoint = .zero // Origin point for ripple effect
    @State private var offset = CGSize.zero // Offset for any animation (unused)
  
    @State private var imgUrl = "" // URL for the user's profile image
    @State private var showFriendProfile = false // Flag to show friend's profile
    
    @StateObject var homeViewModel = HomeViewModel() // ViewModel for home data
    @State private var isLiked = false // Flag to track if the story is liked
    @State private var isSaved = false // Flag to track if the story is saved
    @State private var likeObserver = false // Flag to track like status
    @AppStorage("childId") var childId: String = "Default Value" // Child ID stored in app storage
    @State private var comment = "" // Comment from the parent
    @State private var isShowingCmt = false // Flag to show comment alert

    // Function to fetch story reviews from Firestore
    func fetchStoryAndReview(storyID: String) {
        let db = Firestore.firestore()
        
        db.collection("reviews").whereField("storyID", isEqualTo: storyID).getDocuments { snapshot, error in
            if let snapshot = snapshot, let document = snapshot.documents.first {
                let reviewNotes = document.data()["parentReviewNotes"] as? String
                self.comment = reviewNotes ?? "No Comments" // Set comment if available
            } else {
                // Handle error (optional)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Custom background view
                ScrollView {
                    VStack {
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                // Background blur effect for the story container
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                
                                VStack {
                                    // Async image loading for the story's image
                                    AsyncImage(url: URL(string: story.storyText[count].image)) { phase in
                                        switch phase {
                                        case .empty:
                                            GradientRectView(size: 500) // Placeholder while loading
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 500)
                                                .clipped()
                                                .cornerRadius(30)
                                                .overlay(
                                                    ZStack {
                                                        Circle() // Profile image background
                                                            .fill(Color.white)
                                                            .frame(width: 110)
                                                        // Display profile image
                                                        Image(imgUrl.removeJPGExtension())
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 100, height: 100)
                                                            .cornerRadius(50)
                                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                    }
                                                    .padding()
                                                    .onTapGesture {
                                                        showFriendProfile = true // Show friend's profile on tap
                                                    },
                                                    alignment: .topLeading
                                                )
                                                .padding()
                                                .onPressingChanged { point in
                                                    if let point {
                                                        self.origin = point
                                                        self.counter += 1
                                                    }
                                                }
                                                .modifier(RippleEffect(at: self.origin, trigger: self.counter)) // Custom ripple effect
                                                .shadow(radius: 3, y: 2)
                                            
                                        case .failure(_):
                                            Image(systemName: "photo") // Placeholder for failed image load
                                                .resizable()
                                                .scaledToFit()
                                                .padding()
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .id(imgUrl) // Unique ID for the image view
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 500)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                                    
                                    // Display the story text
                                    Text(story.storyText[count].text)
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
                                        .padding()
                                }
                                .padding(.top)
                                .id(count) // Unique ID for the count
                                .onAppear {
                                    // Fetch the user's profile image
                                    profileViewModel.getProfileImage(documentID: story.childId) { profileImage in
                                        if let imageUrl = profileImage {
                                            imgUrl = imageUrl
                                        } else {
                                            print("Failed to retrieve profile image.")
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .safeAreaInset(edge: .bottom) {
                            HStack {
                                Spacer()
                                ZStack {
                                    HStack {
                                        // Back button if not on the first page
                                        if count != 0 {
                                            ZStack {
                                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(50)
                                                    .overlay(
                                                        Circle() // Circular stroke
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                    .onTapGesture {
                                                        withAnimation(.easeIn(duration: 0.7)) {
                                                            count -= 1 // Go to previous page
                                                        }
                                                    }
                                                
                                                Image(systemName: "arrowshape.backward.fill") // Backward arrow icon
                                            }
                                        }
                                        Spacer()
                                        // Next button if not on the last page
                                        if count < story.storyText.count - 1 {
                                            ZStack {
                                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(50)
                                                    .overlay(
                                                        Circle() // Circular stroke
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                    .onTapGesture {
                                                        withAnimation(.easeIn(duration: 0.7)) {
                                                            count += 1 // Go to next page
                                                        }
                                                    }
                                                Image(systemName: "arrowshape.bounce.right.fill") // Forward arrow icon
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .padding(.bottom, 40) // Padding for safe area
                            }
                        }
                    }
                    .padding()
                    .navigationTitle(story.title) // Set the title of the navigation bar
                    .toolbar {
                        HStack {
                            // Button to save the story
                            Button(action: {
                                homeViewModel.toggleSaveStory(childId: childId, storyId: story.id)
                                isSaved.toggle()
                            }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark") // Toggle bookmark icon
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                    )
                            }
                            
                            // Button to like the story
                            Button(action: {
                                homeViewModel.likeStory(childId: childId, storyId: story.id)
                                isLiked.toggle() // Toggle like status
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart") // Toggle heart icon
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [Color.red, Color.pink]),
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                    )
                                    .scaleEffect(isLiked ? 1.2 : 1) // Scale effect on like
                                    .animation(.easeInOut, value: isLiked) // Animation for like toggle
                            }
                            
                            // Show comment button if the user is the child's parent and there is a comment
                            if childId == story.childId && comment != "" {
                                Button("", systemImage: "message.fill") {
                                    isShowingCmt.toggle() // Toggle comment alert
                                }
                            }
                        }
                    }
                }
                .alert("Parent's Comment", isPresented: $isShowingCmt) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(comment) // Display the parent's comment
                }
                .fullScreenCover(isPresented: $showFriendProfile) {
                    FriendProfileView(friendId: story.childId, dp: imgUrl) // Show friend's profile in full screen
                }
                .onAppear {
                    // Check if the child has liked the story
                    homeViewModel.checkIfChildLikedStory(childId: childId, storyId: story.id) { hasLiked in
                        isLiked = hasLiked
                        if isLiked {
                            likeObserver = true // Update like observer
                        }
                    }
                    
                    // Check if the child has saved the story
                    homeViewModel.checkIfChildSavedStory(childId: childId, storyId: story.id) { hasSaved in
                        isSaved = hasSaved // Update saved status
                    }
                    
                    fetchStoryAndReview(storyID: story.id) // Fetch comments for the story
                }
            }
        }
    }
}
