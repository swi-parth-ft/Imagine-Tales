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
    @Published var gender = "Male"
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
    @Environment(\.dismiss) var dismiss
    @State private var newUser = true
    @State private var settingPassword = false
    @State private var confirmPassword = ""
    @Binding var showSignInView: Bool
    @State private var err = ""
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
                     
                    ZStack(alignment: .leading) {
                            
                        HStack {
                            
                            Button {
                                dismiss()
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.white)
                                        .frame(width: 75, height: 75)
                                        .shadow(radius: 10)
                                    
                                    Image(systemName: "chevron.left")
                                        .font(.largeTitle)
                                        .foregroundColor(.black) // You can change the color as per your requirement
                                }
                            }
                            
                            Spacer()
                            
                        }
                                HStack {
                                    Capsule()
                                        .foregroundStyle(.orange)
                                        .frame(width: 100, height: 7)
                                        .shadow(radius: 10)
                                    
                                    Capsule()
                                        .foregroundStyle(settingPassword ? .orange : .white)
                                        .frame(width: 100, height: 7)
                                        .shadow(radius: 10)
                                    
                                    Capsule()
                                        .foregroundStyle(.white)
                                        .frame(width: 100, height: 7)
                                        .shadow(radius: 10)
                                }.frame(maxWidth: .infinity)
                        }
                        .padding([.leading, .trailing], 100)
                        .padding(.top, 40)
                        .frame(width: UIScreen.main.bounds.width)
                            
                        
                        
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(hex: "#8AC640"))
                                
                            VStack {
                                
                                VStack(alignment: .leading) {
                                    Text(settingPassword ? "Create Password" : "Personal Details")
                                        .font(.custom("ComicNeue-Bold", size: 32))
                                    
                                    Text(settingPassword ? "Enter Password" : "Enter Personal Details")
                                        .font(.custom("ComicNeue-Regular", size: 24))
                                    
                                    
                                    if settingPassword {
                                        Button("Back", systemImage: "lessthan") {
                                            withAnimation {
                                                settingPassword = false
                                            }
                                        }
                                        .padding()
                                        .tint(.orange)
                                        .background(.white.opacity(0.5))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding([.top, .leading], 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                if newUser {
                                    
                                    VStack {
                                        
                                        if !settingPassword {
                                            TextField("Name", text: $viewModel.name)
                                                .customTextFieldStyle()
                                            
                                            TextField("Email", text: $viewModel.email)
                                                .customTextFieldStyle()
                                            
                                            TextField("Phone", text: $viewModel.number)
                                                .customTextFieldStyle()
                                            
                                            //                                        TextField("gender", text: $viewModel.gender)
                                            //                                            .customTextFieldStyle()
                                            
                                            VStack {
                                                Picker("Gender", selection: $viewModel.gender) {
                                                    Text("Male").tag("Male")
                                                    Text("Female").tag("Female")
                                                }
                                                .pickerStyle(.segmented)
                                                
                                            }
                                            .customTextFieldStyle()
                                            
                                            
                                            TextField("country", text: $viewModel.country)
                                                .customTextFieldStyle()
                                        } else {
                                            SecureField("Password", text: $viewModel.password)
                                                .customTextFieldStyle()
                                            
                                            SecureField("Confirm Password", text: $confirmPassword)
                                                .customTextFieldStyle()
                                            
                                            Text(err)
                                        }
                                        
                                    }
                                    .padding(.top)
                                    .frame(width:  UIScreen.main.bounds.width * 0.7)
                                    Spacer()
                                    
                                    Button(settingPassword ? "Sign up" : "Next") {
                                        
                                        if settingPassword {
                                            if viewModel.password == confirmPassword {
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
                                            } else {
                                                err = "passwords don't match, Try again."
                                            }
                                        } else {
                                            withAnimation {
                                                settingPassword = true
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(width:  UIScreen.main.bounds.width * 0.7)
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
                        .frame(width:  UIScreen.main.bounds.width * 0.8, height:  UIScreen.main.bounds.height * 0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .frame(width: UIScreen.main.bounds.width * 0.7)
            .cornerRadius(12)
    }
}

extension View {
    func customTextFieldStyle() -> some View {
        self.modifier(CustomTextFieldModifier())
    }
}

#Preview {
    SignInWithEmailView(showSignInView: .constant(false))
}
