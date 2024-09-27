//
//  ReAuthentication.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// ViewModel responsible for handling reauthentication processes for users.
final class ReAuthentication: ObservableObject {
    
    // Published properties to trigger UI updates when values change
    @Published var reAuthenticated: Bool = false // Indicates if the user has been reauthenticated
    @Published var email = "" // User's email for reauthentication
    @Published var password = "" // User's password for reauthentication
    @Published var signedInWithGoogle = false // Flag to check if the user signed in with Google
    
    /// Checks if the current user signed in with Google
    func checkIfGoogle() {
        if let user = Auth.auth().currentUser { // Get the current user
            // Loop through the user's provider data
            for userInfo in user.providerData {
                // Check if the provider ID is Google
                if userInfo.providerID == "google.com" {
                    signedInWithGoogle = true // Set flag if signed in with Google
                    // Perform actions specific to Google-signed-in users here
                    break
                }
                // Get the user's email
                self.email = user.email!
            }
        } else {
            print("No user is signed in.") // Log if no user is signed in
        }
    }
    
    /// Reauthenticate user with Google credentials
    func reAuthWithGoogle() async throws {
        let helper = SignInGoogleHelper() // Initialize Google sign-in helper
        let tokens = try await helper.signIn() // Await for sign-in tokens
        let user = Auth.auth().currentUser // Get the current user
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens) // Sign in with Google tokens
        
        // Create a credential using the Google tokens
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        // Reauthenticate the user with the Google credential
        user!.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                // Handle reauthentication error
                print("Reauthentication failed: \(error.localizedDescription)") // Log the error
            } else {
                // Reauthentication was successful
                print("Reauthentication successful.") // Log success
                self.reAuthenticated = true // Update reAuthenticated status
            }
        }
    }
    
    /// Reauthenticate user with email and password
    func reAuthWithEmail() {
        if let user = Auth.auth().currentUser { // Check if a user is signed in
            
            let email = email  // Obtain these from the user input
            let password = password // Obtain these from the user input
            
            // Create an email credential for reauthentication
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            // Reauthenticate the user with the email credential
            user.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    // An error occurred while trying to reauthenticate
                    print("Reauthentication failed: \(error.localizedDescription)") // Log the error
                    self.reAuthenticated = false // Update reAuthenticated status to false
                } else {
                    // Reauthentication was successful
                    print("Reauthentication successful.") // Log success
                    self.reAuthenticated = true // Update reAuthenticated status to true
                }
            }
        }
    }
    
    /// Set a new PIN for the user
    func setPin(pin: String) throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // Get the authenticated user
        // Update the user's document in Firestore with the new PIN
        Firestore.firestore().collection("users").document(authDataResult.uid).updateData(["pin": pin]) { error in
            if let error = error {
                print("Error setting pin: \(error.localizedDescription)") // Log any errors
            } else {
                print("PIN successfully updated!") // Log success
            }
        }
    }
}
