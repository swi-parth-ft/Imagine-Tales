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
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(hex: "#FFFFF1").ignoresSafeArea()
                VStack {
                        Button("Log out") {
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
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.7)
                        .background(Color(hex: "#FF6F61"))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    
                    Button("Parent Dashboard") {
                        
                        isAddingPin = true
                    }
                    
                    
                    
                }
                .padding([.trailing, .leading])
                .padding(.top, 100)
                .onChange(of: reload) { 
                    try? viewModel.loadUser()
                    viewModel.fetchChild(ChildId: childId)
                    try? viewModel.getPin()
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
            
            Text(reAuthModel.reAuthenticated ? "Enter New PIN" : "Enter Parent PIN")
                .font(.title)
                .padding(.bottom, 2)
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
                    Button("reAuth") {
                        Task {
                            do {
                                try await reAuthModel.reAuthWithGoogle()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                } else {
                    TextField("email", text: $reAuthModel.email)
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.5)
                        .background(Color(hex: "#D0FFD0"))
                        .cornerRadius(12)
                    TextField("Password", text: $reAuthModel.password)
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.5)
                        .background(Color(hex: "#D0FFD0"))
                        .cornerRadius(12)
                }
            }
            
            if !reAuthModel.reAuthenticated  && isPinWrong {
                Button(isResetting ? "Authenticate" : "forgot PIN?") {
                    
                    if isResetting {
                        reAuthModel.reAuthWithEmail()
                    }
                    
                    isResetting = true
                    error = ""
                }
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

#Preview {
    ProfileView(showSignInView: .constant(false), reload: .constant(false))

}


