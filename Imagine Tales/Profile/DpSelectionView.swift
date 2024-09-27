//
//  DpSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import Drops

// View for selecting a profile image
struct DpSelectionView: View {
    @StateObject var viewModel = DpSelectionViewModel() // ViewModel to manage profile image selection and updates
    @AppStorage("childId") var childId: String = "Default Value" // AppStorage to persist selected child ID
    // Define the layout for a grid of images
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    // Array of image names to display
    let images: [String] = ["dp2", "dp1", "dp3", "dp4", "dp5", "dp6", "dp7", "dp8", "dp9", "dp10", "dp11", "dp12"]
    @State private var selectedImage = "" // State variable to keep track of the currently selected image
    @AppStorage("dpurl") private var dpUrl = "" // AppStorage to persist the selected profile image URL
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view
    
    var body: some View {
        ZStack {
            // Set the background color of the view
            Color(hex: "#8AC640").ignoresSafeArea()
            VStack(alignment: .leading) {
                // Title for the selection screen
                Text("Select Profile Image")
                    .font(.title)
                    .padding([.leading, .top])
                
                // Scrollable view for the grid of images
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        // Loop through each image in the array
                        ForEach(images, id: \.self) { image in
                            VStack {
                                ZStack {
                                    // Circle background for each image
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 170, height: 170)
                                    
                                    // Display the profile image
                                    Image(image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle()) // Clip to a circle shape
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Add shadow effect
                                        .scaleEffect(image == selectedImage ? 1.1 : 1) // Scale up if selected
                                    
                                    // Conditional display for the selected image
                                    VStack {
                                        if image == selectedImage {
                                            // Set button to confirm selection
                                            Button("Set", systemImage: "checkmark.circle.fill") {
                                                // Update the profile image in Firestore
                                                viewModel.updateFieldInCollection(childId: childId, url: String(image + ".jpg"))
                                                // Fetch the new profile image
                                                viewModel.fetchProfileImage(dp: image + ".jpg")
                                                // Show a drop notification
                                                let drop = Drop(title: "Profile Image Changed!", icon: UIImage(systemName: "pawprint.fill"))
                                                Drops.show(drop)
                                                dismiss() // Dismiss the view after setting the image
                                            }
                                            .padding() // Add padding around the button
                                            .background(Color.white.opacity(0.9)) // Set background with slight opacity
                                            .foregroundStyle(.black) // Set foreground color to black
                                            .cornerRadius(22) // Round the corners of the button
                                        }
                                    }
                                }
                            }
                            // Gesture to select an image
                            .onTapGesture {
                                withAnimation {
                                    selectedImage = image // Update selected image with animation
                                }
                            }
                        }
                    }
                    .padding() // Add padding around the grid
                }
            }
        }
    }
}

#Preview {
    DpSelectionView() // Preview for the view
}
