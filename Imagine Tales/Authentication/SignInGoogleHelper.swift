//
//  SignInGoogleHelper.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/12/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

/// Model representing the result of a Google Sign-In operation.
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper {
    
    /// Initiates the Google Sign-In process and returns the resulting tokens.
    /// - Throws: An error if the sign-in fails or if tokens cannot be retrieved.
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        // Retrieve the topmost view controller for presenting the sign-in UI
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost) // More descriptive error handling
        }
        
        // Perform the Google Sign-In
        let gidSignInResults = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        // Ensure the ID token exists, throw an error if it does not
        guard let idToken = gidSignInResults.user.idToken?.tokenString else {
            throw URLError(.badURL) // More descriptive error handling
        }
        
        // Retrieve the access token
        let accessToken = gidSignInResults.user.accessToken.tokenString
        
        // Create and return the result model
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
