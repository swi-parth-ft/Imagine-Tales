//
//  parentSettings.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import Drops

// View for the parent settings, including options for logging out
struct parentSettings: View {
    
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view
    @StateObject var viewModel = ParentViewModel() // State object for managing parent-related data
    @Binding var showSigninView: Bool // Binding to control the visibility of the sign-in view
    @StateObject var AuthviewModel = SignInWithEmailViewModel()
    @State private var isResettingPassword = false
    @State private var enteredEmail = ""
    @State private var isEditingName = false
    @State private var newName = ""
    func reset() async throws {
        try await AuthenticationManager.shared.resetPassword(email: enteredEmail.lowercased())
    }
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Custom background for the view
                VStack {
                    List {
                        HStack {
                            if !isEditingName {
                                Text(viewModel.parent?.name ?? "Loading...")
                                Spacer()
                                Button("Edit") {
                                    isEditingName.toggle()
                                }
                            } else {
                                TextField("", text: $newName)
                                Button("Save") {
                                    viewModel.updateNameInFirestore(userId: viewModel.parent?.userId ?? "", newName: newName) { result in
                                        switch result {
                                        case .success:
                                            print("Name updated successfully.")
                                            Drops.show("Name updated successfully.")
                                            isEditingName.toggle()
                                            do {
                                                try viewModel.fetchParent()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        case .failure(let error):
                                            print("Error updating name: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                        if !isResettingPassword {
                            Button("Reset password") {
                                isResettingPassword.toggle()
                            }
                        } else {
                            
                            TextField("Enter your email", text: $enteredEmail)
                            
                            
                            
                            if enteredEmail.lowercased() == viewModel.parent?.email {
                                Button("Reset") {
                                    Task {
                                        do {
                                            try await reset()
                                            Drops.show("Check your email for a reset link")
                                            isResettingPassword.toggle()
                                        } catch {
                                            
                                        }
                                        
                                    }
                                }
                            } else {
                                if !enteredEmail.isEmpty {
                                    Text("Invalid Email")
                                        .foregroundStyle(.red)
                                }
                                Button("Cancel") {
                                    isResettingPassword.toggle()
                                }
                            }
                        }
                    
                        
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
                .onAppear {
                    do {
                        try viewModel.fetchParent()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .navigationTitle("Settings") // Set the navigation title
        }
    }
}
