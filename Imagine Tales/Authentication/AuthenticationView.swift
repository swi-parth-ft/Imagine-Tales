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
    
    func signInGoogle() async throws {
        
    }
    
    func signInWithEmail() async throws -> AuthDataResultModel? {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        
        return try await AuthenticationManager.shared.signIn(email: email, password: password)
         
    }
    
    func createAccount() async throws -> AuthDataResultModel? {
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        
        return try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
}

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    @StateObject var viewModel = AuthenticationViewModel()
    
    @State private var newUser = true
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(.white.opacity(0.5))
                        .cornerRadius(22)
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(.white.opacity(0.5))
                        .cornerRadius(22)
                    
                    Button(newUser ? "Create an Account" : "Sign In") {
                        if newUser {
                            Task {
                                do {
                                    if let _ = try await viewModel.createAccount() {
                                        showSignInView = false
                                    }
                                    return
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        } else {
                            Task {
                                do {
                                    if let _ = try await viewModel.signInWithEmail() {
                                        showSignInView = false
                                    }
                                    return
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(width: 200)
                    .background(.orange.opacity(0.5))
                    .cornerRadius(22)
                    .foregroundStyle(.white)
                    
                
                        
                    Button(newUser ? "Already a user? Sign In here" : "create a new account.") {
                        newUser.toggle()
                        }
                        .foregroundStyle(.white)
                        
                    
                    
                    
                }
                .padding()
                
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .icon, state: .normal)) {
                    Task {
                        do {
                            //                        try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .cornerRadius(12)
                .padding()
                
            }
            .navigationTitle("Sign In")
            .preferredColorScheme(.dark)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    AuthenticationView(showSignInView: .constant(false))
}
