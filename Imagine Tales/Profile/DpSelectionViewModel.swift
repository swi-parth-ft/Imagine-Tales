//
//  DpSelectionViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

// ViewModel for managing profile image selection and updates
final class DpSelectionViewModel: ObservableObject {
    
    @AppStorage("dpurl") private var dpUrl = "" // AppStorage to persist the selected profile image URL
    
    @Published var imageURL = "" // Published property to hold the current image URL
    
    // Function to update the profile image field in Firestore for a given child ID
    func updateFieldInCollection(childId: String, url: String) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Specify the path to the document you want to update using the child ID
        let documentReference = db.collection("Children2").document(childId)
        
        // Data to update: here we set the new profile image URL
        let updatedData: [String: Any] = [
            "profileImage": url // Replace with the field name and its new value
        ]
        
        // Perform the update in Firestore
        documentReference.updateData(updatedData) { error in
            if let error = error {
                // Print an error message if the update fails
                print("Error updating document: \(error.localizedDescription)")
            } else {
                // Print a success message if the update is successful
                print("Document successfully updated!")
            }
        }
    }
    
    // Function to fetch the profile image URL from Firebase Storage
    func fetchProfileImage(dp: String) {
        // Get a reference to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Specify the path to the profile image in Storage (assuming a naming convention)
        let imageRef = storageRef.child("profileImages/\(dp)")
        
        // Fetch the download URL for the image
        imageRef.downloadURL { url, error in
            if let error = error {
                // Print an error message if fetching the URL fails
                print("Error fetching image URL: \(error)")
                return
            }
            if let url = url {
                // Set the dpUrl property to the fetched URL
                self.dpUrl = url.absoluteString
            }
        }
    }
}
