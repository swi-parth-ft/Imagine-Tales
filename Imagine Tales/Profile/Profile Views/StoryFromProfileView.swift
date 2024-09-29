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
    @Environment(\.colorScheme) var colorScheme
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
    
    @State private var isExpanding = false

    

    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Custom background view
                ScrollView {
                    VStack {
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                
                                VStack(spacing: isExpanding ? -30 : -80) {
                                    // Async image loading for the story's image
                                    AsyncImage(url: URL(string: story.storyText[count].image)) { phase in
                                        switch phase {
                                        case .empty:
                                            ZStack {
                                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : 700)
                                                    .cornerRadius(20)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                MagicView()
                                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 700)
                                            }
                                                
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : 700)
                                                .clipped()
                                                .cornerRadius(23)
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
                                                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20) // Adds shadow at the bottom
                                            
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
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : 700)
                                    .cornerRadius(23)
                                    .shadow(radius: 10)
                                    .onTapGesture {
                                        withAnimation {
                                            isExpanding.toggle()
                                        }
                                        // Schedule the second toggle after 5 seconds
                                        if isExpanding {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                                withAnimation {
                                                    isExpanding = false
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    VStack(spacing: -20) {
                                        
                                        HStack(spacing: 8) {
                                            ForEach(0..<story.storyText.count, id: \.self) { index in
                                                        Rectangle()
                                                    .fill(index == count ? Color.orange : Color.gray.opacity(0.3))
                                                            .frame(height: 10)
                                                            .cornerRadius(5)
                                                    }
                                                }
                                                .padding()
                                        
                                        // Display the story text
                                        Text(story.storyText[count].text)
                                            .font(.system(size: 23))
                                            .padding()
                                        
                                        ZStack {
                                            HStack(spacing: 20) {
                                                Button {
                                                    if count > 0 {
                                                        withAnimation {
                                                            count -= 1
                                                        }
                                                    }
                                                } label: {
                                                    ZStack {
                                                        Circle()
                                                            .fill(count == 0 ? .gray : Color(hex: "#8AC640"))
                                                            .frame(width: 64, height: 64)
                                                        Image(systemName: "arrowtriangle.backward.fill")
                                                            .font(.system(size: 30))
                                                            .foregroundStyle(.white)
                                                    }
                                                }
                                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10) // Adds shadow at the bottom
                                                
                                                Button {
                                                    if count < story.storyText.count - 1 {
                                                        withAnimation {
                                                            count += 1
                                                        }
                                                    }
                                                
                                                } label: {
                                                    ZStack {
                                                        Circle()
                                                            .fill(count == story.storyText.count - 1 ? .gray : Color(hex: "#8AC640"))
                                                            .frame(width: 64, height: 64)
                                                        Image(systemName: "arrowtriangle.forward.fill")
                                                            .font(.system(size: 30))
                                                            .foregroundStyle(.white)
                                                    }
                                                }
                                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10) // Adds shadow at the bottom
                                            }
                                            HStack {
//                                                Button("Speak") {
//                                                    
//                                                    let openAITTS = OpenAITTS()
//
//                                                    // Example text to be converted to speech
//                                                    let textToSpeak = "Hello, welcome to Imagine Tools, your creative story assistant."
//
//                                                    // Call the speak function to send the request
//                                                    openAITTS.speak(textToSpeak)
//                                                }
                                                
                                                Spacer()
                                            }
                                            
                                         
                                        }
                                        .padding()
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.8)
                                    .background(
                                        // Background blur effect for the story container
                                        VisualEffectBlur(blurStyle: .systemThinMaterial)
                                            .frame(width: UIScreen.main.bounds.width * 0.9)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)

                                    )
                                    .cornerRadius(23)
                                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20) // Adds shadow at the bottom
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
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
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
