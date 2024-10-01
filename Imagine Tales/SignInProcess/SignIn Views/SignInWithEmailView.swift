//
//  userDetailsView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/16/24.
//

import SwiftUI
import Drops


struct SignInWithEmailView: View {
    @StateObject var viewModel = SignInWithEmailViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var newUser = true
    @State private var settingPassword = false
    @State private var confirmPassword = ""
    @Binding var showSignInView: Bool
    @Binding var isiPhone: Bool
    @State private var isSignedUp = false
    @State private var isAddingChild = false
    @State var isParent: Bool
    let gridItems = Array(repeating: GridItem(.fixed(100)), count: 5)
    @State private var err = ""
    @State private var selectedAgeRange: AgeRange? = nil
    @State private var addingChildDetails = false
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = false
    
    @AppStorage("dpurl") private var dpUrl = ""
    @EnvironmentObject var appState: AppState
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
    
    @State private var keyboardHeight: CGFloat = 0
    var isParentFlow: Bool
    @Binding var isChildFlow: Bool
    
    
    @State private var isSettingPin = false
    @State private var pin = ""
    
    @State private var otp: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedIndex: Int?
    @State private var isShowingButtons = true
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager
    @State private var isSelectingImage = false
    @State private var selectedImageName = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var isResettingPassword = false
    
    let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                //MARK: Background
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Spacer()
                            Image(colorScheme == .dark ? "bg2dark" : "backgroundShade2") // Left background image
                                .resizable()
                                .scaledToFit()
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            Image(colorScheme == .dark ? "bg1dark" : "backgroundShade1") // Right background image
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if keyboardHeight != 0 {
                        Spacer()
                    }
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
                        //MARK: Stepper View
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
                    .frame(width: UIScreen.main.bounds.width)
                    
