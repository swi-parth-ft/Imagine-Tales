//
//  ReAuthentication.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Drops
import GoogleSignIn

/// ViewModel responsible for handling reauthentication processes for users.
@MainActor
final class ReAuthentication: ObservableObject {
    
    // Published properties to trigger UI updates when values change
    @Published var reAuthenticated: Bool = false // Indicates if the user has been reauthenticated
    @Published var email = "" // User's email for reauthentication
    @Published var password = "" // User's password for reauthentication
    @Published var signedInWithGoogle = false // Flag to check if the user signed in with Google
    @Published var signedInWithApple = false
    let signInAppleHelper = SignInAppleHelper()
    /// Checks if the current user signed in with Google or Apple
    func checkIfGoogle() {
        if let user = Auth.auth().currentUser { // Get the current user
            // Loop through the user's provider data
            for userInfo in user.providerData {
                // Check if the provider ID is Google
                if userInfo.providerID == "google.com" {
                    signedInWithGoogle = true // Set flag if signed in with Google
                    // Perform actions specific to Google-signed-in users here
                    break
                } else if userInfo.providerID == "apple.com" {
                    signedInWithApple = true // Set flag if signed in with Apple
                    // Perform actions specific to Apple-signed-in users here
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
    func reAuthWithEmail(completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            let email = self.email // Email from user input
            let password = self.password // Password from user input
            
            // Create an email credential for reauthentication
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            // Reauthenticate the user with the email credential
            user.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    // An error occurred during reauthentication
                    print("Reauthentication failed: \(error.localizedDescription)")
                    completion(false)
                } else {
                    // Reauthentication was successful
                    self.reAuthenticated = true
                    print("Reauthentication successful.")
                    completion(true)
                }
            }
        } else {
            // No user is signed in
            completion(false)
        }
    }
    
    func reAuthWithApple(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false) // Safely handle nil user
            return
        }

        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    let credential = OAuthProvider.credential(
                        providerID: AuthProviderID(rawValue: "apple.com")!,
                        idToken: signInAppleResult.token,
                        rawNonce: signInAppleResult.nonce
                    )
                    
                    // Reauthenticate with the obtained credential
                    user.reauthenticate(with: credential) { authResult, error in
                        if let error = error {
                            print("Reauthentication failed: \(error.localizedDescription)")
                            completion(false) // Indicate failure
                        } else {
                            print("Reauthentication successful.")
                            completion(true) // Indicate success
                            self.reAuthenticated = true
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false) // Indicate failure
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
    
    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }

        checkIfGoogle() // Call your existing method to check sign-in provider
        if signedInWithGoogle {
            // If signed in with Google, re-authenticate and delete account
            Task {
                do {
                    try await reAuthWithGoogle() // Call your reAuthWithGoogle method
                    performAccountDeletion(userId: user.uid, completion: completion)
                } catch {
                    completion(error) // Handle re-authentication error
                }
            }
        } else if signedInWithApple {
            // If signed in with Apple, re-authenticate and delete account
            reAuthWithApple { success in
                if success {
                    self.performAccountDeletion(userId: user.uid, completion: completion)
                } else {
                    completion(NSError(domain: "Reauthentication", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple reauthentication failed."]))
                }
            }
        } else {
            // If signed in with email/password, re-authenticate and delete account
            reAuthWithEmail { success in
                if success {
                    self.performAccountDeletion(userId: user.uid, completion: completion)
                } else {
                    completion(NSError(domain: "Reauthentication", code: 1, userInfo: [NSLocalizedDescriptionKey: "Email reauthentication failed."]))
                }
            }
        }
    }

    // Perform account deletion and associated data cleanup
    private func performAccountDeletion(userId: String, completion: @escaping (Error?) -> Void) {
        // Delete user-related data from Firestore
        deleteUserData(userId: userId) { error in
            if let error = error {
                completion(error)
            } else {
                // If data deletion is successful, delete the Firebase account
                self.deleteFirebaseAccount(completion: completion)
            }
        }
    }

    private func deleteUserData(userId: String, completion: @escaping (Error?) -> Void) {
        // Example: Deleting user data logic (implement as needed)
        Firestore.firestore().collection("users").document(userId).delete { error in
            completion(error)
        }
    }

    private func deleteFirebaseAccount(completion: @escaping (Error?) -> Void) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                completion(error)
            } else {
                print("Firebase account deleted successfully.")
                completion(nil)
            }
        }
    }
    
    
   

    

   
}
