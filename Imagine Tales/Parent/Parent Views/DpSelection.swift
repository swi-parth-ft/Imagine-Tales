//
//  DpSelection.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// View for selecting a profile image from a set of predefined images
struct DpSelection: View {
    @Binding var selectedImageName: String // Binding to keep track of the selected image
    // Array of image names representing available profile pictures
    let images: [String] = ["dp2", "dp1", "dp3", "dp4", "dp5", "dp6", "dp7", "dp8", "dp9", "dp10", "dp11", "dp12", "dp13", "dp14", "dp15", "dp16", "dp17", "dp18", "dp19", "dp20", "dp21", "dp22", "dp23"]
    
    // Define a flexible grid layout with 3 columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view
    
    var isCompact: Bool // Variable to check if the layout is compact

    var body: some View {
        ZStack {
            // Background blur effect
            BackGroundMesh().ignoresSafeArea()
            
            VStack(alignment: .leading) {
                // Title for the image selection
                Text("Select Profile Image")
                    .font(.title)
                    .padding([.leading, .top]) // Padding for title
                
                ScrollView { // Scrollable view for grid of images
                    LazyVGrid(columns: columns, spacing: 16) { // LazyVGrid for image layout
                        // Iterate over image names and create image views
                        ForEach(images, id: \.self) { image in
                            VStack {
                                ZStack {
                                    // Circle background for each image
                                    Circle()
                                        .fill(Color.white) // White fill for the circle
                                        .frame(width: isCompact ? 170 / 2 : 170) // Conditional width based on layout
                                    
                                    // Profile image with rounded shape
                                    Image(image)
                                        .resizable() // Make the image resizable
                                        .scaledToFill() // Scale to fill the circle
                                        .frame(width: isCompact ? 150 / 2 : 150) // Conditional width
                                        .clipShape(Circle()) // Clip image to circle shape
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Shadow effect
                                    
                                    // Scale effect to highlight the selected image
                                    .scaleEffect(image == selectedImageName ? 1.1 : 1) // Slightly enlarge selected image
                                    
                                    VStack {
                                        // Button to confirm selection for the currently selected image
                                        if image == selectedImageName {
                                            Button("Set", systemImage: "checkmark.circle.fill") {
                                                dismiss() // Dismiss the view when the button is tapped
                                            }
                                            .padding() // Padding for button
                                            .background(Color.white.opacity(0.9)) // Background color
                                            .foregroundStyle(.black) // Text color
                                            .cornerRadius(22) // Rounded corners for button
                                        }
                                    }
                                }
                            }
                            // Gesture to select an image on tap
                            .onTapGesture {
                                withAnimation {
                                    selectedImageName = image // Update the selected image
                                }
                            }
                        }
                    }
                    .padding() // Padding for the grid
                }
            }
        }
    }
}
