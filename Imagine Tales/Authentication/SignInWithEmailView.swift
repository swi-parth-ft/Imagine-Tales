//
//  userDetailsView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/16/24.
//

import SwiftUI
import FirebaseFirestore

final class SignInWithEmailViewModel: ObservableObject {
    
    @Published var children: [UserChildren] = []
    
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var date = Date()
    @Published var gender = "Male"
    @Published var country = ""
    @Published var number = ""
    var userId = ""
    
    
//    @MainActor
//    func getChildren() {
//      
//            children =  UserManager.shared.getAllUserChildren(userId: userId)
//            print("children: \(children)")
//        
//    }
    
    func resetPassword() async throws {
//        let user = try AuthenticationManager.shared.getAuthenticatedUser()
//        guard let email = user.email else {
//            throw URLError(.fileIsDirectory)
//        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    
//    func getChildren() throws {
//       
//        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//        userId = authDataResult.uid
//        
//        Firestore.firestore().collection("users").document(userId).collection("Children").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//                return
//            }
//            
//            self.children = querySnapshot?.documents.compactMap { document in
//                try? document.data(as: UserChildren.self)
//            } ?? []
//            print(self.children)
//            
//        }
//    }
    
    func getChildren() throws {
       
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        
        Firestore.firestore().collection("Children2").whereField("parentId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.children = querySnapshot?.documents.compactMap { document in
                try? document.data(as: UserChildren.self)
            } ?? []
            print(self.children)
            
        }
    }
    
    
    func signInWithEmail() async throws -> AuthDataResultModel? {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        let authResult = try await AuthenticationManager.shared.signIn(email: email, password: password)
        userId = authResult.uid
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
    
    func createGoogleUserProfile(isParent: Bool) async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        let user = UserModel(userId: userId, name: name, birthDate: date, email: authDataResult.email, gender: gender, country: country, number: number, isParent: isParent)
        print(user.userId)
        let _ = try await UserManager.shared.createNewUser(user: user)
    }
    
