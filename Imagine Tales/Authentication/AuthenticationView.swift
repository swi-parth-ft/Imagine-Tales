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
        return try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
      
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
    
    @State private var newUser = true
    
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
                    GeometryReader { geometry in
                        VStack(spacing: -10) {
                            Image("OnBoardingImageLogo")
                                
                            ZStack(alignment: .center) {
                                
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color(hex: "#8AC640"))
                                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.5)
                                
                                VStack(alignment: .center) {
                                    
                                    Text("Welcome to KidScribe")
                                        .font(.custom("ComicNeue-Regular", size: 32))
                                    
                                    Text("The Number One Best Ebook Store & Reader Application in this Century")
                                        .font(.custom("ComicNeue-Regular", size: 24))
                                        .multilineTextAlignment(.center)
                                    
                                    NavigationLink {
                                        SignInWithEmailView(showSignInView: $showSignInView)
                                    } label: {
                                        Text("Sign in with email")
                                            .font(.custom("ComicNeue-Regular", size: 24))
                                            .frame(height: 40)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.orange)
                                            .cornerRadius(12)
                                            .foregroundStyle(.white)
                                    }
                                    
                                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                                        Task {
                                            do {
                                                if let _ = try await viewModel.signInGoogle() {
                                                    showSignInView = false
                                                }
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                    .cornerRadius(12)
                                    
                                    Button {
                                        Task {
                                            do {
                                                try await viewModel.signInApple()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    } label: {
                                        signInWithAppleButtonViewRepresentable(type: .signIn, style: .white)
                                            .allowsHitTesting(false)
                                    }
                                    .frame(height: 40)
                                    .cornerRadius(12)
                                    .onChange(of: viewModel.didSignInWithApple) { oldValue, newValue in
                                        if newValue {
                                            showSignInView = false
                                        }
                                    }
                                    
                                    
                                }
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.4)
                                
                                
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("Sign In")
                .preferredColorScheme(.dark)
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
