//
//  SignInWithEmailViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import FirebaseMessaging

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
    
    func checkIfUserDocumentExists(documentId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(documentId)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                completion(false)
            } else if let document = document, document.exists {
                print("Document exists.")
                completion(true)
            } else {
                print("Document does not exist.")
                completion(false)
            }
        }
    }
    
    // Fetch the FCM token and update Firestore with the selected child's token
    func addFCMToken(childId: String) {
        if let fcmToken = Messaging.messaging().fcmToken {
            let currentChildId = childId // Get the active child ID from your app logic
            
            let childRef = Firestore.firestore().collection("Children2").document(currentChildId)

                // Check if the child document exists
                childRef.getDocument { (document, error) in
                    if let error = error {
                        print("Error fetching child document: \(error.localizedDescription)")
                        return
                    }

                    // If the document does not exist, create it with the fcmToken
                    if let document = document, document.exists {
                        // Document exists, update the fcmToken
                        childRef.updateData([
                            "fcmToken": fcmToken
                        ]) { error in
                            if let error = error {
                                print("Error updating FCM token: \(error.localizedDescription)")
                            } else {
                                print("FCM token updated successfully for child ID: \(currentChildId)")
                            }
                        }
                    } else {
                        // Document does not exist, create it with the fcmToken
                        let childData: [String: Any] = [
                            "fcmToken": fcmToken // Initialize the fcmToken field
                        ]
                        childRef.setData(childData) { error in
                            if let error = error {
                                print("Error creating child document: \(error.localizedDescription)")
                            } else {
                                print("Child document created successfully with FCM token for ID: \(currentChildId)")
                            }
                        }
                    }
                }
        }
    }
            
    
}
