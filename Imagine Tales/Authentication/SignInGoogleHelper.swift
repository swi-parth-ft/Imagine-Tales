//
//  SignInGoogleHelper.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/12/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct googleSignInResultModel {
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper  {
    @MainActor
    func signIn() async throws -> googleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else { throw URLError(.cannotFindHost) }
        
        
        let gidSignInResults = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idToken = gidSignInResults.user.idToken?.tokenString else { throw URLError(.badURL) }
        let accessToken = gidSignInResults.user.accessToken.tokenString
        
        let tokens = googleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
