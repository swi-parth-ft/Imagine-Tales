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
    @State private var isSignedUp = false
    
    let gridItems = Array(repeating: GridItem(.fixed(100)), count: 5)
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
                            
                            if !isSignedUp {
                                Button {
                                    if !settingPassword {
                                        dismiss()
                                    } else {
                                        withAnimation {
                                            if settingPassword {
                                                settingPassword = false
                                            }
                                        }
                                    }
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
                            }
                            
                            Spacer()
                            
                        }
                                HStack {
                                    Capsule()
                                        .foregroundStyle(.orange)
                                        .frame(width: 100, height: 7)
                                        .shadow(radius: 10)
                                    
                                    Capsule()
                                        .foregroundStyle(settingPassword || isSignedUp ? .orange : .white)
                                        .frame(width: 100, height: 7)
                                        .shadow(radius: 10)
                                    
                                    Capsule()
                                        .foregroundStyle(isSignedUp ? .orange : .white)
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
                                    Text(settingPassword ? "Create Password" : (isSignedUp ? "Add Children" : "Personal Details"))
                                        .font(.custom("ComicNeue-Bold", size: 32))
                                    
                                    Text(settingPassword ? "Enter Password" : (isSignedUp ? "Add accounts for personalised experience": "Enter Personal Details"))
                                        .font(.custom("ComicNeue-Regular", size: 24))
                                    
                                }
                                .padding([.top, .leading], 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                if newUser {
                                    
                                    VStack {
                                        
                                        if !settingPassword && !isSignedUp {
                                            TextField("Name", text: $viewModel.name)
                                                .customTextFieldStyle()
                                            
                                            TextField("Email", text: $viewModel.email)
                                                .customTextFieldStyle()
                                            
                                            TextField("Phone", text: $viewModel.number)
                                                .customTextFieldStyle()
                                            
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
                                        } else if settingPassword {
                                            SecureField("Password", text: $viewModel.password)
                                                .customTextFieldStyle()
                                            
                                            SecureField("Confirm Password", text: $confirmPassword)
                                                .customTextFieldStyle()
                                            
                                            Text(err)
                                        }
                                        
                                        if isSignedUp {
                                            VStack(alignment: .leading) {
                                                ScrollView {
                                                    LazyVGrid(columns: gridItems, spacing: 20) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color(hex: "#DFFFDF"))
                                                                .frame(width: 100, height: 100)
                                                            
                                                            Image(systemName: "plus")
                                                                .font(.system(size: 40))
                                                                
                                                        }
//                                                        ForEach(0..<1) { index in
//                                                            Circle()
//                                                                .fill(Color.blue)
//                                                                .frame(width: 100, height: 100)
                                                            
                                                     //   }
                                                    }
                                                    .padding()
                                                    
                                                }
                                            }
                                            .frame(width:  UIScreen.main.bounds.width * 0.7)
                                            
                                        }
                                        
                                    }
                                    .padding(.top)
                                    .frame(width:  UIScreen.main.bounds.width * 0.7)
                                    Spacer()
                                    VStack {
                                        Button(settingPassword ? "Sign up" : (isSignedUp ? "Continue" : "Next")) {
                                            
                                            if settingPassword {
                                                if viewModel.password == confirmPassword {
                                                    isSignedUp = true
                                                    settingPassword = false
                                                    //                                                Task {
                                                    //                                                    do {
                                                    //                                                        if let _ = try await viewModel.createAccount() {
                                                    //                                                            showSignInView = false
                                                    //                                                            try await viewModel.createUserProfile()
                                                    //                                                        }
                                                    //                                                        return
                                                    //                                                    } catch {
                                                    //                                                        print(error.localizedDescription)
                                                    //                                                    }
                                                    //                                                }
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
                                        
                                        if isSignedUp {
                                            Button("Add Later") {
                                                
                                            }
                                            .padding()
                                            .frame(width:  UIScreen.main.bounds.width * 0.7)
                                            .background(Color(hex: "#DFFFDF"))
                                            .foregroundStyle(.black)
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.bottom, isSignedUp ? 40 : 0)
                                    
                                    
                                    
                                    
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
                                
                                if !isSignedUp {
                                    Button(newUser ? "Already have an account? Sign in" : "Create an Account.") {
                                        newUser.toggle()
                                    }
                                    .padding()
                                }
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
