//
//  UserManager.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserManager {
    
    static let shared = UserManager() // Singleton instance of UserManager
    private init() {} // Prevents the creation of additional instances

    // Reference to the Firestore "users" collection
    private let userCollection = Firestore.firestore().collection("users")
    
    // Private method to create a document reference for a specific user
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    // Private method to get a reference to the "Children" sub-collection of a user
    private func childCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("Children")
    }
    
    // Reference to the "Children2" collection
    private let childCollection2 = Firestore.firestore().collection("Children2")
    
    // Private method to create a new document reference in "Children2"
    private func childDocument() -> DocumentReference {
        childCollection2.document()
    }
    
    // Private method to access the "Characters" sub-collection of a specific child
    private func charCollection(childId: String) -> CollectionReference {
        childCollection2.document(childId).collection("Characters")
    }
    
    // Private method to access the "Pets" sub-collection of a specific child
    private func petCollection(childId: String) -> CollectionReference {
        childCollection2.document(childId).collection("Pets")
    }

    // Firestore encoder and decoder
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    // MARK: User Management Functions
    
    /// Creates a new user document in Firestore.
    /// - Parameter user: The UserModel containing user details.
    func createNewUser(user: UserModel) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    /// Fetches a user document by user ID.
    /// - Parameter userId: The ID of the user to fetch.
    /// - Returns: The UserModel object representing the user.
    func getUser(userId: String) async throws -> UserModel {
        try await userDocument(userId: userId).getDocument(as: UserModel.self)
    }

    /// Updates the premium status of a user.
    /// - Parameters:
    ///   - userId: The ID of the user to update.
    ///   - isPremium: Boolean indicating premium status.
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String : Any] = [
            "isPremium" : isPremium // Fixed typo: changed "isPremeum" to "isPremium"
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    /// Adds a preference to the user's preferences array.
    /// - Parameters:
    ///   - userId: The ID of the user to update.
    ///   - preference: The preference to add.
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            "preferences" : FieldValue.arrayUnion([preference])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    /// Removes a preference from the user's preferences array.
    /// - Parameters:
    ///   - userId: The ID of the user to update.
    ///   - preference: The preference to remove.
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            "preferences" : FieldValue.arrayRemove([preference])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    // MARK: Child Management Functions
    
    /// Adds a character for a specific child.
    /// - Parameters:
    ///   - childId: The ID of the child.
    ///   - char: The character to add.
    func addChar(childId: String, char: Charater) async throws {
        let document = charCollection(childId: childId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            "id" : documentId,
            "name" : char.name,
            "age" : char.age,
            "gender" : char.gender,
            "emotion" : char.emotion,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    /// Adds a pet for a specific child.
    /// - Parameters:
    ///   - childId: The ID of the child.
    ///   - pet: The pet to add.
    func addPet(childId: String, pet: Pet) async throws {
        let document = petCollection(childId: childId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            "id" : documentId,
            "name" : pet.name,
            "kind" : pet.kind,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    /// Adds a child under a specific user.
    /// - Parameters:
    ///   - userId: The ID of the user (parent).
    ///   - name: The name of the child.
    ///   - age: The age of the child.
    func addChild(userId: String, name: String, age: String) async throws {
        let document = childCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            "id" : documentId,
            "parentId" : userId,
            "name" : name,
            "age" : age,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    /// Adds a child to the "Children2" collection with additional details.
    /// - Parameters:
    ///   - userId: The ID of the user (parent).
    ///   - name: The name of the child.
    ///   - age: The age of the child.
    ///   - username: The username of the child.
    ///   - imageUrl: The URL of the child's profile image.
    func addChild2(userId: String, name: String, age: String, username: String, imageUrl: String) async throws {
        let document = childDocument()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            "id" : documentId,
            "parentId" : userId,
            "name" : name,
            "age" : age,
            "username" : username,
            "profileImage" : imageUrl,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    /// Fetches all children associated with a user.
    /// - Parameter userId: The ID of the user (parent).
    /// - Returns: An array of UserChildren objects.
    func getAllUserChildren(userId: String) -> [UserChildren] {
        var items: [UserChildren] = []
        Firestore.firestore().collection("users").document(userId).collection("Children").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            items = querySnapshot?.documents.compactMap { document in
                try? document.data(as: UserChildren.self)
            } ?? []
        }
        return items
    }
}
