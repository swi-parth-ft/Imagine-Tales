//
//  parentSettings.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import Drops
import FirebaseAuth
// View for the parent settings, including options for logging out
struct parentSettingsiPhone: View {
    
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
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var reAuthModel = ReAuthentication()
    @State private var reAuthed = false
    @State private var isDeletingAccount = false
    @State private var isDeletingWithEmail = false
    @EnvironmentObject var appState: AppState
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                    .cornerRadius(12)
                    
                    if reAuthModel.signedInWithEmail {
                        if !isResettingPassword {
                            Button {
                                withAnimation {
                                    isResettingPassword.toggle()
                                }
                            } label: {
                                Text("Reset Passowrd")
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                    .cornerRadius(12)
                            }
                        } else {
                            
                            TextField("Enter your email", text: $enteredEmail)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.9)
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
                                        .frame(width: UIScreen.main.bounds.width * 0.5)
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
                                        .frame(width: UIScreen.main.bounds.width * 0.3)
                                        .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                        .foregroundStyle(.red)
                                        .cornerRadius(12)
                                }
                            }
                            
                            
                            
                            
                            
                        }
                    }
                    if reAuthModel.signedInWithApple && !reAuthModel.isLinkedWithGoogle {
                        Button {
                            Task {
                                do {
                                    try await reAuthModel.linkWithGoogle()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                         } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(colorScheme == .dark ? .gray : .white)
                                    .frame(width: 250, height: 55)
                                HStack {
                                    Image("googleIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                    Text("Link Account with Google")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                            }
                        }
                    }
                    
                    if reAuthModel.isLinkedWithGoogle {
                        Button {
                            Task {
                                do {
                                    try await reAuthModel.unlinkGoogleAccount()
                                } catch {
                                    
                                }
                            }
                        } label: {
                            Text("Unlink google account")
                        }
                    }
                    Spacer()
                    // Button to log out the parent
                    Button {
                        Task {
                            do {
                                viewModel.removeFCMTokenParent(parentId: viewModel.parent?.userId ?? "")
                                try viewModel.logOut() // Attempt to log out
                                showSigninView = true // Set binding to show sign-in view
                                appState.isPremium = false
                                dismiss() // Dismiss the settings view
                            } catch {
                                // Print error if logout fails
                                print(error.localizedDescription)
                            }
                        }
                    } label: {
                        Text("Log Out")
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .foregroundStyle(.red)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        if reAuthModel.signedInWithEmail {
                            isDeletingWithEmail.toggle()
                        } else {
                            isDeletingAccount.toggle()
                        }
                    } label: {
                        Text("Delete Account")
                            .foregroundStyle(.red)
                            
                    }
                    .alert("Delete Account", isPresented: $isDeletingAccount) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            reAuthModel.deleteAccount { error in
                                if let error = error {
                                    print("Error deleting account: \(error.localizedDescription)")
                                    Drops.show("Something went wrong, Try again!.")
                                } else {
                                    print("Account deleted successfully.")
                                    showSigninView = true // Set binding to show sign-in view
                                    dismiss() // Dismiss the settings view
                                    Drops.show("Account deleted successfully.")
                                }
                            }
                        }
                    } message: {
                        Text("Are you sure you want to delete your account and all associated data? This action cannot be undone.")
                    }
                    
                    
                }
                .padding()
                .onAppear {
                    reAuthModel.checkIfGoogle()
                    do {
                        try viewModel.fetchParent()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .sheet(isPresented: $isDeletingWithEmail, onDismiss: {
                    dismiss()
                }) {
                    DeleteWithEmailiPhone(showSigninView: $showSigninView)
                }
            }
            .navigationTitle("Settings") // Set the navigation title
        }
    }
}
