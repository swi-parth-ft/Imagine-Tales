//
//  PinView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import Drops
import FirebaseAuth

/// View for entering and resetting the user's PIN.
struct PinView: View {
    @State private var pin = "" // Variable to hold the user's PIN
    private let otpLength: Int = 4 // Length of the PIN (One-Time Password)

    @AppStorage("ipf") private var ipf: Bool = true // AppStorage for a flag
    @StateObject private var viewModel = ProfileViewModel() // ViewModel for profile data
    @StateObject private var parentViewModel = ParentViewModel()
    @StateObject private var reAuthModel = ReAuthentication() // ViewModel for reauthentication
    @State private var otp: [String] = Array(repeating: "", count: 4) // Array to hold each digit of the PIN
    @FocusState private var focusedIndex: Int? // State to track which text field is focused
    @State private var error = "" // Variable to hold error messages
    @State private var isResetting = false // Flag to track if we are resetting the PIN
    @State private var isPinWrong = false // Flag to indicate if the entered PIN is incorrect
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager // EnvironmentObject for managing screen time
    @Environment(\.colorScheme) var colorScheme
    var childId: String
    var body: some View {
        ZStack {
            BackGroundMesh().ignoresSafeArea() // Background color for the view
            VStack {
                // Display the appropriate title based on the state
                Text(reAuthModel.reAuthenticated ? "Enter New PIN" : (isResetting ? "Sign in to reset PIN" : "Enter Parent PIN"))
                    .font(.title)
                    .padding(.bottom, 2)

                // Show user's email if resetting the PIN and signed in with Google
                if isResetting && reAuthModel.signedInWithGoogle {
                    Text("\(reAuthModel.email)")
                }

                // If not resetting or reauthenticated, display the PIN input fields
                if !isResetting || reAuthModel.reAuthenticated {
                    HStack(spacing: 10) {
                        // Create text fields for PIN input
                        ForEach(0..<otpLength, id: \.self) { index in
                            TextField("", text: $otp[index])
                                .frame(width: 50, height: 50)
                                .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#D0FFD0"))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .multilineTextAlignment(.center)
                                .font(.title)
                                .keyboardType(.numberPad)
                                .focused($focusedIndex, equals: index)
                                .onChange(of: otp[index]) { newValue in
                                    // Handle input change for PIN digits
                                    if newValue.count > 1 {
                                        otp[index] = String(newValue.prefix(1)) // Limit to one character
                                    }
                                    if !newValue.isEmpty && index < 3 {
                                        focusedIndex = index + 1 // Move focus to next field
                                    }
                                    if newValue.isEmpty && index > 0 {
                                        focusedIndex = index - 1 // Move focus to previous field
                                    }
                                }
                        }
                    }
                    .padding()

                    // Button to submit the entered PIN
                    Button(reAuthModel.reAuthenticated ? "Reset PIN" : "Enter to the boring side") {
                        // Check the entered PIN
                        if reAuthModel.reAuthenticated {
                            do {
                                // Attempt to set the new PIN
                                try reAuthModel.setPin(pin: otp.joined())
                                isResetting = false // Reset the resetting flag
                                reAuthModel.reAuthenticated = false // Clear reauthenticated flag
                                error = "" // Clear any existing error messages
                                isPinWrong = false // Reset incorrect PIN flag
                                otp = Array(repeating: "", count: otpLength) // Clear the PIN input fields
                                try? viewModel.getPin() // Fetch the updated PIN
                            } catch {
                                print(error.localizedDescription) // Log any errors
                            }
                        } else {
                            if otp.joined().isEmpty {
                                Drops.show("Please enter a PIN.")
                            } else if otp.joined() == viewModel.pin {
                                screenTimeViewModel.stopScreenTime() // Stop screen time management
                                parentViewModel.removeFCMToken(childId: childId)
                               // parentViewModel.AddFCMTokenParent(parentId: Auth.auth().currentUser?.uid ?? "")
                                ipf = true // Set the app storage flag to true
                            } else {
                                isPinWrong = true // Set incorrect PIN flag
                                if !isResetting {
                                    Drops.show("Incorrect PIN.")
                                }
                                
                                otp = Array(repeating: "", count: otpLength) // Clear PIN fields
                            }
                        }
                    }
                }

                
                // Handle reauthentication process if resetting the PIN
                if isResetting && !reAuthModel.reAuthenticated {
                    if reAuthModel.isLinkedWithGoogle {
                        // Button for Google sign-in if user is resetting their PIN
                        VStack {
                            Button {
                                Task {
                                    do {
                                        try await reAuthModel.reAuthWithGoogle() // Attempt reauthentication with Google
                                        Drops.show("Signed in Successfully")
                                    } catch {
                                        print(error.localizedDescription) // Log any errors
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(colorScheme == .dark ? Color.white : Color(red: 66/255, green: 133/255, blue: 244/255))
                                        .frame(width: 250, height: 55)
                                        .shadow(color: colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.4), radius: 10)
                                    HStack {
                                        Image("googleIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 22, height: 22)
                                        Text("Continue with Google")
                                            .font(.system(size: 16, weight: .medium))
                                                        
                                            .foregroundColor(colorScheme == .dark ? .black : .white) // Adjust text color
                                    }
                                }
                            }
                            
                            Button {
                                Task {
                                    do {
                                       // try await reAuthModel.reAuthWithApple() // Attempt reauthentication with Apple
                                        reAuthModel.reAuthWithApple { success in
                                            if success {
                                                Drops.show("Signed in Successfully")
                                            } else {
                                                
                                            }
                                        }
                                    } catch {
                                        print(error.localizedDescription) // Log any errors
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(colorScheme == .dark ? .white : .black)
                                        .frame(width: 250, height: 55)
                                        .shadow(color: colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.4), radius: 10)
                                    HStack {
                                        Image(systemName: "apple.logo")
                                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                                            .font(.system(size: 22))
                                        Text("Continue with Apple")
                                            .font(.system(size: 16, weight: .medium))
                                                        
                                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                                    }
                                }
                            }
                        }
                    }
                    else if reAuthModel.signedInWithGoogle {
                        // Button for Google sign-in if user is resetting their PIN
                        Button {
                            Task {
                                do {
                                    try await reAuthModel.reAuthWithGoogle() // Attempt reauthentication with Google
                                    Drops.show("Signed in Successfully")
                                } catch {
                                    print(error.localizedDescription) // Log any errors
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(colorScheme == .dark ? Color.white : Color(red: 66/255, green: 133/255, blue: 244/255))
                                    .frame(width: 250, height: 55)
                                    .shadow(color: colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.4), radius: 10)
                                HStack {
                                    Image("googleIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                    Text("Continue with Google")
                                        .font(.system(size: 16, weight: .medium))
                                                    
                                        .foregroundColor(colorScheme == .dark ? .black : .white) // Adjust text color
                                }
                            }
                        }
                    } else if reAuthModel.signedInWithApple {
                        Button {
                            Task {
                                do {
                                   // try await reAuthModel.reAuthWithApple() // Attempt reauthentication with Apple
                                    reAuthModel.reAuthWithApple { success in
                                        if success {
                                            Drops.show("Signed in Successfully")
                                        } else {
                                            
                                        }
                                    }
                                } catch {
                                    print(error.localizedDescription) // Log any errors
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .frame(width: 250, height: 55)
                                    .shadow(color: colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.4), radius: 10)
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                        .font(.system(size: 22))
                                    Text("Continue with Apple")
                                        .font(.system(size: 16, weight: .medium))
                                                    
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                }
                            }
                        }
                    } else {
//                        // Text fields for email and password if not using Google
//                        Text(reAuthModel.email)
//                            .padding()
//                            .frame(width: UIScreen.main.bounds.width * 0.5)
//                            .background(colorScheme == .dark ? .black.opacity(0.2) : Color(hex: "#D0FFD0"))
//                            .cornerRadius(12)
//                        SecureField("Password", text: $reAuthModel.password)
//                            .padding()
//                            .frame(width: UIScreen.main.bounds.width * 0.5)
//                            .background(colorScheme == .dark ? .black.opacity(0.2) : Color(hex: "#D0FFD0"))
//                            .cornerRadius(12)
                    }
                }
                
                // If reauthentication failed, provide a button for sign-in or forgotten PIN
                if !reAuthModel.reAuthenticated && isPinWrong {
                    Button(isResetting ? (reAuthModel.signedInWithGoogle || reAuthModel.signedInWithApple ? "" : "Sign in") : "forgot PIN?") {
                        if isResetting {
                            reAuthModel.reAuthWithEmail { success in
                                if success {
                                    Drops.show("Signed In Succesfully.")
                                } else {
                                    Drops.show("Password is Incorrect.")
                                }
                            } // Attempt reauthentication with email
                           
                        }
                        isResetting = true // Set to resetting state
                        error = "" // Clear any existing error messages
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Fetch the stored PIN and initialize view state on appear
            try? viewModel.getPin() // Fetch the current PIN
            focusedIndex = 0 // Set focus to the first input field
            reAuthModel.checkIfGoogle() // Check if the user signed in with Google
        }
      
    }
}
