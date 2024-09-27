//
//  parentSettings.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// View for the parent settings, including options for logging out
struct parentSettings: View {
    
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view
    @StateObject var viewModel = ParentViewModel() // State object for managing parent-related data
    @Binding var showSigninView: Bool // Binding to control the visibility of the sign-in view
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Custom background for the view
                VStack {
                    List {
                        // Button to log out the parent
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.logOut() // Attempt to log out
                                    showSigninView = true // Set binding to show sign-in view
                                    dismiss() // Dismiss the settings view
                                } catch {
                                    // Print error if logout fails
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings") // Set the navigation title
        }
    }
}
