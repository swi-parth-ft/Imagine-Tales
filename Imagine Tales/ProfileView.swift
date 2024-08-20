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
    @Binding var selectedChild: UserChildren
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.purple, .black, .black], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                VStack {
                    List {
                        Text(viewModel.user?.email ?? "N/A")
                            .listRowBackground(Color.white.opacity(0.5))
                        
                        Text(selectedChild.name)
                            .listRowBackground(Color.white.opacity(0.5))
                        
                        Text(selectedChild.id)
                            .listRowBackground(Color.white.opacity(0.5))
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.logOut()
                                    showSignInView = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.5))
                    }
                    .onAppear {
                        try? viewModel.loadUser()
                    }
                    .scrollContentBackground(.hidden)
                }
                .padding([.trailing, .leading])
                .navigationTitle("Profile")
            }
        }
     
        
            
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false), selectedChild: .constant(UserChildren(id: "", parentId: "", name: "", age: "", dateCreated: Date.now)))
        .preferredColorScheme(.dark)
}
