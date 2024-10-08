//
//  AuthenticationManager.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import Foundation
import FirebaseAuth

/// Model representing the authentication data result.
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    var isNewUser = false
    
    private init() {}
    
    /// Retrieves the currently authenticated user.
    /// - Throws: An error if no user is authenticated.
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        return AuthDataResultModel(user: user)
    }
    
    /// Creates a new user with the provided email and password.
    /// - Throws: An error if user creation fails.
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Signs out the currently authenticated user.
    /// - Throws: An error if sign-out fails.
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// Signs in a user with the provided email and password.
    /// - Throws: An error if sign-in fails.
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Sends a password reset email to the specified address.
    /// - Throws: An error if the email cannot be sent.
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// Updates the user's password.
    /// - Throws: An error if the update fails.
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    /// Updates the user's email address.
    /// - Throws: An error if the update fails.
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
    
    /// Signs in a user with Google credentials.
    /// - Throws: An error if the sign-in fails.
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    /// Signs in a user with the provided authentication credential.
    /// - Throws: An error if sign-in fails.
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        
        // Determine if the user is new or existing
        isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
        
        if isNewUser {
            print("This is a new user.")
        } else {
            print("This is an existing user.")
        }
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Deletes the currently authenticated user.
    /// - Throws: An error if deletion fails.
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.delete()
    }
    
    /// Signs in a user with Apple credentials.
    /// - Throws: An error if sign-in fails.
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(providerID: AuthProviderID(rawValue: "apple.com")!, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
}
