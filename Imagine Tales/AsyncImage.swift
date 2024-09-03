//
//  AsyncImage.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//

import SwiftUI
import FirebaseStorage

struct AsyncCircularImageView: View {
    let urlString: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle()) // Clip to circle shape
                
            case .empty, .failure:
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                
            @unknown default:
                EmptyView()
            }
        }
    }
}
struct AsyncDp: View {
    let urlString: String
    let size: CGFloat
    @State private var dpUrl = ""
    
    var body: some View {
        AsyncImage(url: URL(string: dpUrl)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle()) // Clip to circle shape
                
            case .empty, .failure:
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                
            @unknown default:
                EmptyView()
            }
        }
        .onAppear {
            fetchProfileImage()
        }
    }
    
    func fetchProfileImage() {
        
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // Assuming the profilePicture field contains "1.jpg", "2.jpg", etc.
            let imageRef = storageRef.child("profileImages/\(urlString)")
            
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
