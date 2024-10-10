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
    @Environment(\.colorScheme) var colorScheme
    enum AgeRange: String, CaseIterable {
        case sixToEight = "6-8"
        case eightToTen = "8-10"
        case tenToTwelve = "10-12"
        case twelveToFourteen = "12-14"
    }
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        ZStack {
            // Background mesh view for aesthetics
            BackGroundMesh()

            VStack {
                VStack {
                    
                    // Circle for displaying the profile image or image selection icon
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white) // Background circle color
                            .frame(width: 200, height: 200) // Size of the circle

                        // Display an icon if no image has been selected
                        if selectedImageName == "" {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 170)) // Size of the icon
                                .foregroundStyle(.gray.opacity(0.4)) // Icon color
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Shadow effect
                        } else {
                            // Display the selected image if one has been chosen
                            Image(selectedImageName)
                                .resizable() // Enable resizing of the image
                                .scaledToFill() // Scale the image to fill the circle
                                .frame(width: 170, height: 170) // Size of the image
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
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .cornerRadius(12) // Background color for the text field
                        TextField("Username", text: $viewModel.username) // Username input field
                            .padding()
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .cornerRadius(12) // Background color for the text field
                        Text("Select Age")
                            .padding(.top)
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(AgeRange.allCases, id: \.self) { range in
                                Button(action: {
                                    viewModel.age = range.rawValue
                                }) {
                                    Text(range.rawValue)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(viewModel.age != range.rawValue ? Color.clear : colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"), lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.bottom)
                        
                    }
                }

                // Button to add the child
                Button {
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
                } label: {
                    Text("Add Child")
                        .frame(width: UIScreen.main.bounds.width * 0.5, height: 55) // Button size
                        .background(Color(hex: "#FF6F61")) // Button background color
                        .foregroundStyle(.white) // Button text color
                        .cornerRadius(12) // Button corner radius for rounded edges
                }
                
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

struct AgeRangeButtonFromParent: View {
    let ageRange: AddChildForm.AgeRange
    @Binding var selectedAgeRange: AddChildForm.AgeRange?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            selectedAgeRange = ageRange
        }) {
            Text(ageRange.rawValue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedAgeRange != ageRange ? Color.clear : colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
                
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"), lineWidth: 2)
                )
        }
        
    }
}
