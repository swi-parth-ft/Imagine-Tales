//
//  AuthenticationView.swift
//  Stories
//
//  Created by Parth Antala on 8/11/24.
//

/**
 The AuthenticationView is the entry point for users to sign up or continue as a parent in the Imagine Tales app.
 It presents different options based on device type (iPhone or other) and includes Google and Apple sign-in methods.
*/

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    // MARK: - State & Binding Variables
    
    /// Controls the visibility of the sign-in view.
    @Binding var showSignInView: Bool
    
    /// Determines whether the current device is an iPhone.
    @Binding var isiPhone: Bool
    
    /// View model responsible for handling authentication logic (Google/Apple sign-in).
    @StateObject var viewModel = AuthenticationViewModel()
    
    /// Tracks whether the current user is a parent (default is true).
    @State private var isParent = true
    
    /// Indicates if the current user is new.
    @State private var newUser = true
    
    /// Tracks the status of Google sign-in.
    @State private var isSignedInWithGoogle = false
    
    /// Persistent storage to track if the user has completed the onboarding process.
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    /// Provides the current horizontal size class (compact or regular).
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    /// Provides the current color scheme (light or dark).
    @Environment(\.colorScheme) var colorScheme
    
    /// Determines whether the current flow is for parents.
    @Binding var isParentFlow: Bool
    @StateObject var subViewModel = SubscriptionViewModel()
    @EnvironmentObject var appState: AppState
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                SignInBG()
                // Main Content Area
                VStack {
                    VStack(spacing: isiPhone ? -45 : -10) {
                        
                        // Onboarding logo, with different sizes for iPhone and other devices
                        if isiPhone {
                            Image("OnBoardingImageLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        } else {
                            Image("OnBoardingImageLogo") // Default size for other devices
                        }
                                
                        // Rounded rectangle card for welcome message and buttons
                        ZStack(alignment: .center) {
                         
                            BackGroundMesh()
                                .frame(width: UIScreen.main.bounds.width * (isiPhone ? 0.9 : 0.7), height: UIScreen.main.bounds.height * 0.5)
                                .cornerRadius(horizontalSizeClass == .compact ? 25 : 50)
                                .shadow(radius: 10)
                            
                            VStack(alignment: .center) {
                                // Welcome Title
                                Text("Welcome to Imagine Tales")
                                    .font(.custom("ComicNeue-Bold", size: isiPhone ? 20 : 32))
                                
                                // Subtitle
                                Text("The Number One Best Ebook Store & Reader Application in this Century")
                                    .font(.custom("ComicNeue-Regular", size: isiPhone ? 15 : 24))
                                    .multilineTextAlignment(.center)
                                
                                Spacer() // Spacer to adjust layout

                                // Button to trigger onboarding flow again
                                Button("Show onBoarding") {
                                    isOnboarding = true // Set onboarding flag to true
                                }

                                // Navigation link for the Sign Up button
                                NavigationLink {
                                    SignInWithEmailView(
                                        showSignInView: $showSignInView,
                                        isiPhone: $isiPhone,
                                        isParent: true, // Default to parent flow
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
                                        .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61")) // Button color
                                        .cornerRadius(isiPhone ? 6 : 12) // Rounded corners
                                        .foregroundStyle(.black) // Text color
                                }

                                // Navigation link to Continue as Parent
                                NavigationLink {
                                    SignInWithEmailView(
                                        showSignInView: $showSignInView,
                                        isiPhone: $isiPhone,
                                        isParent: false, // Switch to child flow
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
                                        .background(colorScheme == .dark ? Color(hex: "#A6A6A6") : Color(hex: "#DFFFDF")) // Button color for parents
                                        .cornerRadius(isiPhone ? 6 : 12)
                                        .foregroundStyle(.black) // Text color
                                }

                                // Additional "Setup for Child" option for non-iPhone devices
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
                                            .background(colorScheme == .dark ? Color(hex: "#A6A6A6") : Color(hex: "#DFFFDF")) // Button color for child setup
                                            .cornerRadius(isiPhone ? 6 : 12)
                                            .foregroundStyle(.black) // Text color
                                    }
                                }
                                
                                // Divider with "or" text
                                HStack {
                                    Capsule()
                                        .fill(Color(hex: "#E9E9E9"))
                                        .frame(width: isiPhone ? 100 : 200, height: 1) // Left line
                                    
                                    Text("or") // Text between the lines
                                    
                                    Capsule()
                                        .fill(Color(hex: "#E9E9E9"))
                                        .frame(width: isiPhone ? 100 : 200, height: 1) // Right line
                                }
                                
                                // Buttons for signing in with Google and Apple
                                HStack {
                                    // Google sign-in button
                                    Button {
                                        Task {
                                            do {
                                                if let _ = try await viewModel.signInGoogle() {
                                                    isSignedInWithGoogle = true // Update the sign-in status
                                                }
                                            } catch {
                                                print(error.localizedDescription) // Log any errors
                                            }
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 22)
                                                .fill(.white)
                                                .frame(width: 55, height: 55) // Google button size
                                            Image("googleIcon") // Google icon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 22, height: 22) // Google icon size
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
                                        ) // Navigate after Google sign-in
                                    }

                                    // Apple sign-in button
                                    Button {
                                        Task {
                                            do {
                                                try await viewModel.signInApple()
                                               
                                                
                                            } catch {
                                                print(error.localizedDescription) // Log any errors
                                            }
                                        }
                                    } label: {
                                        Image("appleIcon") // Apple icon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 55, height: 55) // Apple icon size
                                            .cornerRadius(22) // Rounded corners
                                    }
                                    .onChange(of: viewModel.didSignInWithApple) { 
                                        subViewModel.loginUser(with: Auth.auth().currentUser?.uid ?? "")
                                        
                                    }
                                  
                                    .navigationDestination(isPresented: $viewModel.didSignInWithApple) {
                                        SignInWithEmailView(
                                            showSignInView: $showSignInView,
                                            isiPhone: $isiPhone,
                                            isParent: true,
                                            continueAsChild: false,
                                            signedInWithGoogle: true,
                                            isParentFlow: true,
                                            isChildFlow: $isParentFlow
                                        ) // Navigate after Google sign-in
                                    }
//                                    .onChange(of: viewModel.didSignInWithApple) { newValue in
//                                        if newValue {
//                                            showSignInView = false // Dismiss view after Apple sign-in
//                                        }
//                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width * (isiPhone ? 0.8 : 0.6), height: UIScreen.main.bounds.height * 0.4)
                        }
                    }
                    .padding(isiPhone ? 12 : 20)
                }
                .onChange(of: subViewModel.hasActiveSubscription) {
                    appState.isPremium = subViewModel.hasActiveSubscription
                }
            }
            .toolbar(.hidden, for: .navigationBar) // Hide the navigation bar for a clean look
        }
    }
}

#Preview {
    AuthenticationView(showSignInView: .constant(false), isiPhone: .constant(true), isParentFlow: .constant(true))
}
