//
//  AsyncImage.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//

import SwiftUI
import FirebaseStorage

// MARK: - AsyncCircularImageView
struct AsyncCircularImageView: View {
    let urlString: String // URL string for the image
    let size: CGFloat // Size of the circular image
    @State private var retryCount = 0 // Count of retry attempts
    @State private var maxRetryAttempts = 3 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retry attempts

    var body: some View {
        // Asynchronously load the image from the provided URL
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                // Image successfully loaded
                image
                    .resizable()
                    .scaledToFill() // Scale image to fill the frame
                    .frame(width: size, height: size) // Set frame size
                    .clipShape(Circle()) // Clip image to a circular shape

            case .empty, .failure:
                // Placeholder for empty or failed image load
                Circle()
                    .fill(Color.gray.opacity(0.3)) // Gray circle as a placeholder
                    .frame(width: size, height: size) // Set frame size
                    .onAppear {
                        // Retry logic for loading the image
                        if retryCount < maxRetryAttempts {
                            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                retryCount += 1 // Increment retry count
                            }
                        }
                    }

            @unknown default:
                // Handle unexpected states
                EmptyView()
            }
        }
    }
}

// MARK: - AsyncDp
struct AsyncDp: View {
    let urlString: String // URL string for the profile image
    let size: CGFloat // Size of the profile image
    @State private var dpUrl = "" // URL of the fetched profile image
    @State private var retryCount = 0 // Count of retry attempts
    @State private var maxRetryAttempts = 30 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retry attempts

    var body: some View {
        // Asynchronously load the image from the provided URL
        AsyncImage(url: URL(string: dpUrl)) { phase in
            switch phase {
            case .success(let image):
                // Image successfully loaded
                image
                    .resizable()
                    .scaledToFill() // Scale image to fill the frame
                    .frame(width: size, height: size) // Set frame size
                    .clipShape(Circle()) // Clip image to a circular shape

            case .empty, .failure:
                // Placeholder for empty or failed image load
                Circle()
                    .fill(Color.gray.opacity(0.3)) // Gray circle as a placeholder
                    .frame(width: size, height: size) // Set frame size
                    .onAppear {
                        // Retry logic for loading the image
                        if retryCount < maxRetryAttempts {
                            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                retryCount += 1 // Increment retry count
                            }
                        }
                    }

            @unknown default:
                // Handle unexpected states
                EmptyView()
            }
        }
        .onAppear {
            // Fetch the profile image URL when the view appears
            fetchProfileImage()
        }
    }

    // Fetch the profile image URL from Firebase Storage
    func fetchProfileImage() {
        let storage = Storage.storage() // Get default Firebase Storage instance
        let storageRef = storage.reference() // Get a reference to the storage

        // Assuming the profilePicture field contains image names like "1.jpg", "2.jpg", etc.
        let imageRef = storageRef.child("profileImages/\(urlString)") // Reference to the specific image

        // Fetch the download URL for the image
        imageRef.downloadURL { url, error in
            if let error = error {
                print("Error fetching image URL: \(error)") // Print error if fetching fails
                return
            }
            if let url = url {
                self.dpUrl = url.absoluteString // Set the dpUrl with the fetched URL
            }
        }
    }
}
