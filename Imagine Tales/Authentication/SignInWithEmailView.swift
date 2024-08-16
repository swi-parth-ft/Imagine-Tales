//
//  userDetailsView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/16/24.
//

import SwiftUI

final class SignInWithEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var date = Date()
    @Published var gender = ""
    @Published var country = ""
    @Published var number = ""
    var userId = ""
    
    func signInWithEmail() async throws -> AuthDataResultModel? {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        let authResult = try await AuthenticationManager.shared.signIn(email: email, password: password)
        return authResult
         
    }
    
    func createAccount() async throws -> AuthDataResultModel? {
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        
        let authResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        userId = authResult.uid
        return authResult
    }
    
    func createUserProfile() async throws {
        let user = UserModel(userId: userId, name: name, birthDate: date, email: email, gender: gender, country: country, number: number)
        let _ = try await UserManager.shared.createNewUser(user: user)
    }
    
    
}

struct SignInWithEmailView: View {
    @StateObject var viewModel = SignInWithEmailViewModel()
    @State private var newUser = true
    
    @Binding var showSignInView: Bool
    var body: some View {
        if newUser {
            Form {
                TextField("Name", text: $viewModel.name)
                TextField("Email", text: $viewModel.email)
                TextField("Phone", text: $viewModel.number)
                TextField("gender", text: $viewModel.gender)
                TextField("country", text: $viewModel.country)
                SecureField("Password", text: $viewModel.password)
                
                Button("Sign Up") {
                    Task {
                        do {
                            if let _ = try await viewModel.createAccount() {
                                showSignInView = false
                                try await viewModel.createUserProfile()
                            }
                            return
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } else {
            Form {
                TextField("Email", text: $viewModel.email)
                SecureField("Password", text: $viewModel.password)
                
                Button("Sign in") {
                    Task {
                        do {
                            if let _ = try await viewModel.signInWithEmail() {
                                showSignInView = false
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        Button(newUser ? "Already have an account? Sign in" : "Create an Account.") {
            newUser.toggle()
        }
    }
}

#Preview {
    SignInWithEmailView(showSignInView: .constant(false))
}
