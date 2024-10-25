//
//  AuthenticationViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import GoogleSignIn
import GoogleSignInSwift
import RevenueCat
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var didSignInWithApple = false
    @Published var didSignInWithGoogle = false
    
    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws -> AuthDataResultModel?{
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        self.didSignInWithGoogle = true
            return authDataResult
        
      
    }
    
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let _ = try await AuthenticationManager.shared.signInWithApple(tokens: signInAppleResult)
                        self.didSignInWithApple = true
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

 
    
}
