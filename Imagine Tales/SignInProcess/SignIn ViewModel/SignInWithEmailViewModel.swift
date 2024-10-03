//
//  SignInWithEmailViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import FirebaseFirestore
import FirebaseStorage
import SwiftUI

final class SignInWithEmailViewModel: ObservableObject {
    
    @Published var children: [UserChildren] = []
    
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var date = Date()
    @Published var gender = "Male"
    @Published var country = ""
    @Published var number = ""
    @Published var username = ""
    var userId = ""
    @AppStorage("dpurl") private var dpUrl = ""
    func fetchProfileImage(dp: String) {
        
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // Assuming the profilePicture field contains "1.jpg", "2.jpg", etc.
            let imageRef = storageRef.child("profileImages/\(dp)")
            
            // Fetch the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching image URL: \(error)")
                    return
                }
                if let url = url {
                    self.dpUrl = url.absoluteString
                   
                }
            }
        
        }
    func resetPassword() async throws {

        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    func getChildren() throws {
       
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        
        Firestore.firestore().collection("Children2").whereField("parentId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.children = querySnapshot?.documents.compactMap { document in
                try? document.data(as: UserChildren.self)
            } ?? []
            print(self.children)
            
        }
    }
    
    
    func signInWithEmail() async throws -> AuthDataResultModel? {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        let authResult = try await AuthenticationManager.shared.signIn(email: email, password: password)
        userId = authResult.uid
        return authResult
         
    }
    
    func createAccount() async throws -> AuthDataResultModel? {
        guard !email.isEmpty, !password.isEmpty else {
            print("no email or password found!")
            return nil
        }
        
        let authResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        userId = authResult.uid
        return authResult
    }
    
    func createUserProfile(isParent: Bool) async throws {
        let user = UserModel(userId: userId, name: name, birthDate: date, email: email, gender: gender, country: country, number: number, isParent: isParent)
        let _ = try await UserManager.shared.createNewUser(user: user)
    }
    
    func createGoogleUserProfile(isParent: Bool) async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        let user = UserModel(userId: userId, name: name, birthDate: date, email: authDataResult.email, gender: gender, country: country, number: number, isParent: isParent)
        print(user.userId)
        let _ = try await UserManager.shared.createNewUser(user: user)
    }
    
    func addChild(age: String, dpUrl: String) async throws {
        let _ = try await UserManager.shared.addChild(userId: userId, name: name, age: age)
        let _ = try await UserManager.shared.addChild2(userId: userId, name: name, age: age, username: username.replacingOccurrences(of: " ", with: "_"), imageUrl: dpUrl)
    }
    
    func setPin(pin: String) throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        Firestore.firestore().collection("users").document(userId).updateData(["pin": pin])
    }
    
}
