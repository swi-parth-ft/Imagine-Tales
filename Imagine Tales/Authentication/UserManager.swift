//
//  UserManager.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum gender: String {
    case male
    case female
}

struct UserModel: Codable {
    let userId: String
    let name: String
    let birthDate: Date?
    let email: String?
    let gender: String
    let country: String
    let number: String
    let isParent: Bool
//    init(auth: AuthDataResultModel) {
//        self.userId = auth.uid
//        self.name = ""
//        self.email = auth.email
//        self.gender = ""
//        self.photoURL = auth.photoURL
//        self.birthDate = Date()
//        self.isPremeum = false
//        self.preferences = []
//        self.country = ""
//    }
    
    init(userId: String, name: String, birthDate: Date?, email: String?, gender: String, country: String, number: String, isParent: Bool) {
        self.userId = userId
        self.name = name
        self.birthDate = birthDate
        self.email = email
        self.gender = gender
        self.country = country
        self.number = number
        self.isParent = isParent
    }
}

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
    
    
//    private func childDocument(userId: String, favoriteProductId: String) -> DocumentReference {
//        childCollection(userId: userId).document(favoriteProductId)
//    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
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

struct UserChildren: Codable, Identifiable {
    
    let id: String
    let parentId: String
    let name: String
    let age: String
    let dateCreated: Date
}

extension Query {
    
//    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
//        try await getDocumentsWithSnapshot(as: type).children
//    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (children: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let children = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (children, snapshot.documents.last)
    }
    
}
