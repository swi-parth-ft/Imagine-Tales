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
        
        // Firestore.firestore().collection("users").document(userId).updateData(["pin": pin])
    }
    
    
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @Binding var reload: Bool
    
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = true
    @State private var isAddingPin = false
    @StateObject var parentViewModel = ParentViewModel()
    @State private var selectedStory: Story?
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                VStack {
                    List {
                        Text("Your Stories")
                            .font(.title)
                            .fontWeight(.bold)
                            .listRowBackground(Color.white.opacity(0.5))
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
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        do {
                            try parentViewModel.getStory(childId: childId)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
                .padding([.trailing, .leading])
                .padding(.bottom, 50)
           
                .onChange(of: reload) {
                    try? viewModel.loadUser()
                    viewModel.fetchChild(ChildId: childId)
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
                
                
            }
            .navigationTitle("Hey, \(viewModel.child?.name ?? "N/A")")
            .onAppear {
                try? viewModel.loadUser()
                viewModel.fetchChild(ChildId: childId)
                try? viewModel.getPin()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                        Task {
                            do {
                                try viewModel.logOut()
                                childId = ""
                                showSignInView = true
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                        }
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
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    
    @State private var offset = CGSize.zero
    
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
                                            GradientRectView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 500)
                                                .clipped()
                                                .cornerRadius(30)
                                            
                                                .padding()
                                            
                                            
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
                            }
                            
                        }
                        .padding()
                        
                        HStack {
                            Spacer()
                            ZStack {
                                HStack {
                                    if count != 0 {
                                        ZStack {
                                            
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(20)
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
                                            
//                                            Circle()
//                                                .fill(.orange)
//                                                .frame(width: 100, height: 100)
//                                                .onTapGesture {
//                                                    print(count)
//                                                    print(story.storyText.count)
//                                                    withAnimation(.easeIn(duration: 1.5)) {
//                                                        count -= 1
//                                                    }
//                                                    
//                                                }
                                            
                                            Image(systemName: "arrowshape.backward.fill")
                                        }
                                    }
                                    Spacer()
                                    if count < story.storyText.count - 1{
                                        ZStack {
                                            
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(20)
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
                                            
//                                            Circle()
//                                                .fill(.orange)
//                                                .frame(width: 100, height: 100)
//                                                .onTapGesture {
//                                                    print(count)
//                                                    print(story.storyText.count)
//                                                    withAnimation(.easeIn(duration: 1.5)) {
//                                                        count += 1
//                                                    }
//                                                    
//                                                }
                                            
                                            Image(systemName: "arrowshape.bounce.right.fill")
                                        }
                                    }
                                }
                                
                                
                            }
                            .padding()
                            .padding(.bottom, 40)
                        }
                    }
                    .padding()
                    .navigationTitle(story.title)
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
    ProfileView(showSignInView: .constant(false), reload: .constant(false))
    
}


