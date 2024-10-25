//
//  RootView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

/**
 The `RootView` is the main entry point of the Imagine Tales app, responsible for managing the authentication flow and deciding
 which view to present based on the device type (iPhone or iPad) and user authentication status.

 - The view uses a `NavigationStack` as the root of the navigation structure.
 - Based on the current state, it dynamically shows either a `ParentView` or a `TabbarView`.
 - If the user is not signed in, the `AuthenticationView` is presented in full-screen mode.

 This view also handles device type detection (iPhone or iPad) and manages whether to reload the content or not after signing in.
*/

import SwiftUI

/// The main entry point of the app that manages the root view and user authentication state.
struct RootView: View {
    
    // MARK: - State Variables
    
    /// Controls whether the sign-in view should be displayed. Defaults to `true`.
    @State private var showSignInView = true
    
    /// Tracks whether the current device is an iPhone. Defaults to `false`.
    @State private var isiPhone = false
    
    /// Manages whether the parent flow is active. Defaults to `false`.
    @State private var isParentFlow = false
    
    /// The environment variable to check the horizontal size class of the device, which helps identify if it's an iPhone (compact).
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    /// Persists a boolean state across app launches, stored in UserDefaults. Key is `"ipf"`, default is `true`.
    @AppStorage("ipf") private var ipf: Bool = true
    
    /// State variable that toggles to trigger a reload of the view. Defaults to `false`.
    @State private var reload = false
    @StateObject private var subViewModel = SubscriptionViewModel()
    @EnvironmentObject var appState: AppState
    // MARK: - Body View
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Conditionally show ParentView or TabbarView based on whether the device is an iPhone or iPad
                if isiPhone || ipf {
                    ParentView(showSigninView: $showSignInView, reload: $reload, isiPhone: $isiPhone)
                } else {
                    TabbarView(showSignInView: $showSignInView, reload: $reload)
                        
                }
            }
            .onAppear {
                handleAuthentication() // Calls the method to handle user authentication when the view appears
                updateDeviceType() // Updates the device type state when the view appears
            }
            .onChange(of: subViewModel.hasActiveSubscription) {
                appState.isPremium = subViewModel.hasActiveSubscription
            }
            // Presents the AuthenticationView in full-screen mode if the user needs to sign in
            .fullScreenCover(isPresented: $showSignInView, onDismiss: { reload.toggle() }) {
                AuthenticationView(showSignInView: $showSignInView, isiPhone: $isiPhone, isParentFlow: $isParentFlow)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /**
     This method handles the authentication logic for the app.
     
     It checks if a user is currently authenticated. If no user is authenticated, the sign-in view will be displayed.
     */
    private func handleAuthentication() {
        do {
            // Tries to fetch the authenticated user using the shared AuthenticationManager
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            // If the authenticated user is nil, show the sign-in view
            showSignInView = authUser == nil
            subViewModel.loginUser(with: authUser.uid)
        } catch {
            // Logs the error message in case of failure and shows the sign-in view
            print("Failed to get authenticated user: \(error.localizedDescription)")
            showSignInView = true
        }
    }

    /**
     This method updates the `isiPhone` state based on the device's horizontal size class.
     
     It checks if the horizontal size class is compact (typically for iPhones) and updates the `isiPhone` state accordingly.
     */
    private func updateDeviceType() {
        isiPhone = horizontalSizeClass == .compact
    }
}

// Preview section for development to visualize the RootView in SwiftUI previews
#Preview {
    RootView()
}
