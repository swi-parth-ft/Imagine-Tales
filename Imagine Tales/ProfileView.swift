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

final class ReAuthentication: ObservableObject {
    @Published var reAuthenticated: Bool = false
    @Published var email = ""
    @Published var password = ""
    @Published var signedInWithGoogle = false
    
    
    func checkIfGoogle() {
        if let user = Auth.auth().currentUser {
            // Loop through the user's provider data
            for userInfo in user.providerData {
                // Check if the provider ID is Google
                if userInfo.providerID == "google.com" {
                    signedInWithGoogle = true
                    // Perform actions specific to Google-signed-in users here
                    break
                }
                
                self.email = user.email!
            }
        } else {
            print("No user is signed in.")
        }
    }
    
    func reAuthWithGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let user = Auth.auth().currentUser
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
        
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        user!.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                // Handle reauthentication error
                print("Reauthentication failed: \(error.localizedDescription)")
            } else {
                // Reauthentication was successful
                print("Reauthentication successful.")
                self.reAuthenticated = true
            }
        }
    }
    
    
    func reAuthWithEmail() {
        if let user = Auth.auth().currentUser {
            
            let email = email  // Obtain these from the user input
            let password = password    // Obtain these from the user input
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            user.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    // An error occurred while trying to reauthenticate
                    print("Reauthentication failed: \(error.localizedDescription)")
                    self.reAuthenticated = false
                } else {
                    // Reauthentication was successful
                    print("Reauthentication successful.")
                    self.reAuthenticated = true
                }
            }
        }
    }
    
    func setPin(pin: String) throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        Firestore.firestore().collection("users").document(authDataResult.uid).updateData(["pin": pin])
    }
}
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AuthDataResultModel? = nil
    @Published var child: UserChildren?
    @Published var pin: String = ""
    @Published var profileURL = ""
    @Published var numberOfFriends = 0
    @Published var imageURL: String = ""
    
    func loadUser() throws {
        user = try AuthenticationManager.shared.getAuthenticatedUser()
    }
    func logOut() throws {
        try AuthenticationManager.shared.SignOut()
    }
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                self.child = document
                self.profileURL = document.profileImage
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    func getPin() throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        Firestore.firestore().collection("users").document(authDataResult.uid).getDocument { doc, error in
            if let doc = doc, doc.exists {
                self.pin = doc.get("pin") as? String ?? "0"
                print(self.pin)
            }
        }
        
    }
    
    func getFriendsCount(childId: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2").document(childId).collection("friends")
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let documentCount = querySnapshot?.count ?? 0
                print("Number of documents: \(documentCount)")
                self.numberOfFriends = documentCount
            }
        }
    }
    
    func updateUsername(childId: String, username: String) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Specify the path to the document you want to update
        let documentReference = db.collection("Children2").document(childId)
        
        // Data to update
        let updatedData: [String: Any] = [
            "username": username  // Replace with the field name and its new value
        ]
        
        // Perform the update
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated!")
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

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @Binding var reload: Bool
    
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = true
    @AppStorage("dpurl") private var dpUrl = ""
    
    @State private var isAddingPin = false
    @StateObject var parentViewModel = ParentViewModel()
    @State private var selectedStory: Story?
    @State private var isSelectingImage = false
    @State private var profileURL = ""
    @State private var tiltAngle: Double = 0
    @State private var isEditingUsername = false
    @State private var newUsername = ""
    @FocusState private var isTextFieldFocused: Bool
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    @State private var isShowingAlert = false
    @Binding var showingProfile: Bool
    @StateObject var screenTimeViewModel = ScreenTimeManager()
    
    
    
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                VStack {
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 250, height: 250)
                                
                            AsyncCircularImageView(urlString: dpUrl, size: 200)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                .onTapGesture {
                                    isSelectingImage = true
                                }
                            
                        }
                        .onPressingChanged { point in
                            if let point {
                                self.origin = point
                                self.counter += 1
                            }
                        }
                        .modifier(RippleEffect(at: self.origin, trigger: self.counter))
                        .shadow(radius: 3, y: 2)
                        .rotation3DEffect(
                                    .degrees(tiltAngle),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        .onAppear {
                                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                    tiltAngle = 10 // Adjust this value to control the tilt range
                                }
                            }
                        VStack(alignment: .leading) {
                               HStack {
                                if isEditingUsername {
                                    TextField("\(viewModel.child?.username ?? "N/A")", text: $newUsername)
                                        .font(.title)
                                        .frame(width: 200)
                                        .focused($isTextFieldFocused)
                                        .onAppear {
                                            isTextFieldFocused = true
                                        }
                                } else {
                                    Text("@\(viewModel.child?.username ?? "N/A")")
                                        .font(.title)
                                }
                                HStack {
                                    Image(systemName: isEditingUsername ? "checkmark.circle.fill" : "pencil")
                                        .font(.title)
                                        .onTapGesture {
                                            if isEditingUsername {
                                                viewModel.updateUsername(childId: childId, username: newUsername)
                                                reload.toggle()
                                                withAnimation {
                                                    isEditingUsername = false
                                                }
                                            } else {
                                                withAnimation {
                                                    isEditingUsername = true
                                                }
                                            }
                                            
                                        }
                                    
                                    if isEditingUsername {
                                        Image(systemName: "x.circle.fill")
                                            .font(.title)
                                            .onTapGesture {
                                                withAnimation {
                                                    isEditingUsername = false
                                                }
                                                
                                            }
                                    }
                                    
                                    
                                }
                            }
                            NavigationLink(destination: FriendsView()) {
                                Text("\(viewModel.numberOfFriends) Friends")
                                    .font(.title2)
                            }
                            
                                
                        }
                        .padding()
                        Spacer()
                    }
                    
                    List {
                        Section("Your Stories") {
                            ForEach(parentViewModel.story, id: \.id) { story in
                                
                                NavigationLink(destination: StoryFromProfileView(story: story)) {
                                    
                                    HStack {
                                        VStack {
                                            Spacer()
                                            Text("\(story.title)")
                                           
                                            
                                        }
                                        Spacer()
                                        
                                        Text(story.status == "Approve" ? "Approved" : (story.status == "Reject" ? "Rejected" : "Pending"))
                                            .foregroundStyle(story.status == "Approve" ? .green : (story.status == "Reject" ? .red : .blue))
                                    }
                                    
                                }
                                .listRowBackground(Color.white.opacity(0.5))
                                
                               
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        do {
                            try parentViewModel.getStory(childId: childId)
                            viewModel.getFriendsCount(childId: childId)
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .sheet(isPresented: $isSelectingImage) {
                        DpSelectionView()
                            .background {
                                BackgroundClearView()
                            }
                    }
                    
                }
                .padding([.trailing, .leading])
                .padding(.bottom, 50)
           
                .onChange(of: reload) {
                    try? viewModel.loadUser()
                    viewModel.fetchChild(ChildId: childId)
                    viewModel.getFriendsCount(childId: childId)
                    
                    try? viewModel.getPin()
                    
                    do {
                        try parentViewModel.getStory(childId: childId)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .sheet(isPresented: $isAddingPin) {
                    PinView()
                    
                }

                CustomAlert(isShowing: $isShowingAlert, title: "Already Leaving?", message1: "You’ll miss all the fun! 😢", message2: "But don’t worry, you can come back anytime!", onConfirm: {
                    Task {
                        do {
                            try viewModel.logOut()
                            childId = ""
                            showSignInView = true
                            screenTimeViewModel.stopScreenTime()
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                            })
                
            }
            .navigationTitle("Hey, \(viewModel.child?.name ?? "N/A")")
            .onAppear {
                try? viewModel.loadUser()
                viewModel.fetchChild(ChildId: childId)
                viewModel.getFriendsCount(childId: childId)
                try? viewModel.getPin()
               
            }
            .toolbar {
                
                if showingProfile {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                            isShowingAlert = true
                            
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Parent Dashboard") {
                            
                            isAddingPin = true
                        }
                    }
                }
            }
        }
        
        
        
        
        
    }
}

struct PinView: View {
    @State private var pin = ""
    private let otpLength: Int = 4
    
    @AppStorage("ipf") private var ipf: Bool = true
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var reAuthModel = ReAuthentication()
    @State private var otp: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedIndex: Int?
    @State private var error = ""
    @State private var isResetting = false
    @State private var isPinWrong = false
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager
    var body: some View {
        ZStack {
            Color(hex: "#8AC640").ignoresSafeArea()
            VStack {
                
                Text(reAuthModel.reAuthenticated ? "Enter New PIN" : (isResetting ? "Sign in to reset PIN" : "Enter Parent PIN"))
                    .font(.title)
                    .padding(.bottom, 2)
                
                if isResetting && reAuthModel.signedInWithGoogle {
                    Text("\(reAuthModel.email)")
                }
                
                if !isResetting || reAuthModel.reAuthenticated {
                    HStack(spacing: 10) {
                        ForEach(0..<4, id: \.self) { index in
                            TextField("", text: $otp[index])
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "#D0FFD0"))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .multilineTextAlignment(.center)
                                .font(.title)
                                .keyboardType(.numberPad)
                                .focused($focusedIndex, equals: index)
                                .onChange(of: otp[index]) { newValue in
                                    if newValue.count > 1 {
                                        otp[index] = String(newValue.prefix(1))
                                    }
                                    if !newValue.isEmpty && index < 3 {
                                        focusedIndex = index + 1
                                    }
                                    
                                    if newValue.isEmpty && index > 0 {
                                        focusedIndex = index - 1
                                    }
                                }
                        }
                    }
                    .padding()
                    
                    
                    
                    Button(reAuthModel.reAuthenticated ? "Reset PIN" : "Enter to the boring side") {
                        print(viewModel.pin)
                        if reAuthModel.reAuthenticated {
                            do {
                                try reAuthModel.setPin(pin: otp.joined())
                                isResetting = false
                                reAuthModel.reAuthenticated = false
                                error = ""
                                isPinWrong = false
                                otp = Array(repeating: "", count: 4)
                                try? viewModel.getPin()
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            if otp.joined() == viewModel.pin {
                                screenTimeViewModel.stopScreenTime()
                                ipf = true
                            } else {
                                isPinWrong = true
                                error = "Incorrect PIN, Try again!"
                                otp = Array(repeating: "", count: 4)
                            }
                        }
                    }
                }
                
                Text(error).foregroundStyle(.red)
                if isResetting && !reAuthModel.reAuthenticated {
                    if reAuthModel.signedInWithGoogle {
                        Button {
                            Task {
                                do {
                                    try await reAuthModel.reAuthWithGoogle()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.white)
                                    .frame(width: 250, height: 55)
                                HStack {
                                    Image("googleIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                    
                                    Text("Continue with Google")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    } else {
                        TextField("email", text: $reAuthModel.email)
                            .padding()
                            .frame(width:  UIScreen.main.bounds.width * 0.5)
                            .background(Color(hex: "#D0FFD0"))
                            .cornerRadius(12)
                        SecureField("Password", text: $reAuthModel.password)
                            .padding()
                            .frame(width:  UIScreen.main.bounds.width * 0.5)
                            .background(Color(hex: "#D0FFD0"))
                            .cornerRadius(12)
                    }
                }
                
                if !reAuthModel.reAuthenticated  && isPinWrong {
                    Button(isResetting ? (reAuthModel.signedInWithGoogle ? "" : "Sign in") : "forgot PIN?") {
                        
                        if isResetting {
                            reAuthModel.reAuthWithEmail()
                        }
                        
                        isResetting = true
                        error = ""
                    }
                    .padding()
                }
                
                
            }
            
        }
        
        
        .onAppear {
            try? viewModel.getPin()
            focusedIndex = 0
            
            reAuthModel.checkIfGoogle()
            
        }
    }
    
}

struct StoryFromProfileView: View {
    var story: Story
    @State private var count = 0
    @State private var currentPage = 0
    @StateObject var viewModel = ParentViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    @State private var offset = CGSize.zero
  
    @State private var imgUrl = ""
    @State private var showFriendProfile = false
    
    @StateObject var homeViewModel = HomeViewModel()
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var isSaved = false
    @State private var likeObserver = false
    @AppStorage("childId") var childId: String = "Default Value"
    @State private var comment = ""
    @State private var isShowingCmt = false
    func fetchStoryAndReview(storyID: String) {
        let db = Firestore.firestore()
        
        db.collection("reviews").whereField("storyID", isEqualTo: storyID).getDocuments { snapshot, error in
                if let snapshot = snapshot, let document = snapshot.documents.first {
                    let reviewNotes = document.data()["parentReviewNotes"] as? String
                    self.comment = reviewNotes ?? "No Comments"
                    
                } else {
                    
                }
            }
        
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh()
                ScrollView {
                    VStack {
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                
                                VStack {
                                    AsyncImage(url: URL(string: story.storyText[count].image)) { phase in
                                        switch phase {
                                        case .empty:
                                            GradientRectView(size: 500)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 500)
                                                .clipped()
                                                .cornerRadius(30)
                                                .overlay(
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.white)
                                                            .frame(width: 110)
                                                        AsyncDp(urlString: imgUrl, size: 100)
                                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                            .id(imgUrl)
                                                    }
                                                        .padding()
                                                    .onTapGesture {
                                                        showFriendProfile = true
                                                    }
                                                    , alignment: .topLeading
                                                )
                                                .padding()
                                                .onPressingChanged { point in
                                                    if let point {
                                                        self.origin = point
                                                        self.counter += 1
                                                    }
                                                }
                                                .modifier(RippleEffect(at: self.origin, trigger: self.counter))
                                                .shadow(radius: 3, y: 2)
                                            
                                            
                                        case .failure(_):
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .padding()
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 500)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                                    
                                    Text(story.storyText[count].text)
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
                                        .padding()
                                    
                                }
                                .padding(.top)
                                .id(count)
                                .transition(shader.transition)
                                .onAppear {
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
                                                        print(count)
                                                        print(story.storyText.count)
                                                        withAnimation(.easeIn(duration: 0.7)) {
                                                            count -= 1
                                                        }
                                                        
                                                    }
                                                
                                                
                                                Image(systemName: "arrowshape.backward.fill")
                                            }
                                        }
                                        Spacer()
                                        if count < story.storyText.count - 1{
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
                                                        print(count)
                                                        print(story.storyText.count)
                                                        withAnimation(.easeIn(duration: 0.7)) {
                                                            count += 1
                                                        }
                                                        
                                                    }
                                                
                                                
                                                Image(systemName: "arrowshape.bounce.right.fill")
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                .padding()
                                .padding(.bottom, 40)
                            }
                        }
                        
                        
                    }
                    .padding()
                    .navigationTitle(story.title)
                    .toolbar {
                        HStack {
                            Button(action: {
                                homeViewModel.toggleSaveStory(childId: childId, storyId: story.id)
                                isSaved.toggle()
                                
                            }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                    )
                                
                            }
                            
                                Button(action: {
                                    homeViewModel.likeStory(childId: childId, storyId: story.id)
                                    
                                    isLiked.toggle()
                                    // reload.toggle()
                                    
                                }) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .foregroundStyle(
                                            LinearGradient(gradient: Gradient(colors: [Color.red, Color.pink]),
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                        )
                                        .scaleEffect(isLiked ? 1.2 : 1)
                                        .animation(.easeInOut, value: isLiked)
                                }
                            if childId == story.childId && comment != "" {
                                Button("", systemImage: "message.fill") {
                                    isShowingCmt.toggle()
                                }
                            }
                            
                            }
                    }
                
                }
                .alert("Parent's Comment", isPresented: $isShowingCmt) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(comment)
                        }
                .fullScreenCover(isPresented: $showFriendProfile) {
                    FriendProfileView(friendId: story.childId, dp: imgUrl)
                }
                .onAppear {
                    homeViewModel.checkIfChildLikedStory(childId: childId, storyId: story.id) { hasLiked in
                        isLiked = hasLiked
                        if isLiked {
                            likeObserver = true
                        }
                        
                        
                    }
                    
                    homeViewModel.checkIfChildSavedStory(childId: childId, storyId: story.id) { hasSaved in
                        isSaved = hasSaved
                        print(isSaved)
                    }
                    
                    fetchStoryAndReview(storyID: story.id)
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


