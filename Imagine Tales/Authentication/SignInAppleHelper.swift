//
//  SignInAppleHelper.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/12/24.
//

import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI

// Structure to hold the results from Sign In with Apple
struct SignInWithAppleResult {
    let token: String
    let nonce: String
}

// UIViewRepresentable for the Sign In with Apple button
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    // Create and return the Apple Sign In button
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    // Update the view (no updates needed for this button)
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

// Main class to handle Sign In with Apple functionality
@MainActor
final class SignInAppleHelper: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)?
    
    /// Starts the Sign In with Apple flow
    func startSignInWithAppleFlow(completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        guard let topVC = Utilities.shared.topViewController() else {
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // Request full name and email
        request.nonce = sha256(nonce) // Hash the nonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    /// Generates a random nonce string for security
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        // Character set for the nonce
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        // Map random bytes to characters in the charset
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    /// Hashes the input string using SHA-256
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        
        // Convert hashed data to hex string
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// Extension to handle the ASAuthorizationControllerDelegate methods
extension SignInAppleHelper: ASAuthorizationControllerDelegate {

    // Called when the authorization process is completed successfully
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        
        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)
        completionHandler?(.success(tokens))
    }
  
    // Called when there is an error during the authorization process
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print("Sign in with Apple errored: \(error)")
        completionHandler?(.failure(URLError(.badServerResponse)))
    }
}

// Extension to provide a presentation anchor for the authorization controller
extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // Return the window for presentation
    }
}
