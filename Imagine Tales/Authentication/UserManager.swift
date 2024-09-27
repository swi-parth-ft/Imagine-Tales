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
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    private func childCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("Children")
    }
    
    private let childCollection2 = Firestore.firestore().collection("Children2")
    private func childDocument() -> DocumentReference {
        childCollection2.document()
    }
    
    private func charCollection(childId: String) -> CollectionReference {
        childCollection2.document(childId).collection("Characters")
    }
    
    private func petCollection(childId: String) -> CollectionReference {
        childCollection2.document(childId).collection("Pets")
    }
    
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    func createNewUser(user: UserModel) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func getUser(userId: String) async throws -> UserModel {
        try await userDocument(userId: userId).getDocument(as: UserModel.self)
    }
    
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String : Any] = [
            "isPremeum" : isPremium
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            "preferences" : FieldValue.arrayUnion([preference])
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            "preferences" : FieldValue.arrayRemove([preference])
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addChar(childId: String, char: Charater) async throws {
        let document = charCollection(childId: childId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "name" : char.name,
            "age" : char.age,
            "gender" : char.gender,
            "emotion" : char.emotion,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    func addPet(childId: String, pet: Pet) async throws {
        let document = petCollection(childId: childId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "name" : pet.name,
            "kind" : pet.kind,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    func addChild(userId: String, name: String, age: String) async throws {
        let document = childCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "parentId" : userId,
            "name" : name,
            "age" : age,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    func addChild2(userId: String, name: String, age: String, username: String, imageUrl: String) async throws {
        let document = childDocument()
        let documentId = document.documentID
        
        let data: [String:Any] = [
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
    
    func getAllUserChildren(userId: String) -> [UserChildren] {
        var items:[UserChildren] = []
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




