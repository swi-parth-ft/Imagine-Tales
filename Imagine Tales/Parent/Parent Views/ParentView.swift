//
//  ParentView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/25/24.
//

import SwiftUI
import FirebaseAuth
// Main view for the parent interface where they can manage their children
struct ParentView: View {
    @StateObject var viewModel = ParentViewModel() // ViewModel to manage the parent's data
    @Binding var showSigninView: Bool // Binding to control the visibility of the sign-in view
    @State private var isAddingNew = false // State variable to track if a new child is being added
    @State private var isShowingSetting = false // State variable to track if the settings view is shown
    @Binding var reload: Bool // Binding to trigger reload of child data
    @Binding var isiPhone: Bool // Binding to check if the device is an iPhone
    @AppStorage("ipf") private var ipf: Bool = true // AppStorage to persist a value across launches
    @AppStorage("childId") var childId: String = "Default Value" // AppStorage to persist the current child ID
    @Environment(\.horizontalSizeClass) var horizontalSizeClass // Environment variable to check size class
    @State private var isCompact = false // State variable to track if the layout is compact
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background mesh view
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    // List to display children
                    List {
                        ForEach(viewModel.children) { child in
                            // Navigation link to the ChildView
                            NavigationLink(destination: ChildView(isiPhone: $isiPhone, child: child)) {
                                HStack {
                                    // Display child's profile image
                                    Image(child.profileImage.removeJPGExtension())
                                        .resizable() // Enable resizing
                                        .scaledToFit() // Scale the image to fit
                                        .frame(width: 50, height: 50) // Set frame size
                                        .cornerRadius(25) // Make image circular
                                    Text(child.name) // Display child's name
                                    Spacer() // Spacer to push content to the right
                                }
                            }
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.4)) // Background color for list row
                        }
                        .onDelete(perform: viewModel.deleteChild) // Enable swipe-to-delete functionality
                        
                        // Button to add a new child
                        Button("Add Child") {
                            isAddingNew = true // Trigger the add child form
                        }
                        .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.4)) // Background color for button row
                    }
                    .onAppear {
                        // Fetch children and parent data when the view appears
                        Task {
                            do {
                                try viewModel.getChildren() // Get children from Firestore
                                try viewModel.fetchParent() // Get parent data from Firestore
                            } catch {
                                print(error.localizedDescription) // Print any errors
                            }
                        }
                    }
                    .onChange(of: reload) { _ in
                        // Refresh child and parent data if the reload state changes
                        Task {
                            do {
                                try viewModel.getChildren() // Fetch children again
                                try viewModel.fetchParent() // Fetch parent data again
                            } catch {
                                print(error.localizedDescription) // Print any errors
                            }
                        }
                    }
                    .scrollContentBackground(.hidden) // Hide the background for the scroll view
                }
                // Sheet for adding a new child
                .sheet(isPresented: $isAddingNew, onDismiss: {
                    // Refresh children list after the sheet is dismissed
                    Task {
                        do {
                            try viewModel.getChildren() // Fetch children again
                        } catch {
                            print(error.localizedDescription) // Print any errors
                        }
                    }
                }) {
                    AddChildForm(isCompact: isCompact) // Present the AddChildForm
                }
                // Sheet for parent settings
                .sheet(isPresented: $isShowingSetting, onDismiss: {
                    do {
                       
                        try viewModel.fetchParent()
                        
                    } catch {
                        
                    }
                }) {
                    if isCompact {
                        parentSettingsiPhone(showSigninView: $showSigninView)
                    } else {
                        parentSettings(showSigninView: $showSigninView) // Present the settings view
                    }
                }
                .onAppear {
                    
                    // Check the horizontal size class and set the isCompact state
                    if horizontalSizeClass == .compact {
                        isCompact = true // Set isCompact to true for compact layouts
                    }
                }
            }
            .navigationTitle("Hey, \(viewModel.parent?.name ?? "Children")") // Set navigation title
            .toolbar {
                // Toolbar button to open the profile settings
                Button("Profile", systemImage: "person.fill") {
                    isShowingSetting = true // Show settings when button is tapped
                }
            }
        }
    }
}

#Preview {
    // Preview setup for the ParentView
    ParentView(showSigninView: .constant(false), reload: .constant(false), isiPhone: .constant(false))
}
