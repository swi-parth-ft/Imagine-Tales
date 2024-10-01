//
//  AddChildForm.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import Drops

// View to add a new child with their details and an optional profile image
struct AddChildForm: View {
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view
    @StateObject var viewModel = ParentViewModel() // StateObject for managing child data
    @State private var isSelectingImage = false // State variable to track if image selection is in progress
    @State private var selectedImageName = "" // State variable to hold the name of the selected image
    var isCompact: Bool // A boolean to determine layout behavior

    var body: some View {
        ZStack {
            // Background mesh view for aesthetics
            BackGroundMesh()

            VStack {
                VStack {
                    // Circle for displaying the profile image or image selection icon
                    ZStack {
                        Circle()
                            .fill(Color.white) // Background circle color
                            .frame(width: 250, height: 250) // Size of the circle

                        // Display an icon if no image has been selected
                        if selectedImageName == "" {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 200)) // Size of the icon
                                .foregroundStyle(.gray.opacity(0.4)) // Icon color
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Shadow effect
                        } else {
                            // Display the selected image if one has been chosen
                            Image(selectedImageName)
                                .resizable() // Enable resizing of the image
                                .scaledToFill() // Scale the image to fill the circle
                                .frame(width: 200, height: 200) // Size of the image
                                .clipShape(Circle()) // Clip the image to a circle
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Shadow effect
                        }
                    }
                    // Action to select an image when the circle is tapped
                    .onTapGesture {
                        isSelectingImage = true // Trigger image selection
                    }
                    .padding()

                    // Text fields for entering child's details
                    VStack {
                        TextField("Name", text: $viewModel.name) // Name input field
                            .padding()
                            .background(.white.opacity(0.4)) // Background color for the text field
                        TextField("Age", text: $viewModel.age) // Age input field
                            .padding()
                            .background(.white.opacity(0.4)) // Background color for the text field
                        TextField("Username", text: $viewModel.username) // Username input field
                            .padding()
                            .background(.white.opacity(0.4)) // Background color for the text field
                    }
                }

                // Button to add the child
                Button("Add Child") {
                    if viewModel.name.isEmpty || viewModel.username.isEmpty || viewModel.age.isEmpty {
                        Drops.show("Please fill all details.")
                    }
                    Task {
                        do {
                            try await viewModel.addChild() // Attempt to add the child using the view model
                            dismiss() // Dismiss the view after successful addition
                        } catch {
                            print(error.localizedDescription) // Print error message if operation fails
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.5, height: 55) // Button size
                .background(Color(hex: "#FF6F61")) // Button background color
                .foregroundStyle(.white) // Button text color
                .cornerRadius(12) // Button corner radius for rounded edges
            }
            .padding() // Padding around the VStack

            // Sheet for selecting a profile image
            .sheet(isPresented: $isSelectingImage, onDismiss: {
                viewModel.imageUrl = "\(selectedImageName).jpg" // Set the image URL when selection is complete
            }) {
                DpSelection(selectedImageName: $selectedImageName, isCompact: isCompact) // Image selection view
            }
        }
    }
}
