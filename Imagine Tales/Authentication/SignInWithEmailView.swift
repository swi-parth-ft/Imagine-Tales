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
                        
                        ZStack(alignment: .leading) {
                            Button {
                                
                            } label: {
                                Circle()
                                    .foregroundStyle(.white)
                                    .frame(width: 75, height: 75)
                                    .shadow(radius: 10)
                            }
                            
                            
                            HStack {
                                Capsule()
                                    .foregroundStyle(.orange)
                                    .frame(width: 100, height: 10)
                                    .shadow(radius: 10)
                                
                                Capsule()
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 10)
                                    .shadow(radius: 10)
                                
                                Capsule()
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 10)
                                    .shadow(radius: 10)
                            }.frame(maxWidth: .infinity)
                
                           
                        }
                        .padding([.leading, .trailing], 100)
                        .padding(.top, 50)
                            
                        
                        
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(hex: "#8AC640"))
                                
                            VStack {
                                
                                VStack(alignment: .leading) {
                                    Text("Personal Details")
                                        .font(.custom("ComicNeue-Regular", size: 32))
                                    
                                    Text("Enter Personal Details")
                                        .font(.custom("ComicNeue-Regular", size: 24))
                                }
                                .padding([.top, .leading], 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                if newUser {
                                    VStack {
                                        TextField("Name", text: $viewModel.name)
                                            .padding()
                                            .background(.white)
                                            .frame(width: geometry.size.width * 0.7)
                                            .cornerRadius(12)
                                        TextField("Email", text: $viewModel.email)
                                            .padding()
                                            .background(.white)
                                            .frame(width: geometry.size.width * 0.7)
                                            .cornerRadius(12)
                                        TextField("Phone", text: $viewModel.number)
                                            .padding()
                                            .background(.white)
                                            .frame(width: geometry.size.width * 0.7)
                                            .cornerRadius(12)
                                        TextField("gender", text: $viewModel.gender)
                                            .padding()
                                            .background(.white)
                                            .frame(width: geometry.size.width * 0.7)
                                            .cornerRadius(12)
                                        TextField("country", text: $viewModel.country)
                                            .padding()
                                            .background(.white)
                                            .frame(width: geometry.size.width * 0.7)
                                            .cornerRadius(12)
                                        SecureField("Password", text: $viewModel.password)
                                            .padding()
                                            .background(.white)
                                            .frame(width: geometry.size.width * 0.7)
                                            .cornerRadius(12)
                                        
                                    }
                                    .padding(.top)
                                    Spacer()
                                    
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
                                    .padding()
                                    .frame(width: geometry.size.width * 0.7)
                                    .background(Color(hex: "#FF6F61"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                                    
                                    
                                    
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
                                .padding()
                            }
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                    }
                }
            }
        }
    }
}

#Preview {
    SignInWithEmailView(showSignInView: .constant(false))
}
