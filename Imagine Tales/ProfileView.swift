//
//  ProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI

final class ProfileViewModel: ObservableObject {
    
    func logOut() throws {
        try AuthenticationManager.shared.SignOut()
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.logOut()
                            showSignInView = true
                        } catch {
                            
                        }
                            
                    }
                }
            }
            .navigationTitle("Profile")
            
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))
}
