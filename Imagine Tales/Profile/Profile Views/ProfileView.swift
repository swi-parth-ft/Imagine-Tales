//
//  ProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseStorage

/// View representing the user's profile, displaying personal information and stories.
struct ProfileView: View {
    
    // StateObject for managing profile data and interactions
    @StateObject private var viewModel = ProfileViewModel()
    
    // Binding variables to manage the visibility of sign-in view and reload state
    @Binding var showSignInView: Bool
    @Binding var reload: Bool
    
    // AppStorage variables to store persistent user data
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = true
    @AppStorage("dpurl") private var dpUrl = ""
    
    // State variables for UI state management
    @State private var isAddingPin = false // To manage the display of the pin entry view
    @StateObject var parentViewModel = ParentViewModel() // ViewModel for managing parent-related data
    @State private var selectedStory: Story? // The currently selected story for navigation
    @State private var isSelectingImage = false // To manage the image selection process
    @State private var profileURL = "" // URL for the user's profile image
    @State private var tiltAngle: Double = 0 // Angle for any tilt effects (not currently used)
    @State private var isEditingUsername = false // To toggle username editing mode
    @State private var newUsername = "" // Holds the new username input by the user
    @FocusState private var isTextFieldFocused: Bool // Focus state for the username text field
    @State var counter: Int = 0 // Counter for ripple effect on the profile image
    @State var origin: CGPoint = .zero // Origin point for the ripple effect
    @State private var isShowingAlert = false // To trigger the log out confirmation alert
    @Binding var showingProfile: Bool // Binding to manage profile visibility
    @StateObject var screenTimeViewModel = ScreenTimeManager() // ViewModel for managing screen time
    
