//
//  UserManager.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

struct UserModel: Codable {
    let userId: String
    let createdAt: Date?
    let email: String?
    let photoURL: String?
    let isPremeum: Bool?
    let favMovie: Movie?
    let preferences: [String]?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.createdAt = Date()
        self.isPremeum = false
        self.favMovie = nil
        self.preferences = []
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    private func userFavoriteProductCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favorite_products")
    }
    
    private func userFavoriteProductDocument(userId: String, favoriteProductId: String) -> DocumentReference {
        userFavoriteProductCollection(userId: userId).document(favoriteProductId)
    }
    
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
    
    func addFavoriteMovie(userId: String, movie: Movie) async throws {
        guard let data = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        
        let dict: [String:Any] = [
            "favMovie" : data
        ]

        try await userDocument(userId: userId).updateData(dict)
    }
    
    func removeFavoriteMovie(userId: String) async throws {
        let data: [String:Any?] = [
            "favMovie" : nil
        ]

        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
    }
    
    func addUserFavoriteProduct(userId: String, productId: Int) async throws {
        let document = userFavoriteProductCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "productId" : productId,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
    }
    
    func removeUserFavoriteProduct(userId: String, favoriteProductId: String) async throws {
        try await userFavoriteProductDocument(userId: userId, favoriteProductId: favoriteProductId).delete()
    }
    
    func getAllUserFavoriteProducts(userId: String) async throws -> [UserFavoriteProduct] {
        try await userFavoriteProductCollection(userId: userId).getDocuments(as: UserFavoriteProduct.self)
    }
    
   
    
}

struct UserFavoriteProduct: Codable {
    let id: String
    let productId: Int
    let dateCreated: Date
    
}
