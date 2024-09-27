//
//  RootView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI

/// The main entry point of the app that manages the root view and user authentication state.
struct RootView: View {
    
    @State private var showSignInView = true // State variable to control the visibility of the sign-in view
    @State private var isiPhone = false // State variable to check if the device is an iPhone
    @State private var isParentFlow = false // State variable to manage parent flow (if needed)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass // Environment variable to check the horizontal size class (compact or regular)
    @AppStorage("ipf") private var ipf: Bool = true // AppStorage variable to persist a boolean state
    @State private var reload = false // State variable to trigger a reload action

    var body: some View {
        NavigationStack {
            ZStack {
                // Conditionally show ParentView or TabbarView based on the device type and state
                if isiPhone || ipf {
                    ParentView(showSigninView: $showSignInView, reload: $reload, isiPhone: $isiPhone)
                } else {
                    TabbarView(showSignInView: $showSignInView, reload: $reload)
                }
            }
            .onAppear {
                handleAuthentication() // Handle user authentication when the view appears
                updateDeviceType() // Update device type state
            }
            .fullScreenCover(isPresented: $showSignInView, onDismiss: { reload.toggle() }) {
                // Present AuthenticationView in full-screen mode if the user needs to sign in
                AuthenticationView(showSignInView: $showSignInView, isiPhone: $isiPhone, isParentFlow: $isParentFlow)
            }
        }
    }
    
    /// Handles the authentication logic when the view appears.
    /// Checks if a user is authenticated and updates the showSignInView state accordingly.
    private func handleAuthentication() {
        do {
            // Attempt to get the currently authenticated user
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            // If there is no authenticated user, show the sign-in view
            showSignInView = authUser == nil
        } catch {
            // Print error message if getting the authenticated user fails
            print("Failed to get authenticated user: \(error.localizedDescription)")
            // Show the sign-in view on error
            showSignInView = true
        }
    }

    /// Updates the isiPhone state based on the horizontal size class of the device.
    /// Determines whether the device is an iPhone (compact size class).
    private func updateDeviceType() {
        isiPhone = horizontalSizeClass == .compact
    }
}

#Preview {
    RootView()
}
