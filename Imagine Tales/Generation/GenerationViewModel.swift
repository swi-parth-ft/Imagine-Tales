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

// ViewModel responsible for handling story-related operations, including uploading images and story data to Firestore
final class StoryViewModel: ObservableObject {
    // Published properties to store story text and child information
    @Published var storyText: [StoryTextItem] = []  // Holds the list of story text items
    @Published var imageURL = ""                    // Stores the URL of the uploaded image
    @Published var child: UserChildren?             // Stores the child's information

    // Function to upload an image to Firebase Storage
    func uploadImage(image: UIImage, completion: @escaping (_ url: String?) -> Void) {
        // Convert the UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data.")
            completion(nil)
            return
        }

        // Reference to Firebase Storage
        let storageRef = Storage.storage().reference()
        let imageName = UUID().uuidString // Create a unique name for the image
        let imageRef = storageRef.child("images/\(imageName).jpg") // Reference path in Firebase

        // Upload the image data
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                // Handle any errors during upload
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Fetch the download URL once upload is successful
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                // Check if the URL is available and return it via the completion handler
                guard let downloadURL = url else {
                    print("Error: Download URL is nil.")
                    completion(nil)
                    return
                }

                completion(downloadURL.absoluteString) // Pass the URL back to the caller
            }
        }

        // Optional: Observe upload progress and success/failure states
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload is \(percentComplete)% complete") // Log upload progress
        }

        uploadTask.observe(.success) { _ in
            print("Upload completed successfully") // Log success message
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Upload failed with error: \(error.localizedDescription)") // Log failure message
            }
        }
    }

    // Function to upload story data to Firestore
    func uploadStoryToFirestore(storyTextItem: [StoryTextItem], childId: String, title: String, genre: String, theme: String, mood: String, summary: String) async throws {
        // Get the authenticated user's ID
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()

        // Create a new document in the "Story" collection
        let document = Firestore.firestore().collection("Story").document()
        let documentId = document.documentID // Generate a unique document ID

        // Prepare the story data to upload
        let data: [String: Any] = [
            "id": documentId,
            "parentId": authDataResult.uid, // Parent user ID
            "childId": childId, // Child's ID
            "storyText": storyTextItem.map { item in
                // Map each story text item to a dictionary format
                [
                    "image": item.image,
                    "text": item.text
                ]
            },
            "title": title,
            "status": "pending", // Story status (pending/approved)
            "genre": genre, // Story genre
            "childUsername": child?.username ?? "", // Child's username (optional)
            "likes": 0, // Initialize like count to zero
            "theme": theme, // Story theme
            "mood": mood, // Story mood
            "summary": summary, // Story summary
            "dateCreated": Timestamp() // Story creation timestamp
        ]

        // Upload the story data to Firestore
        try await document.setData(data, merge: true)
    }

    // Function to fetch child information from Firestore
    func fetchChild(ChildId: String) {
        // Reference to the child's document in Firestore
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)

        // Fetch the child's document and map it to the UserChildren model
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                // Successfully fetched the child's information
                self.child = document
            case .failure(let error):
                // Handle any errors
                print(error.localizedDescription)
            }
        }
    }
}

// ViewModel responsible for handling character and pet-related operations
final class ContentViewModel: ObservableObject {
    @Published var characters: [Charater] = [] // Stores the list of characters
    @AppStorage("childId") var childId: String = "Default Value" // Stores the child's ID using AppStorage
    @Published var pets: [Pet] = [] // Stores the list of pets

    // Function to fetch characters from Firestore
    func getCharacters() throws {
        // Fetch characters from the Firestore collection associated with the child
        Firestore.firestore().collection("Children2").document(childId).collection("Characters").getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle errors
                print("Error getting documents: \(error)")
                return
            }

            // Map the fetched documents to the Charater model
            self.characters = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Charater.self)
            } ?? []
            print(self.characters) // Debug print
        }
    }

    // Function to fetch pets from Firestore
    func getPets() throws {
        // Fetch pets from the Firestore collection associated with the child
        Firestore.firestore().collection("Children2").document(childId).collection("Pets").getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle errors
                print("Error getting documents: \(error)")
                return
            }

            // Map the fetched documents to the Pet model
            self.pets = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Pet.self)
            } ?? []
            print(self.pets) // Debug print
        }
    }

    // Function to delete a character from Firestore
    func deleteChar(char: Charater) {
        Firestore.firestore().collection("Children2").document(childId).collection("Characters").document(char.id).delete { err in
            if let err = err {
                // Handle errors during deletion
                print("Error removing document: \(err)")
            } else {
                // Success
                print("Document successfully removed!")
            }
        }
    }

    // Function to delete a pet from Firestore
    func deletePet(pet: Pet) {
        Firestore.firestore().collection("Children2").document(childId).collection("Pets").document(pet.id).delete { err in
            if let err = err {
                // Handle errors during deletion
                print("Error removing document: \(err)")
            } else {
                // Success
                print("Document successfully removed!")
            }
        }
    }
}
