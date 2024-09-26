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
    
    @AppStorage("dpurl") private var dpUrl = ""
    
    @Published var imageURL = ""

    
    
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

}
struct DpSelectionView: View {
    @StateObject var viewModel = DpSelectionViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    let images: [String] = ["dp2", "dp1", "dp3", "dp4", "dp5", "dp6", "dp7", "dp8", "dp9", "dp10", "dp11", "dp12" ] // Use image names as an array of strings
    @State private var selectedImage = ""
    @AppStorage("dpurl") private var dpUrl = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
       
            ZStack {
               
                VisualEffectBlur(blurStyle: .systemThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                VStack(alignment: .leading) {
                    Text("Select Profile Image")
                        .font(.title)
                        .padding([.leading, .top])
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            
                            ForEach(images, id: \.self) { image in
                                VStack {
                                    
                                    ZStack {
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 170, height: 170)
                                        Image(image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                        
                                        
                                            .scaleEffect(image == selectedImage ? 1.1 : 1)
                                        
                                        VStack {
                                            
                                            if image == selectedImage {
                                                Button("Set", systemImage: "checkmark.circle.fill") {
                                                    viewModel.updateFieldInCollection(childId: childId, url: String(image + ".jpg"))
                                                    viewModel.fetchProfileImage(dp: image + ".jpg")
                                                    dismiss()
                                                }
                                                .padding()
                                                .background(Color.white.opacity(0.9))
                                                .foregroundStyle(.black)
                                                .cornerRadius(22)
                                            }
                                            
                                        }
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        selectedImage = image
                                        
                                        
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                }
            

        }
    }
}

#Preview {
    DpSelectionView()
}
