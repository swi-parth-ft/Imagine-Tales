//
//  DeleteWithEmail.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/8/24.
//

import SwiftUI
import Drops
import FirebaseAuth

struct DeleteWithEmail: View {
    @StateObject private var viewModel = ReAuthentication()
    @State private var isDeletingAccount: Bool = false
    @Binding var showSigninView: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            Text(viewModel.email)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(12)
            SecureField("Password", text: $viewModel.password)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(12)
            Button {
                
                isDeletingAccount.toggle()
                
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                    .cornerRadius(12)
                
            }
            
            .alert("Delete Account", isPresented: $isDeletingAccount) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount { error in
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
        .onAppear {
            if let user = Auth.auth().currentUser {
                viewModel.email = user.email!
              //  print("Current signed-in user's email: \(email ?? "No email available")")
            } else {
                print("No user is signed in.")
            }
        }
       
    }
}

struct DeleteWithEmailiPhone: View {
    @StateObject private var viewModel = ReAuthentication()
    @State private var isDeletingAccount: Bool = false
    @Binding var showSigninView: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            Text(viewModel.email)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(12)
            SecureField("Password", text: $viewModel.password)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(12)
            Button {
                
                isDeletingAccount.toggle()
                
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                    .cornerRadius(12)
                
            }
            
            .alert("Delete Account", isPresented: $isDeletingAccount) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount { error in
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
        .onAppear {
            if let user = Auth.auth().currentUser {
                viewModel.email = user.email!
              //  print("Current signed-in user's email: \(email ?? "No email available")")
            } else {
                print("No user is signed in.")
            }
        }
       
    }
}
