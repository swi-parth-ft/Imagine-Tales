//
//  PinView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

/// View for entering and resetting the user's PIN.
struct PinView: View {
    @State private var pin = "" // Variable to hold the user's PIN
    private let otpLength: Int = 4 // Length of the PIN (One-Time Password)

    @AppStorage("ipf") private var ipf: Bool = true // AppStorage for a flag
    @StateObject private var viewModel = ProfileViewModel() // ViewModel for profile data
    @StateObject private var reAuthModel = ReAuthentication() // ViewModel for reauthentication
    @State private var otp: [String] = Array(repeating: "", count: 4) // Array to hold each digit of the PIN
    @FocusState private var focusedIndex: Int? // State to track which text field is focused
    @State private var error = "" // Variable to hold error messages
    @State private var isResetting = false // Flag to track if we are resetting the PIN
    @State private var isPinWrong = false // Flag to indicate if the entered PIN is incorrect
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager // EnvironmentObject for managing screen time
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            colorScheme == .dark ? Color(hex: "#5A6D2A").ignoresSafeArea() : Color(hex: "#8AC640").ignoresSafeArea() // Background color for the view
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
                            // Check if the entered PIN matches the stored PIN
                            if otp.joined() == viewModel.pin {
                                screenTimeViewModel.stopScreenTime() // Stop screen time management
                                ipf = true // Set the app storage flag to true
                            } else {
                                isPinWrong = true // Set incorrect PIN flag
                                error = "Incorrect PIN, Try again!" // Set error message
                                otp = Array(repeating: "", count: otpLength) // Clear PIN fields
                            }
                        }
                    }
                }

                // Display any error messages in red
                Text(error).foregroundStyle(.red)
                
                // Handle reauthentication process if resetting the PIN
                if isResetting && !reAuthModel.reAuthenticated {
                    if reAuthModel.signedInWithGoogle {
                        // Button for Google sign-in if user is resetting their PIN
                        Button {
                            Task {
                                do {
                                    try await reAuthModel.reAuthWithGoogle() // Attempt reauthentication with Google
                                } catch {
                                    print(error.localizedDescription) // Log any errors
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.white)
                                    .frame(width: 250, height: 55)
                                HStack {
                                    Image("googleIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                    Text("Continue with Google")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    } else {
                        // Text fields for email and password if not using Google
                        TextField("email", text: $reAuthModel.email)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .background(Color(hex: "#D0FFD0"))
                            .cornerRadius(12)
                        SecureField("Password", text: $reAuthModel.password)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .background(Color(hex: "#D0FFD0"))
                            .cornerRadius(12)
                    }
                }
                
                // If reauthentication failed, provide a button for sign-in or forgotten PIN
                if !reAuthModel.reAuthenticated && isPinWrong {
                    Button(isResetting ? (reAuthModel.signedInWithGoogle ? "" : "Sign in") : "forgot PIN?") {
                        if isResetting {
                            reAuthModel.reAuthWithEmail() // Attempt reauthentication with email
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
