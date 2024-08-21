//
//  AuthenticationView.swift
//  Stories
//
//  Created by Parth Antala on 8/11/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var didSignInWithApple = false

    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws -> AuthDataResultModel?{
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
//        let user = UserModel(userId: authDataResult.uid, name: "", birthDate: Date(), email: authDataResult.email, gender: "", country: "", number: "", isParent: true)
//        try await UserManager.shared.createNewUser(user: user) 
            
            return authDataResult
        
      
    }
    
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let _ = try await AuthenticationManager.shared.signInWithApple(tokens: signInAppleResult)
                        self.didSignInWithApple = true
                    } catch {
                        
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    @StateObject var viewModel = AuthenticationViewModel()
    @State private var isParent = true
    @State private var newUser = true
    @State private var isSignedInWithGoogle = false
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5DC").ignoresSafeArea()
                
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Spacer()
                            Image("backgroundShade2")
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            Image("backgroundShade1")
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
               
                VStack {
                    
                        VStack(spacing: -10) {
                            Image("OnBoardingImageLogo")
                                
                            ZStack(alignment: .center) {
                                
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color(hex: "#8AC640"))
                                    .frame(width:  UIScreen.main.bounds.width * 0.7, height:  UIScreen.main.bounds.height * 0.5)
                                
                                VStack(alignment: .center) {
                                    
                                    Text("Welcome to KidScribe")
                                        .font(.custom("ComicNeue-Bold", size: 32))
                                    
                                    
                                    Text("The Number One Best Ebook Store & Reader Application in this Century")
                                        .font(.custom("ComicNeue-Regular", size: 24))
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    Button("Show onBoarding") {
                                        isOnboarding = true
                                    }
                                    NavigationLink {
                                        SignInWithEmailView(showSignInView: $showSignInView, isParent: true, continueAsChild: false, signedInWithGoogle: false)
                                        
                                    } label: {
                                        Text("Sign Up")
                                            .font(.custom("ComicNeue-Regular", size: 24))
                                            .frame(height: 55)
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hex: "#FF6F61"))
                                            .cornerRadius(12)
                                            .foregroundStyle(.black)
                                    }
                                    
                                    NavigationLink {
                                        SignInWithEmailView(showSignInView: $showSignInView, isParent: false, continueAsChild: true, signedInWithGoogle: false)
                                        
                                    } label: {
                                        Text("Continue as Parent")
                                            .font(.custom("ComicNeue-Regular", size: 24))
                                            .frame(height: 55)
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hex: "#DFFFDF"))
                                            .cornerRadius(12)
                                            .foregroundStyle(.black)
                                    }
                                    
                                    NavigationLink {
                                        SignInWithEmailView(showSignInView: $showSignInView, isParent: false, continueAsChild: true, signedInWithGoogle: false)
                                        
                                    } label: {
                                        Text("Setup for Child")
                                            .font(.custom("ComicNeue-Regular", size: 24))
                                            .frame(height: 55)
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hex: "#DFFFDF"))
                                            .cornerRadius(12)
                                            .foregroundStyle(.black)
                                    }
                                    
                                    HStack {
                                        Capsule()
                                            .fill(Color(hex: "#E9E9E9"))
                                            .frame(width: 200, height: 1)
                                        
                                        Text("or")
                                        Capsule()
                                            .fill(Color(hex: "#E9E9E9"))
                                            .frame(width: 200, height: 1)
                                    }
                                    
                                    HStack{
                                        Button {
                                            Task {
                                                do {
                                                    if let _ = try await viewModel.signInGoogle() {
                                                        
                                                        isSignedInWithGoogle = true
                                                    }
                                                } catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 22)
                                                    .fill(.white)
                                                    .frame(width: 55, height: 55)
                                                Image("googleIcon")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 22, height: 22)
                                            }
                                            
                                        }
                                        .navigationDestination(isPresented: $isSignedInWithGoogle) {
                                            SignInWithEmailView(showSignInView: $showSignInView, isParent: true, continueAsChild: false, signedInWithGoogle: true)
                                        }
                                        
                                        
                                        Button {
                                            Task {
                                                do {
                                                    try await viewModel.signInApple()
                                                } catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        } label: {
                                            Image("appleIcon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 55, height: 55)
                                                .cornerRadius(22)
                                            //                                        signInWithAppleButtonViewRepresentable(type: .signIn, style: .white)
                                            //                                            .allowsHitTesting(false)
                                        }
                                        .onChange(of: viewModel.didSignInWithApple) { oldValue, newValue in
                                            if newValue {
                                                showSignInView = false
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                .frame(width:  UIScreen.main.bounds.width * 0.6, height:  UIScreen.main.bounds.height * 0.4)
                                
                                
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("Welcome onboard")
                .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    AuthenticationView(showSignInView: .constant(false))
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
