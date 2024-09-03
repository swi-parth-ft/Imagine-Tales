//
//  DpSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

final class DpSelectionViewModel: ObservableObject {
    @Published var imageURL = ""
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
    
    
    func updateFieldInCollection(childId: String, url: String) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Specify the path to the document you want to update
        let documentReference = db.collection("Children2").document(childId)
        
        // Data to update
        let updatedData: [String: Any] = [
            "profileImage": url  // Replace with the field name and its new value
        ]
        
        // Perform the update
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated!")
            }
        }
    }
}
struct DpSelectionView: View {
    @StateObject var viewModel = DpSelectionViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    
    let images: [String] = ["dp1", "dp2"] // Use image names as an array of strings
    @State private var selectedImage = Image("dp1")
    
    var body: some View {
        List {
            ForEach(images, id: \.self) { imageName in
                HStack {
                    Image(imageName) // Create Image from the string name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    Spacer()
                    Button("Set") {
                        viewModel.uploadImage(image: UIImage(named: imageName)!) { url in
                            if let url = url {
                                viewModel.updateFieldInCollection(childId: childId, url: url)
                            }
                        }
                    }
                }
                   
            }
        }
    }
}

#Preview {
    DpSelectionView()
}