    func addChild(age: String) async throws {
        let _ = try await UserManager.shared.addChild(userId: userId, name: name, age: age)
        let _ = try await UserManager.shared.addChild2(userId: userId, name: name, age: age)
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
    @State var isParent: Bool
    let gridItems = Array(repeating: GridItem(.fixed(100)), count: 5)
    @State private var err = ""
    @State private var selectedAgeRange: AgeRange? = nil
@State private var addingChildDetails = false
    @AppStorage("childId") var childId: String = "Default Value"
    let isNewGoogleUser = AuthenticationManager.shared.isNewUser
    var continueAsChild: Bool
    var signedInWithGoogle: Bool
    
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

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isCompact = false
    
    
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
                                            .frame(width: isCompact ? 50 : 75, height: isCompact ? 50 : 75)
                                            .shadow(radius: 10)
                                        
                                        Image("arrow1")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: isCompact ? 25 : 55, height: isCompact ? 25 : 55)
                                    }
                                }
                                .padding(.leading, isCompact ? 20 : 40)
                            }
                                
                            Spacer()
                            
                        }
                        .frame(width: UIScreen.main.bounds.width)
                        //Stepper View
                        HStack {
                                Capsule()
                                    .foregroundStyle(.orange)
                                    .frame(width: isCompact ? 55 : 100, height: 7)
                                    .shadow(radius: 10)
                                
                                Capsule()
                                .foregroundStyle(settingPassword || isSignedUp || isAddingChild ? .orange : .white)
                                    .frame(width: isCompact ? 55 : 100, height: 7)
                                    .shadow(radius: 10)
                                
                                Capsule()
                                .foregroundStyle(isSignedUp || isAddingChild ? .orange : .white)
                                    .frame(width: isCompact ? 55 : 100, height: 7)
                                    .shadow(radius: 10)
                            }.frame(maxWidth: .infinity)
                        }
                        .padding([.leading, .trailing], 100)
                        .padding(.top, 40)
                       // .padding(.bottom, isCompact ? 30 : 0)
                        .frame(width: UIScreen.main.bounds.width)
                 
                        //MARK: Form
                        ZStack {
                            RoundedRectangle(cornerRadius: isCompact ?  25 : 50)
                                .fill(Color(hex: "#8AC640"))
                            
                            
                            VStack {
                                
                                //title
                                VStack(alignment: .leading) {
                                    if signedInWithGoogle {
                                        Text(isAddingChild ? "Add Child" : "Add Children")
                                            .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                        Text(isAddingChild ? "Enter Personal Details" : "Add or select child to continue.")
                                            .font(.custom("ComicNeue-Regular", size: isCompact ?  16 : 24))
                                    } else {
                                    if isParent {
                                        Text(settingPassword ? "Create Password" : (isSignedUp ? "Add Children" : (isAddingChild ? "Add Child" : (newUser ? "Personal Details" : "Sign In"))))
                                            .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                        
                                        Text(settingPassword ? "Enter Password" : (isSignedUp ? "Add accounts for personalised experience": "Enter Personal Details"))
                                            .font(.custom("ComicNeue-Regular", size: isCompact ?  16 : 24))
                                    } else {
                                        if !newUser {
                                            Text(isAddingChild ? "Add Child" : (isSignedUp ? "Select Child" : "Sign In as Parent"))
                                                .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                        } else {
                                            Text(isAddingChild ? "Add Child" : (isSignedUp ? "Select Child" : "Sign Up as Parent"))
                                                .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                        }
                                        Text(isAddingChild ? "Enter personal details" : (isSignedUp ? "Add or select child to continue." :"Sign in or create a new parent account"))
                                            .font(.custom("ComicNeue-Regular", size: isCompact ?  16 : 24))
                                        
                                        
                                    }
                                }
                                    
                                }
                                .padding([.top, .leading], isCompact ? 20 : 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                if !isAddingChild {
                                    
                                    //New User View
                                    if newUser {
                                        VStack {
                                            //User detail view
                                            if !settingPassword && !isSignedUp && !signedInWithGoogle {
                                                TextField("Name", text: $viewModel.name)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                
                                                TextField("Email", text: $viewModel.email)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                
                                                TextField("Phone", text: $viewModel.number)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                
                                                VStack {
                                                    Picker("Gender", selection: $viewModel.gender) {
                                                        Text("Male").tag("Male")
                                                        Text("Female").tag("Female")
                                                    }
                                                    .pickerStyle(.segmented)
                                                    .frame(height: isCompact ? 35 : 55)
                                                    
                                                }
                                                
                                                
                                                TextField("country", text: $viewModel.country)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                
                                                
                                            }
                                            
                                            //Setting Password View
                                            else if settingPassword && !signedInWithGoogle {
                                                SecureField("Password", text: $viewModel.password)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                
                                                SecureField("Confirm Password", text: $confirmPassword)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                
                                                Text(err)
                                            }
                                            
                                            //Add Children View
                                            if isSignedUp {
                                                VStack(alignment: .leading) {
                                                    ScrollView {
                                                        LazyVGrid(columns: gridItems, spacing: 40) {
                                                            VStack {
                                                                ZStack {
                                                                    
                                                                    Circle()
                                                                        .fill(Color(hex: "#DFFFDF"))
                                                                        .frame(width: 100, height: 100)
                                                                    
                                                                    
                                                                    
                                                                    Image(systemName: "plus")
                                                                        .font(.system(size: 40))
                                                                    
                                                                    
                                                                }
                                                                
                                                                Text("Add")
                                                            }
                                                            .onTapGesture {
                                                                if isSignedUp {
                                                                    withAnimation {
                                                                        settingPassword = false
                                                                        isSignedUp = false
                                                                        isAddingChild = true
                                                                    }
                                                                }
                                                            }
                                                            ForEach(viewModel.children) { child in
                                                                VStack {
                                                                    Circle()
                                                                        .fill(Color.blue)
                                                                        .frame(width: 100, height: 100)
                                                                    
                                                                    Text(child.name)
                                                                }
                                                                .onTapGesture {
                                                                    
                                                                    childId = child.id
                                                                    showSignInView = false
                                                                }
                                                            }
                                                        }
                                                        .padding()
                                                        
                                                    }
                                                }
                                                .frame(width:  UIScreen.main.bounds.width * 0.7)
                                                .onAppear {
                                                    Task {
                                                        do {
                                                            try viewModel.getChildren()
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
                                                    }
                                                }
                                                
                                                
                                                
                                            }
                                            
                                            
                                            //New user signed in with google View
                                            if signedInWithGoogle && !isSignedUp && isNewGoogleUser {
                                               
                                                    TextField("Name", text: $viewModel.name)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                    
                                                    TextField("Phone", text: $viewModel.number)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                    
                                                    VStack {
                                                        Picker("Gender", selection: $viewModel.gender) {
                                                            Text("Male").tag("Male")
                                                            Text("Female").tag("Female")
                                                        }
                                                        .pickerStyle(.segmented)
                                                        
                                                    }
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                    
                                                    
                                                    TextField("country", text: $viewModel.country)
                                                    .customTextFieldStyle(isCompact: isCompact)
                                                    
                                                    Spacer()
                                                    Button("Continue") {
                                                        Task {
                                                            do {
                                                                
                                                                
                                                                
                                                                
                                                                try await viewModel.createGoogleUserProfile(isParent: isParent)
                                                                isSignedUp = true
                                                                settingPassword = false
                                                                try viewModel.getChildren()
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
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
                                        .padding(.top)
                                        .frame(width:  UIScreen.main.bounds.width * 0.7)
                                        Spacer()
                                        
                                   
                                        //Buttons
                                        VStack {
                                            
                                            //Main Button
                                            Button(settingPassword ? "Sign up" : (isSignedUp ? "Continue" : "Next")) {
                                                
                                                if settingPassword {
                                                    if viewModel.password == confirmPassword {
                                                        
                                                        Task {
                                                            do {
                                                                if let _ = try await viewModel.createAccount() {
                                                                    
                                                                    isSignedUp = true
                                                                    settingPassword = false
                                                                    
                                                                    try await viewModel.createUserProfile(isParent: isParent)
                                                                    try viewModel.getChildren()
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
                                            .frame(width:  UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                                            
                                            .background(Color(hex: "#FF6F61"))
                                            .foregroundStyle(.white)
                                            .cornerRadius(isCompact ? 6 : 12)
                                            
                                            
                                            //Add Later Button
                                            if isSignedUp {
                                                Button("Add Later") {
                                                    withAnimation {
                                                        showSignInView = false
                                                    }
                                                }
                                                .padding()
                                                .frame(width:  UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                                                .background(Color(hex: "#DFFFDF"))
                                                .foregroundStyle(.black)
                                                .cornerRadius(isCompact ? 6 : 12)
                                            }
                                        }
                                        .padding(.bottom, isSignedUp ? 40 : 0)
                                        
                                    }
                                    
                                    //Sign In View
                                    else {
                                        VStack {
                                            TextField("Email", text: $viewModel.email)
                                                .customTextFieldStyle(isCompact: isCompact)
                                            SecureField("Password", text: $viewModel.password)
                                                .customTextFieldStyle(isCompact: isCompact)
                                            HStack {
                                                Spacer()
                                                Button("Forgot password?") {
                                                    Task {
                                                        do {
                                                            try await viewModel.resetPassword()
                                                            print("Pasword reset")
                                                            
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
                                                    }
                                                }
                                                    .foregroundStyle(.black)
                                            }
                                            .frame(width: UIScreen.main.bounds.width * 0.7)
                                            .padding(.top)
                                            Spacer()
                                            
                                            Button("Sign in") {
                                                Task {
                                                    do {
                                                        if let _ = try await viewModel.signInWithEmail() {
                                                            isSignedUp = true
                                                            settingPassword = false
                                                            newUser = true
                                                         //   viewModel.getChildren()
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
                                            .customTextFieldStyle(isCompact: isCompact)
                                        
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
                                                Task {
                                                    do {
                                                        try await viewModel.addChild(age: selectedAgeRange?.rawValue ?? "n/a")
                                                        settingPassword = false
                                                        isSignedUp = true
                                                        isAddingChild = false
                                                        try viewModel.getChildren()
                                                        
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
                                        withAnimation {
                                            newUser.toggle()
                                        }
                                    }
                                    .padding()
                                }
                            }
                            
                        }
                        .frame(width:  UIScreen.main.bounds.width * (isCompact ? 0.9 : 0.8), height:  UIScreen.main.bounds.height * (isCompact ? 0.5 : 0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
//                        .padding(.bottom, isCompact ? 190 : 0)
                   Spacer()
                }.frame(width:  UIScreen.main.bounds.width * (isCompact ? 1 : 0.8), height:  UIScreen.main.bounds.height * (isCompact ? 1 : 0.7))
            }
            .onAppear {
                if !isParent {
                    newUser = false
                }
                
                if !isNewGoogleUser && signedInWithGoogle {
                    isSignedUp = true
                    settingPassword = false
                }
                
                if horizontalSizeClass == .compact {
                    isCompact = true
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

struct CustomTextFieldModifierCompact: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 30)
            .cornerRadius(6)
            .font(.system(size: 12))
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
    
    func customTextFieldStyle(isCompact: Bool) -> some View {

        if isCompact {
                return AnyView(self.modifier(CustomTextFieldModifierCompact()))
            } else {
                return AnyView(self.modifier(CustomTextFieldModifier()))
            }
    }
}

#Preview {
    SignInWithEmailView(showSignInView: .constant(false), isParent: true, continueAsChild: false, signedInWithGoogle: false)
}