    // State variables for navigation and UI state
    @State private var isNavigating = false
    @State private var openingStory: Story?
    @State private var isShowingSharedStories = false // Toggle for displaying shared stories
    @Environment(\.colorScheme) var colorScheme
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let columnsLandscape = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @State private var retryCount = 0 // Count for retry attempts when loading images
    @State private var maxRetryAttempts = 6 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retries
    @EnvironmentObject var orientation: OrientationManager
    @State private var isExpanding = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Profile header section
                    HStack {
                        VStack {
                            // Profile image and ripple effect
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white) // Background for the profile image
                                    .frame(width: isExpanding ? 250 : 70, height: isExpanding ? 250 : 70)
                                
                                Image((viewModel.child?.profileImage.removeJPGExtension() ?? ""))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: isExpanding ? 200 : 50, height: isExpanding ? 200 : 50)
                                    .cornerRadius(100) // Circular profile image
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Shadow effect
                                    .onTapGesture {
                                        isSelectingImage = true // Trigger image selection on tap
                                    }
                            }
                            .onPressingChanged { point in
                                if let point = point {
                                    self.origin = point // Update ripple effect origin
                                    self.counter += 1 // Increment counter for ripple effect
                                }
                            }
                            .modifier(RippleEffect(at: self.origin, trigger: self.counter)) // Apply ripple effect
                            .shadow(radius: 3, y: 2) // Additional shadow for profile image
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                // Username editing or display
                                if isEditingUsername {
                                    TextField("\(viewModel.child?.username ?? "Loading...")", text: $newUsername)
                                        .font(.title)
                                        .frame(width: 200)
                                        .focused($isTextFieldFocused)
                                        .onAppear {
                                            isTextFieldFocused = true // Focus the text field on appearance
                                        }
                                } else {
                                    Text("@\(viewModel.child?.username ?? "Loading...")")
                                        .font(.title)
                                }
                                // Username edit and cancel buttons
                                HStack {
                                    Image(systemName: isEditingUsername ? "checkmark.circle.fill" : "pencil")
                                        .font(.title)
                                        .onTapGesture {
                                            if isEditingUsername {
                                                // Update username and toggle editing mode
                                                if !newUsername.isEmpty {
                                                    let un = newUsername.replacingOccurrences(of: " ", with: "_")
                                                    viewModel.updateUsername(childId: childId, username: un)
                                                }
                                                reload.toggle()
                                                withAnimation {
                                                    isEditingUsername = false
                                                }
                                            } else {
                                                withAnimation {
                                                    isEditingUsername = true // Enter editing mode
                                                }
                                            }
                                        }
                                    
                                    // Cancel button for editing username
                                    if isEditingUsername {
                                        Image(systemName: "x.circle.fill")
                                            .font(.title)
                                            .onTapGesture {
                                                withAnimation {
                                                    isEditingUsername = false // Exit editing mode
                                                }
                                            }
                                    }
                                }
                            }
                            // Navigation to FriendsView
                            NavigationLink(destination: FriendsView()) {
                                Text("\(viewModel.numberOfFriends) Friends")
                                    .font(.title2)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    
                    
                    .padding([.trailing, .leading])
                    // Button to toggle between "Your Stories" and "Shared with you"
                    HStack(alignment: .bottom) {
                        Text(isShowingSharedStories ? "Shared with you (\(viewModel.sharedStories.count))" : "Your Stories (\(parentViewModel.storyCount))")
                            .font(.title2)
                        Spacer()
                        Button(isShowingSharedStories ? "Your Stories" : "Shared with you", systemImage: isShowingSharedStories ? "book.fill" : "paperplane.fill") {
                            withAnimation {
                                isShowingSharedStories.toggle() // Toggle shared stories view
                                if !isShowingSharedStories {
                                    parentViewModel.story = []
                                    Task {
                                        await parentViewModel.getStorie(isLoadMore: false, childId: childId)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(hex: "#5A6D2A") : Color(hex: "#8AC640")) // Background color for the button
                        .foregroundStyle(.white) // Text color
                        .cornerRadius(22) // Rounded corners
                    }
                    .padding(.horizontal)
                    
                    // Display user's stories or shared stories based on selection
                    if !isShowingSharedStories {
                        if parentViewModel.story.isEmpty {
                            if viewModel.sharedStories.isEmpty {
                                // Placeholder when no shared stories are available
                                ContentUnavailableView {
                                    Label("No Stories Yet", systemImage: "books.vertical")
                                } description: {
                                    Text("Stories you generate will appear here.")
                                } actions: {
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        ScrollView {
                                    LazyVGrid(columns: columns, spacing: 23) {
                                        ForEach(parentViewModel.story, id: \.id) { story in
                                            ZStack {
                                                // Load the story image asynchronously
                                                AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        MagicView()
                                                            .frame(width: UIScreen.main.bounds.width * 0.45, height: 500)
                                                        
                                                    case .success(let image):
                                                        // Successfully loaded image
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: UIScreen.main.bounds.width * 0.45, height: 500)
                                                            .clipped()
                                                            .cornerRadius(16)
                                                        
                                                    case .failure(_):
                                                        // Placeholder for failed load
                                                        Image(systemName: "photo")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: UIScreen.main.bounds.width * 0.45, height: 500)
                                                            .cornerRadius(16)
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
                                                            .frame(width: UIScreen.main.bounds.width * 0.43, height: 200)
                                                            .cornerRadius(16)
                                                        
                                                        VStack(spacing: 0) {
                                                            
                                                            Text(story.title)
                                                                .font(.system(size: 18))
                                                            Text(story.status == "Approve" ? "Approved" : (story.status == "Reject" ? "Rejected" : "Pending" ))
                                                                .font(.system(size: 16))
                                                                .bold()
                                                                .foregroundStyle(story.status == "Approve" ? .green : (story.status == "Reject" ? .red : .blue ))
                                                                .padding(.top, -20)
                                                            HStack {
                                                                Image(systemName: "heart.fill")
                                                                    .foregroundStyle(.red)
                                                                Text("\(story.likes) Likes")
                                                                    .padding(.trailing)
                                                                
                                                                Text(story.theme ?? "")
                                                                    .padding(7)
                                                                    .background(colorScheme == .dark ? Color(hex: "#4B8A1C") : .green)
                                                                    .foregroundStyle(.white)
                                                                    .cornerRadius(22)
                                                                    
                                                            }
                                                            .font(.system(size: 16))
                                                            .padding(.top)
                                                            Button {
                                                                selectedStory = story
                                                            } label: {
                                                                HStack {
                                                                    Text("Read Now")
                                                                    Image(systemName: "book.pages")
                                                                }
                                                                .frame(width: UIScreen.main.bounds.width * 0.35)
                                                            }
                                                            .padding()
                                                            .font(.system(size: 16))
                                                            .background(Color(hex: "#FF6F61"))
                                                            .foregroundStyle(.white)
                                                            .cornerRadius(16)
                                                            .padding(.top)
                                                        }
                                                        .foregroundStyle(.black)
                                                        
                                                    }
                                                    .padding(.bottom, 10)
                                                }
                                            }
                                            .onAppear {
                                                if !orientation.isLandscape {
                                                    if story.id == parentViewModel.story[6].id {
                                                        withAnimation {
                                                            isExpanding = false
                                                        }
                                                    } else if story.id == parentViewModel.story[1].id {
                                                        withAnimation {
                                                            isExpanding = true
                                                        }
                                                    }
                                                }
                                            }
                                            

                                            if story == parentViewModel.story.last {
                                                ProgressView()
                                                    .onAppear {
                                                        Task {
                                                            await parentViewModel.getStorie(isLoadMore: true, childId: childId)
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                    .padding()
                                }
                        .padding(.bottom, 40)
                        .fullScreenCover(item: $selectedStory) { story in
                                StoryFromProfileView(story: story)
                        }
                        .onAppear {
                            // Fetch user's stories and friend count on appear
                            Task {
                                await parentViewModel.getStorie(isLoadMore: false, childId: childId)
                            }
                            
//                                try parentViewModel.getStory(childId: childId)
                                
                                viewModel.getFriendsCount(childId: childId)
                          
                        }
                        
                    } else {
                        
                        
                        // Display stories shared with the user
                        List {
                            
                                if viewModel.sharedStories.isEmpty {
                                    // Placeholder when no shared stories are available
                                    ContentUnavailableView {
                                        Label("No Stories Yet", systemImage: "paperplane.fill")
                                    } description: {
                                        Text("Stories shared with you will appear here.")
                                    } actions: {
                                    }
                                    .listRowBackground(Color.clear)
                                }
                                // Display shared stories in a list
                                ForEach(viewModel.sharedStories, id: \.self) { s in
                                    NavigationLink(destination: StoryFromProfileView(story: s.story)) {
                                        ZStack {
                                            HStack {
                                                Image("\(s.story.theme?.filter { !$0.isWhitespace } ?? "")1")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .opacity(colorScheme == .dark ? 0.6 : 0.3)
                                                    .frame(width: 300, height: 300)
                                                Spacer()
                                                Image("\(s.story.theme?.filter { !$0.isWhitespace } ?? "")2")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .opacity(colorScheme == .dark ? 1 : 0.5)
                                                    .frame(width: 70, height: 70)
                                                Spacer()
                                            }
                                            .frame(height: 100) // Fixed height for story preview
                                            HStack {
                                                VStack {
                                                    Text("\(s.story.title)")
                                                        .font(.custom("ComicNeue-Bold", size: 32))
                                                        .padding([.leading, .bottom])
                                                }
                                                Spacer()
                                                VStack(alignment: .trailing) {
                                                    Text("Shared By,")
                                                    Text("\(s.fromId)") // Display the ID of the user who shared the story
                                                }
                                                .padding(.trailing)
                                            }
                                            .contentShape(Rectangle()) // Expand tappable area
                                        }
                                        .padding(.vertical)
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4)) // Background for shared story item
                                        .cornerRadius(22) // Rounded corners for shared story item
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 0)
                                        .contentShape(Rectangle()) // Expand tappable area
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.white.opacity(0)) // Transparent row background
                                    .listRowSeparator(.hidden) // Hide row separator
                                }
                                // Allow deletion of shared stories
                                .onDelete { indexSet in
                                    if let index = indexSet.first {
                                        viewModel.deleteSharedStory(childId: childId, id: viewModel.sharedStories[index].id)
                                        viewModel.fetchSharedStories(childId: childId) // Refresh shared stories after deletion
                                    }
                                }
                            
                        }
                        .scrollContentBackground(.hidden)
                        .onAppear {
                            // Fetch shared stories on appear
                            viewModel.fetchSharedStories(childId: childId)
                        }
                    }
                }
                .padding(.bottom, 50)
                .onChange(of: reload) {
                    // Handle reload event to refresh user and stories data
                    try? viewModel.loadUser()
                    viewModel.fetchChild(ChildId: childId)
                    viewModel.getFriendsCount(childId: childId)
                    try? viewModel.getPin()
//                    Task {
//                        await parentViewModel.getStorie(isLoadMore: true, childId: childId)
//                    }
                    do {
                        
                       // try parentViewModel.getStory(childId: childId)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                // Modal sheet for adding a pin
                .sheet(isPresented: $isAddingPin) {
                    PinView()
                }
                // Modal sheet for selecting a profile image
                .sheet(isPresented: $isSelectingImage, onDismiss: {
                    viewModel.fetchChild(ChildId: childId) // Refresh after image selection
                }) {
                    DpSelectionView()
                }

                // Custom alert for log out confirmation
                CustomAlert(isShowing: $isShowingAlert, title: "Already Leaving?", message1: "You’ll miss all the fun! 😢", message2: "But don’t worry, you can come back anytime!", onConfirm: {
                    Task {
                        do {
                            screenTimeViewModel.stopScreenTime() // Stop screen time tracking
                            try viewModel.logOut() // Log out the user
                            showSignInView = true // Show sign-in view
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                })
            }
            .navigationTitle("Hey, \(viewModel.child?.name ?? "Loading...")") // Navigation title
            .onAppear {
                    if orientation.isLandscape {
                        isExpanding = false
                    }
                
                // Load user data and stories on appear
                parentViewModel.countDocumentsWithChildId(childId: childId)
                
                try? viewModel.loadUser()
                viewModel.fetchChild(ChildId: childId)
                viewModel.getFriendsCount(childId: childId)
                try? viewModel.getPin()
            }
            // Toolbar items for logging out and accessing the parent dashboard
            .toolbar {
                if showingProfile {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                            isShowingAlert = true // Show alert for log out confirmation
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Parent Dashboard") {
                            isAddingPin = true // Show pin entry view
                        }
                    }
                }
            }
        }
    }
}

// Helper view to add a blur effect
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var intensity: CGFloat? = nil

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false), reload: .constant(false), showingProfile: .constant(true))
}
