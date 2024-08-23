//
//  ProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI

final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AuthDataResultModel? = nil
    
    func loadUser() throws {
        user = try AuthenticationManager.shared.getAuthenticatedUser()
    }
    func logOut() throws {
        try AuthenticationManager.shared.SignOut()
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        NavigationStack {
           
               
                VStack {
                    List {
                        Text(viewModel.user?.email ?? "N/A")
                        
                        Text(childId)
                        
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.logOut()
                                    childId = ""
                                    showSignInView = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                            }
                        }
                    }
                    .onAppear {
                        try? viewModel.loadUser()
                    }
                   
                }
                .padding([.trailing, .leading])
                .navigationTitle("Profile")
            }
        
     
        
            
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))

}
