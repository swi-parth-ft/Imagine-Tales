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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Custom background for the view
                VStack {
                    HStack {
                        if !isEditingName {
                            Text(viewModel.parent?.name ?? "Loading...")
                            Spacer()
                            Button {
                                withAnimation {
                                    isEditingName.toggle()
                                }
                            } label: {
                                Image(systemName: "pencil.line")
                            }
                        } else {
                            TextField("\(viewModel.parent?.name ?? "Loading...")", text: $newName)
                            HStack {
                                Button {
                                    viewModel.updateNameInFirestore(userId: viewModel.parent?.userId ?? "", newName: newName) { result in
                                        switch result {
                                        case .success:
                                            print("Name updated successfully.")
                                            Drops.show("Name updated successfully.")
                                            withAnimation {
                                                isEditingName.toggle()
                                            }
                                            do {
                                                try viewModel.fetchParent()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        case .failure(let error):
                                            print("Error updating name: \(error.localizedDescription)")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                }
                                
                                Button {
                                    withAnimation {
                                        isEditingName.toggle()
                                    }
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 22))
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                    .cornerRadius(12)
                    
                    
                    if !isResettingPassword {
                        Button {
                            withAnimation {
                                isResettingPassword.toggle()
                            }
                        } label: {
                            Text("Reset Passowrd")
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                .cornerRadius(12)
                        }
                        
                    } else {
                        
                        TextField("Enter your email", text: $enteredEmail)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .cornerRadius(12)
                        
                        HStack {
                            Button {
                                let parentEmail = viewModel.parent?.email?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                let enteredEmailTrimmed = enteredEmail.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                if enteredEmailTrimmed == parentEmail {
                                    Task {
                                        do {
                                            try await reset()
                                            Drops.show("Check your email for a reset link")
                                            withAnimation {
                                                isResettingPassword.toggle()
                                            }
                                        } catch {
                                            // Handle error
                                        }
                                    }
                                } else {
                                    if !enteredEmail.isEmpty {
                                        Drops.show("Please enter a valid email.")
                                    } else {
                                        Drops.show("Please enter a your email.")
                                    }
                                }
                                
                                
                                
                            } label: {
                                Text("Reset Password")
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.3)
                                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                    .cornerRadius(12)
                                
                            }
                            
                            Button {
                                withAnimation {
                                    isResettingPassword.toggle()
                                }
                            } label: {
                                Text("Cancel")
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.17)
                                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                    .foregroundStyle(.red)
                                    .cornerRadius(12)
                            }
                        }
                        
                       
                        
                        
                        
                    }
                
                    
                    // Button to log out the parent
                    Button {
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
                    } label: {
                        Text("Log Out")
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .foregroundStyle(.red)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
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
