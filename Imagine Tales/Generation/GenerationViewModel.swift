//
//  GenerationViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

final class StoryViewModel: ObservableObject {
    @Published var storyText: [StoryTextItem] = []
    @Published var imageURL = ""
    @Published var child: UserChildren?
    
    func uploadImage(image: UIImage, completion: @escaping (_ url: String?) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data.")
            completion(nil)
            return
        }

        // Create a reference to Firebase Storage
        let storageRef = Storage.storage().reference()
        let imageName = UUID().uuidString // Unique name for the image
        let imageRef = storageRef.child("images/\(imageName).jpg")

        // Upload the image data
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Fetch the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let downloadURL = url else {
                    print("Error: Download URL is nil.")
                    completion(nil)
                    return
                }

                completion(downloadURL.absoluteString)
            }
        }

        // Handle upload progress and completion (optional)
        uploadTask.observe(.progress) { snapshot in
            // Observe upload progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload is \(percentComplete)% complete")
        }

        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("Upload completed successfully")
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Upload failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func uploadStoryToFirestore(stroTextItem: [StoryTextItem], childId: String, title: String, genre: String, theme: String, mood: String, summary: String) async throws {
        
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        
        
        let document = Firestore.firestore().collection("Story").document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "parentId" : authDataResult.uid,
            "childId" : childId,
            "storyText": stroTextItem.map { item in
                        [
                            "image": item.image,
                            "text": item.text
                        ]
                    },
            "title" : title,
            "status" : "pending",
            "genre" : genre,
            "childUsername" : child?.username ?? "",
            "likes" : 0,
            "theme" : theme,
            "mood" : mood,
            "summary" : summary,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
        
    }
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    self.child = document
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
}

final class ContentViewModel: ObservableObject {
    @Published var characters: [Charater] = []
    @AppStorage("childId") var childId: String = "Default Value"
    @Published var pets: [Pet] = []
    
    func getCharacters() throws {
      
        
        Firestore.firestore().collection("Children2").document(childId).collection("Characters").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.characters = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Charater.self)
            } ?? []
            print(self.characters)
            
        }
    }
    
    func getPets() throws {
      
        
        Firestore.firestore().collection("Children2").document(childId).collection("Pets").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.pets = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Pet.self)
            } ?? []
            print(self.pets)
            
        }
    }
    
    func deleteChar(char: Charater) {
        Firestore.firestore().collection("Children2").document(childId).collection("Characters").document(char.id).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
        }
        else {
          print("Document successfully removed!")
        }
      }
    }
    
    func deletePet(pet: Pet) {
        Firestore.firestore().collection("Children2").document(childId).collection("Pets").document(pet.id).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
        }
        else {
          print("Document successfully removed!")
        }
      }
    }
}
