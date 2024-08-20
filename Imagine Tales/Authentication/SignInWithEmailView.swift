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
    
    func createUserProfile(isParent: Bool) async throws {
        let user = UserModel(userId: userId, name: name, birthDate: date, email: email, gender: gender, country: country, number: number, isParent: isParent)
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
    @State private var isAddingChild = false
    var isParent: Bool
    let gridItems = Array(repeating: GridItem(.fixed(100)), count: 5)
    @State private var err = ""
    
    @State private var selectedAgeRange: AgeRange? = nil

        enum AgeRange: String, CaseIterable {
            case sixToEight = "6-8"
            case eightToTen = "8-10"
            case tenToTwelve = "10-12"
            case twelveToFourteen = "12-14"
        }
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    
    
    var body: some View {
        NavigationStack {
            ZStack {
                //Background
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
                            //Back Button
                            if !isSignedUp {
                                Button {
                                    
                                    if !isAddingChild {
                                        if !settingPassword {
                                            dismiss()
                                        } else {
                                            withAnimation {
                                                if settingPassword {
                                                    settingPassword = false
                                                }
                                            }
                                        }
                                    } else {
                                        isAddingChild = false
                                        isSignedUp = true
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.white)
                                            .frame(width: 75, height: 75)
                                            .shadow(radius: 10)
                                        
                                        Image("arrow1")
                                            .frame(width: 55, height: 55)
                                    }
                                }
                            }
                            Spacer()
                            
                        }
                        //Stepper View
                        HStack {
                                Capsule()
                                    .foregroundStyle(.orange)
                                    .frame(width: 100, height: 7)
                                    .shadow(radius: 10)
                                
                                Capsule()
                                .foregroundStyle(settingPassword || isSignedUp || isAddingChild ? .orange : .white)
                                    .frame(width: 100, height: 7)
                                    .shadow(radius: 10)
                                
                                Capsule()
                                .foregroundStyle(isSignedUp || isAddingChild ? .orange : .white)
                                    .frame(width: 100, height: 7)
                                    .shadow(radius: 10)
                            }.frame(maxWidth: .infinity)
                        }
                        .padding([.leading, .trailing], 100)
                        .padding(.top, 40)
                        .frame(width: UIScreen.main.bounds.width)
                            
                  
                        //MARK: Form
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(hex: "#8AC640"))
                            
                            VStack {
                                
                                //title
                                VStack(alignment: .leading) {
                                    Text(settingPassword ? "Create Password" : (isSignedUp ? "Add Children" : (isAddingChild ? "Add Child" : "Personal Details")))
                                        .font(.custom("ComicNeue-Bold", size: 32))
                                    
                                    Text(settingPassword ? "Enter Password" : (isSignedUp ? "Add accounts for personalised experience": "Enter Personal Details"))
                                        .font(.custom("ComicNeue-Regular", size: 24))
                                    
                                }
                                .padding([.top, .leading], 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                if !isAddingChild {
                                    
                                    //New User View
                                    if newUser {
                                        VStack {
                                            //User detail view
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
                                                
                                                
                                            }
                                            
                                            //Setting Password View
                                            else if settingPassword {
                                                SecureField("Password", text: $viewModel.password)
                                                    .customTextFieldStyle()
                                                
                                                SecureField("Confirm Password", text: $confirmPassword)
                                                    .customTextFieldStyle()
                                                
                                                Text(err)
                                            }
                                            
                                            //Add Children View
                                            if isSignedUp {
                                                VStack(alignment: .leading) {
                                                    ScrollView {
                                                        LazyVGrid(columns: gridItems, spacing: 20) {
                                                            ZStack {
                                                                
                                                                Circle()
                                                                    .fill(Color(hex: "#DFFFDF"))
                                                                    .frame(width: 100, height: 100)
                                                                    .onTapGesture {
                                                                        if isSignedUp {
                                                                            withAnimation {
                                                                                settingPassword = false
                                                                                isSignedUp = false
                                                                                isAddingChild = true
                                                                            }
                                                                        }
                                                                    }
                                                                
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
                                        
                                        
                                        //Buttons
                                        VStack {
                                            
                                            //Main Button
                                            Button(settingPassword ? "Sign up" : (isSignedUp ? "Continue" : "Next")) {
                                                
                                                if settingPassword {
                                                    if viewModel.password == confirmPassword {
                                                        isSignedUp = true
                                                        settingPassword = false
                                                        Task {
                                                            do {
                                                                if let _ = try await viewModel.createAccount() {
                                                                    showSignInView = false
                                                                    try await viewModel.createUserProfile(isParent: isParent)
                                                                }
                                                                return
                                                            } catch {
                                                                print(error.localizedDescription)
                                                            }
                                                        }
                                                    } else {
                                                        err = "passwords don't match, Try again."
                                                    }
                                                } else if isSignedUp {
                                                    withAnimation {
                                                        settingPassword = false
                                                        isSignedUp = false
                                                        isAddingChild = true
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
                                            
                                            //Add Later Button
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
                                        
                                    }
                                    
                                    
                                    
                                    //Sign In View
                                    else {
                                        VStack {
                                            TextField("Email", text: $viewModel.email)
                                                .customTextFieldStyle()
                                            SecureField("Password", text: $viewModel.password)
                                                .customTextFieldStyle()
                                            Spacer()
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
                                            .padding()
                                            .frame(width:  UIScreen.main.bounds.width * 0.7)
                                            .background(Color(hex: "#FF6F61"))
                                            .foregroundStyle(.white)
                                            .cornerRadius(12)
                                        }
                                    }
                                    
                                }
                                
                                //adding child View
                                else {
                                    VStack(alignment: .leading) {
                                        TextField("Name", text: $viewModel.name)
                                            .customTextFieldStyle()
                                        
                                        Text("Select age range for better content.")
                                            .font(.custom("ComicNeue-Regular", size: 24))
                                        
                                        LazyVGrid(columns: columns, spacing: 10) {
                                                        ForEach(AgeRange.allCases, id: \.self) { range in
                                                            AgeRangeButton(ageRange: range, selectedAgeRange: $selectedAgeRange)
                                                        }
                                                    }
                                        Spacer()
                                        
                                        //Buttons
                                        VStack {
                                            
                                            //Main Button
                                            Button("Add Child") {
                                                
                                            }
                                            .padding()
                                            .frame(width:  UIScreen.main.bounds.width * 0.7)
                                            .background(Color(hex: "#FF6F61"))
                                            .foregroundStyle(.white)
                                            .cornerRadius(12)
                                            
                                            //Add Later Button
                                            
                                            Button("Add Later") {
                                                
                                            }
                                            .padding()
                                            .frame(width:  UIScreen.main.bounds.width * 0.7)
                                            .background(Color(hex: "#DFFFDF"))
                                            .foregroundStyle(.black)
                                            .cornerRadius(12)
                                            
                                        }
                                        .padding(.bottom, 40)
                                                  
                                    }
                                    .frame(width:  UIScreen.main.bounds.width * 0.7)
                                }
                                if !isSignedUp && !isAddingChild {
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
            .onAppear {
                if !isParent {
                    newUser = false
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
struct AgeRangeButton: View {
    let ageRange: SignInWithEmailView.AgeRange
    @Binding var selectedAgeRange: SignInWithEmailView.AgeRange?

    var body: some View {
        Button(action: {
            selectedAgeRange = ageRange
        }) {
            Text(ageRange.rawValue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedAgeRange != ageRange ? Color.clear : Color(hex: "#DFFFDF"))
                .foregroundColor(.black)
                .cornerRadius(10)
                .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#DFFFDF"), lineWidth: 2)
                    )
        }
 
    }
}
extension View {
    func customTextFieldStyle() -> some View {
        self.modifier(CustomTextFieldModifier())
    }
}

#Preview {
    SignInWithEmailView(showSignInView: .constant(false), isParent: true)
}