                    //MARK: Form
                    ZStack {
                        BackGroundMesh()
                            .cornerRadius(isCompact ?  25 : 50)
                            .shadow(radius: 10)
                        VStack {
                            //MARK: title
                            VStack(alignment: .leading) {
                                if !isSettingPin {
                                    if signedInWithGoogle {
                                        if isNewGoogleUser && !isSignedUp {
                                            Text("Personal Details")
                                                .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                            Text("Enter your personal details for better experience.")
                                                .font(.custom("ComicNeue-Regular", size: isCompact ?  16 : 24))
                                        } else {
                                            Text(isAddingChild ? "Add Child" : "Add Children")
                                                .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                            Text(isAddingChild ? "Enter Personal Details" : "Add or select child to continue.")
                                                .font(.custom("ComicNeue-Regular", size: isCompact ?  16 : 24))
                                        }
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
                                } else {
                                    Text("Set a PIN")
                                        .font(.custom("ComicNeue-Bold", size: isCompact ?  25 : 32))
                                    Text("Set a PIN to secure your account.")
                                        .font(.custom("ComicNeue-Regular", size: isCompact ?  16 : 24))
                                }
                                
                            }
                            .padding([.top, .leading], isCompact ? 20 : 40)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            if !isAddingChild {
                                //MARK: New User View
                                if newUser {
                                    VStack {
                                        //MARK: User detail view
                                        if !settingPassword && !isSignedUp && !signedInWithGoogle {
                                            UserInfoFormView(
                                                name: $viewModel.name,
                                                email: $viewModel.email,
                                                number: $viewModel.number,
                                                gender: $viewModel.gender,
                                                country: $viewModel.country,
                                                isCompact: isCompact
                                            )
                                        }
                                        
                                        //MARK: Setting Password View
                                        else if settingPassword && !signedInWithGoogle {
                                            PasswordFormView(
                                                password: $viewModel.password,
                                                confirmPassword: $confirmPassword,
                                                errorMessage: $err,
                                                isCompact: isCompact
                                            )
                                        }
                                        
                                        //MARK: Add Children View
                                        //  if !isiPhone {
                                        if isSignedUp {
                                            if isSettingPin {
                                                VStack {
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
                                                    Button("set") {
                                                        do {
                                                            try viewModel.setPin(pin: otp.joined())
                                                            isSettingPin = false
                                                            if isiPhone {
                                                                showSignInView = false
                                                            }
                                                            
                                                        } catch {
                                                            print(error.localizedDescription )
                                                        }
                                                        
                                                    }
                                                    .frame(width:  UIScreen.main.bounds.width * 0.4, height: isCompact ? 35 : 55)
                                                    .background(Color(hex: "#DFFFDF"))
                                                    .foregroundStyle(.black)
                                                    .cornerRadius(isCompact ? 6 : 12)
                                                }
                                            } else  if !isiPhone {
                                                VStack(alignment: .leading) {
                                                    ScrollView {
                                                        LazyVGrid(columns: gridItems, spacing: 40) {
                                                            VStack {
                                                                ZStack {
                                                                    
                                                                    Circle()
                                                                        .fill(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
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
                                                                    
                                                                    AsyncDp(urlString: child.profileImage, size: 100)
                                                                    
                                                                    Text(child.name)
                                                                }
                                                                .onTapGesture {
                                                                    
                                                                    childId = child.id
                                                                    showSignInView = false
                                                                    
                                                                    if !isiPhone {
                                                                        ipf = false
                                                                    }
                                                                    viewModel.fetchProfileImage(dp: child.profileImage)
                                                                    
                                                                    screenTimeViewModel.startScreenTime(for: childId)
                                                                    appState.isInSignInView = false
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
                                            
                                            
                                        }
                                        
                                        
                                        //MARK: New user signed in with google View
                                        if signedInWithGoogle && !isSignedUp && isNewGoogleUser {
                                            
                                            TextField("Name", text: $viewModel.name)
                                                .customTextFieldStyle(isCompact: isCompact)
                                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                                .cornerRadius(isCompact ? 6 : 12)
                                                
                                            
                                            TextField("Phone", text: $viewModel.number)
                                                .customTextFieldStyle(isCompact: isCompact)
                                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                                .cornerRadius(isCompact ? 6 : 12)
                                                
                                            
                                            VStack {
                                                Picker("Gender", selection: $viewModel.gender) {
                                                    Text("Male").tag("Male")
                                                    Text("Female").tag("Female")
                                                }
                                                .pickerStyle(.segmented)
                                                
                                            }
                                            .customTextFieldStyle(isCompact: isCompact)
                                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                            .cornerRadius(isCompact ? 6 : 12)
                                            
                                            
                                            TextField("country", text: $viewModel.country)
                                                .customTextFieldStyle(isCompact: isCompact)
                                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                            .cornerRadius(isCompact ? 6 : 12)
                                            
                                            Spacer()
                                            Button("Continue") {
                                                if viewModel.name.isEmpty || viewModel.number.isEmpty || viewModel.country.isEmpty {
                                                    Drops.show("Please fill all details.")
                                                } else {
                                                    Task {
                                                        do {
                                                            try await viewModel.createGoogleUserProfile(isParent: isParent)
                                                            isSignedUp = true
                                                            settingPassword = false
                                                            isSettingPin = true
                                                            isShowingButtons = true
                                                            try viewModel.getChildren()
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
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
                                    
                                    
                                    //MARK: Buttons
                                    
                                    if !isSettingPin && isShowingButtons {
                                        VStack {
                                            
                                            // MARK: Main Button
                                            Button(action: {
                                                if settingPassword {
                                                    if viewModel.password.isEmpty || confirmPassword.isEmpty {
                                                        Drops.show("Passwords can't be empty")
                                                    }
                                                    if viewModel.password == confirmPassword {
                                                        Task {
                                                            do {
                                                                if let _ = try await viewModel.createAccount() {
                                                                    isSettingPin = true
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
                                                        Drops.show("Passwords don't match, Try again.")
                                                    }
                                                } else if isSignedUp {
                                                    withAnimation {
                                                        settingPassword = false
                                                        isSignedUp = false
                                                        isAddingChild = true
                                                    }
                                                } else {
                                                    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
                                                    var isValidEmail = emailPredicate.evaluate(with: viewModel.email)  // Evaluate email first

                                                    if viewModel.name.isEmpty || viewModel.email.isEmpty || viewModel.number.isEmpty || viewModel.country.isEmpty {
                                                        Drops.show("Please fill all details to continue.")
                                                    } else if !isValidEmail {
                                                        Drops.show("This email is not valid.")  // Now it will correctly show if the email is invalid
                                                    } else {
                                                        withAnimation {
                                                            settingPassword = true
                                                        }
                                                    }
                                                }
                                            }) {
                                                Text(settingPassword ? "Sign up" : (isSignedUp ? "Continue" : "Next"))
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .foregroundColor(.white)
                                            }
                                            .padding()
                                            .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                                            .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                            .cornerRadius(isCompact ? 6 : 12)
                                            
                                            // MARK: Add Later Button
                                            if isSignedUp {
                                                Button(action: {
                                                    withAnimation {
                                                        ipf = true
                                                        showSignInView = false
                                                        appState.isInSignInView = false
                                                    }
                                                }) {
                                                    Text("Add Later")
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .foregroundColor(.black)
                                                }
                                                .padding()
                                                .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                                                .background(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
                                                
                                                .cornerRadius(isCompact ? 6 : 12)
                                            }
                                        }
                                        .padding(.bottom, isSignedUp ? 40 : 0)
                                    }
                                    
                                }
                                //MARK: Sign In View
                                else {
                                    VStack {
                                        TextField("Email", text: $viewModel.email)
                                            .customTextFieldStyle(isCompact: isCompact)
                                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                            .cornerRadius(isCompact ? 6 : 12)
                                        
                                        if !isResettingPassword {
                                            
                                            SecureField("Password", text: $viewModel.password)
                                                .customTextFieldStyle(isCompact: isCompact)
                                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                                .cornerRadius(isCompact ? 6 : 12)
                                        }
                                        
                                        if !isResettingPassword {
                                            
                                            HStack {
                                                Spacer()
                                                Button("Forgot password?") {
                                                    isResettingPassword = true
                                                
                                                    Task {
                                                        do {
                                                            try await viewModel.resetPassword()
                                                            print("Pasword reset")
                                                            
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
                                                    }
                                                }
                                                .font(.system(size: isCompact ?  10 : 14))
                                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                            }
                                            .frame(width: UIScreen.main.bounds.width * (isCompact ? 0.8 : 0.7))
                                            .padding(.top, isCompact ? 2 : 5)
                                        } else {
                                            HStack {
                                                Spacer()
                                                
                                                Button("Send reset link") {
                                                    if viewModel.email.isEmpty {
                                                        Drops.show("Please enter you email.")
                                                    } else {
                                                        Task {
                                                            do {
                                                                try await viewModel.resetPassword()
                                                                print("Pasword reset")
                                                                isResettingPassword.toggle()
                                                                Drops.show("Check you email for reset link.")
                                                            } catch {
                                                                Drops.show("Please enter valid email.")
                                                            }
                                                        }
                                                    }
                                                }
                                                .font(.system(size: isCompact ?  10 : 14))
                                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                            }
                                            .frame(width: UIScreen.main.bounds.width * (isCompact ? 0.8 : 0.7))
                                            .padding(.top, isCompact ? 2 : 5)
                                        }
                                        Spacer()
                                        
                                        Button(action: {
                                            if viewModel.email.isEmpty || viewModel.password.isEmpty {
                                                Drops.show("Please enter email and password.")
                                            } else {
                                                
                                                
                                                Task {
                                                    do {
                                                        if let _ = try await viewModel.signInWithEmail() {
                                                            if isiPhone || isParentFlow {
                                                                showSignInView = false
                                                            }
                                                            isSignedUp = true
                                                            settingPassword = false
                                                            newUser = true
                                                        }
                                                    } catch {
                                                        Drops.show("Invalid email or password.")
                                                    }
                                                }
                                            }
                                        }) {
                                            Text("Sign in")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                        .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                                        .background(Color(hex: "#FF6F61"))
                                        .cornerRadius(isCompact ? 6 : 12)
                                        
                                    }
                                }
                            }
                            //MARK: adding child View
                            else {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack {
                                            TextField("Name", text: $viewModel.name)
                                                .padding()
                                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                                .frame(width: UIScreen.main.bounds.width * 0.55)
                                                .cornerRadius(12)
                                                
                                            
                                            TextField("username", text: $viewModel.username)
                                                .padding()
                                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                                .frame(width: UIScreen.main.bounds.width * 0.55)
                                                .cornerRadius(12)
                                        }
                                        ZStack {
                                            Circle()
                                                .fill(colorScheme == .dark ? .black.opacity(0.4) : Color.white)
                                                .frame(width: 150, height: 130)
                                            
                                            if selectedImageName == "" {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 100))
                                                    .foregroundStyle(.gray.opacity(0.4))
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                            } else {
                                                Image(selectedImageName)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                            }
                                            
                                        }
                                        .onTapGesture {
                                            isSelectingImage = true
                                        }
                                        
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.7)
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
                                            if viewModel.name.isEmpty || viewModel.username.isEmpty || selectedAgeRange == nil {
                                                Drops.show("Please fill all details.")
                                            } else {
                                                Task {
                                                    do {
                                                        try await viewModel.addChild(age: selectedAgeRange?.rawValue ?? "n/a", dpUrl: "\(selectedImageName).jpg")
                                                        settingPassword = false
                                                        isSignedUp = true
                                                        isAddingChild = false
                                                        try viewModel.getChildren()
                                                        
                                                    } catch {
                                                        print(error.localizedDescription)
                                                    }
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
                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
                                        .foregroundStyle(.black)
                                        .cornerRadius(12)
                                        
                                    }
                                    .padding(.bottom, keyboardHeight != 0 ? (isCompact ? 60 : 250) : 30)
                                    
                                }
                                .frame(width:  UIScreen.main.bounds.width * 0.7)
                                .sheet(isPresented: $isSelectingImage, onDismiss: {
                                    
                                    
                                }) {
                                    DpSelection(selectedImageName: $selectedImageName, isCompact: isCompact)
                                }
                            }
                            
                            //MARK: toggle newUser
                            if !isSignedUp && !isAddingChild && isShowingButtons {
                                Button(newUser ? "Already have an account? Sign in" : "Create an Account.") {
                                    withAnimation {
                                        newUser.toggle()
                                    }
                                }
                                .font(.system(size: isCompact ?  10 : 14))
                                .padding(.bottom, keyboardHeight != 0 ? (isCompact ? 60 : 250) : 5)
                            }
                        }
                        
                    }
                    .frame(width:  UIScreen.main.bounds.width * (isCompact ? 0.9 : 0.8), height:  UIScreen.main.bounds.height * (isCompact ? 0.5 : 0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                    .onAppear {
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                keyboardHeight = keyboardFrame.height
                            }
                        }
                        
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                            keyboardHeight = 0
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self)
                    }
                    Spacer()
                }.frame(width:  UIScreen.main.bounds.width * (isCompact ? 1 : 0.8), height:  UIScreen.main.bounds.height * (isCompact ? 1 : 0.7))
                
            }
            .ignoresSafeArea(.keyboard)
            .onAppear {
                
                
                appState.isInSignInView = true
                isChildFlow = isParentFlow
                ipf = isParentFlow
                
                if !isNewGoogleUser && signedInWithGoogle {
                    // showSignInView = false
                    if isiPhone {
                        showSignInView = false
                    }
                    isSignedUp = true
                    settingPassword = false
                }
                
                if isNewGoogleUser && signedInWithGoogle {
                    isSignedUp = false
                    isShowingButtons = false
                }
                
                if !isParent  && !signedInWithGoogle {
                    newUser = false
                }
                
                if horizontalSizeClass == .compact {
                    isCompact = true
                    isiPhone = true
                }
            }
            
            .navigationBarBackButtonHidden(true)
        }
    }
}


struct AgeRangeButton: View {
    let ageRange: SignInWithEmailView.AgeRange
    @Binding var selectedAgeRange: SignInWithEmailView.AgeRange?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            selectedAgeRange = ageRange
        }) {
            Text(ageRange.rawValue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedAgeRange != ageRange ? Color.clear : colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
                
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"), lineWidth: 2)
                )
        }
        
    }
}


#Preview {
    SignInWithEmailView(showSignInView: .constant(false), isiPhone: .constant(false), isParent: true, continueAsChild: false, signedInWithGoogle: false, isParentFlow: false, isChildFlow: .constant(false))
}
