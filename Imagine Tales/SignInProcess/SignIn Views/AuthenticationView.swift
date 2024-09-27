//  AuthenticationView.swift
//  Stories
//
//  Created by Parth Antala on 8/11/24.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool // Controls the visibility of the sign-in view
    @Binding var isiPhone: Bool // Determines if the device is an iPhone
    @StateObject var viewModel = AuthenticationViewModel() // View model for authentication
    @State private var isParent = true // Tracks if the user is a parent
    @State private var newUser = true // Tracks if the user is new
    @State private var isSignedInWithGoogle = false // Tracks Google sign-in status
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true // Persistent storage for onboarding status
    @Environment(\.horizontalSizeClass) var horizontalSizeClass // Get the current horizontal size class

    @Binding var isParentFlow: Bool // Determines the flow for parents

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5DC").ignoresSafeArea() // Background color

                // Background images
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Spacer()
                            Image("backgroundShade2") // Left background image
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            Image("backgroundShade1") // Right background image
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
               
                // Main content area
                VStack {
                    VStack(spacing: isiPhone ? -45 : -10) {
                        // Display onboarding logo
                        if isiPhone {
                            Image("OnBoardingImageLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300) // Specific size for iPhone
                        } else {
                            Image("OnBoardingImageLogo") // Full size for other devices
                        }
                                
                        // Rounded rectangle for welcome message and buttons
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(hex: "#8AC640"))
                                .frame(width: UIScreen.main.bounds.width * (isiPhone ? 0.9 : 0.7), height: UIScreen.main.bounds.height * 0.5)

                            VStack(alignment: .center) {
                                // Welcome title
                                Text("Welcome to Imagine Tales")
                                    .font(.custom("ComicNeue-Bold", size: isiPhone ? 20 : 32))
                                
                                // Subtitle description
                                Text("The Number One Best Ebook Store & Reader Application in this Century")
                                    .font(.custom("ComicNeue-Regular", size: isiPhone ? 15 : 24))
                                    .multilineTextAlignment(.center)
                                
                                Spacer() // Spacer to push content up

                                // Button to show onboarding screen
                                Button("Show onBoarding") {
                                    isOnboarding = true // Trigger onboarding flow
                                }

                                // Navigation link for Sign Up
                                NavigationLink {
                                    SignInWithEmailView(
                                        showSignInView: $showSignInView,
                                        isiPhone: $isiPhone,
                                        isParent: true,
                                        continueAsChild: false,
                                        signedInWithGoogle: false,
                                        isParentFlow: false,
                                        isChildFlow: $isParentFlow
                                    )
                                } label: {
                                    Text("Sign Up")
                                        .font(.custom("ComicNeue-Regular", size: isiPhone ? 15 : 24))
                                        .frame(height: isiPhone ? 35 : 55)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#FF6F61")) // Sign Up button color
                                        .cornerRadius(isiPhone ? 6 : 12) // Button corners
                                        .foregroundStyle(.black) // Button text color
                                }

                                // Navigation link for Continue as Parent
                                NavigationLink {
                                    SignInWithEmailView(
                                        showSignInView: $showSignInView,
                                        isiPhone: $isiPhone,
                                        isParent: false,
                                        continueAsChild: true,
                                        signedInWithGoogle: false,
                                        isParentFlow: true,
                                        isChildFlow: $isParentFlow
                                    )
                                } label: {
                                    Text("Continue as Parent")
                                        .font(.custom("ComicNeue-Regular", size: isiPhone ? 15 : 24))
                                        .frame(height: isiPhone ? 35 : 55)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#DFFFDF")) // Continue button color
                                        .cornerRadius(isiPhone ? 6 : 12)
                                        .foregroundStyle(.black) // Button text color
                                }

                                // Setup for Child button only for non-iPhone devices
                                if !isiPhone {
                                    NavigationLink {
                                        SignInWithEmailView(
                                            showSignInView: $showSignInView,
                                            isiPhone: $isiPhone,
                                            isParent: false,
                                            continueAsChild: true,
                                            signedInWithGoogle: false,
                                            isParentFlow: false,
                                            isChildFlow: $isParentFlow
                                        )
                                    } label: {
                                        Text("Setup for Child")
                                            .font(.custom("ComicNeue-Regular", size: isiPhone ? 12 : 24))
                                            .frame(height: isiPhone ? 35 : 55)
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hex: "#DFFFDF")) // Setup button color
                                            .cornerRadius(isiPhone ? 6 : 12)
                                            .foregroundStyle(.black) // Button text color
                                    }
                                }
                                
                                // Divider with "or" text
                                HStack {
                                    Capsule()
                                        .fill(Color(hex: "#E9E9E9"))
                                        .frame(width: isiPhone ? 100 : 200, height: 1) // Left divider
                                    
                                    Text("or") // Text between dividers
                                    
                                    Capsule()
                                        .fill(Color(hex: "#E9E9E9"))
                                        .frame(width: isiPhone ? 100 : 200, height: 1) // Right divider
                                }
                                
                                // Sign-in options with Google and Apple buttons
                                HStack {
                                    // Google sign-in button
                                    Button {
                                        Task {
                                            do {
                                                if let _ = try await viewModel.signInGoogle() {
                                                    isSignedInWithGoogle = true // Update sign-in status
                                                }
                                            } catch {
                                                print(error.localizedDescription) // Log errors
                                            }
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 22)
                                                .fill(.white)
                                                .frame(width: 55, height: 55) // Button size
                                            Image("googleIcon") // Google icon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 22, height: 22) // Icon size
                                        }
                                    }
                                    .navigationDestination(isPresented: $isSignedInWithGoogle) {
                                        SignInWithEmailView(
                                            showSignInView: $showSignInView,
                                            isiPhone: $isiPhone,
                                            isParent: true,
                                            continueAsChild: false,
                                            signedInWithGoogle: true,
                                            isParentFlow: true,
                                            isChildFlow: $isParentFlow
                                        ) // Navigate on successful Google sign-in
                                    }

                                    // Apple sign-in button
                                    Button {
                                        Task {
                                            do {
                                                try await viewModel.signInApple() // Attempt to sign in with Apple
                                            } catch {
                                                print(error.localizedDescription) // Log errors
                                            }
                                        }
                                    } label: {
                                        Image("appleIcon") // Apple icon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 55, height: 55) // Icon size
                                            .cornerRadius(22) // Rounded corners
                                    }
                                    .onChange(of: viewModel.didSignInWithApple) { newValue in
                                        if newValue {
                                            showSignInView = false // Dismiss on successful sign-in
                                        }
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width * (isiPhone ? 0.8 : 0.6), height: UIScreen.main.bounds.height * (isiPhone ? 0.4 : 0.4)) // Set frame for content
                        }
                        .frame(maxWidth: .infinity) // Expand to fill width
                    }
                    .frame(maxWidth: .infinity) // Expand to fill width
                }
                .frame(maxWidth: .infinity) // Expand to fill width
                .navigationTitle("Welcome onboard") // Set navigation title
                .interactiveDismissDisabled() // Disable interactive dismissal
            }
        }
    }
}

// Preview structure for AuthenticationView
#Preview {
    AuthenticationView(showSignInView: .constant(false), isiPhone: .constant(false), isParentFlow: .constant(false))
}
