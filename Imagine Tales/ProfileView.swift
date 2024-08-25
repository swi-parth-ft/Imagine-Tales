//
//  ProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FirebaseFirestore

final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AuthDataResultModel? = nil
    @Published var child: UserChildren?
    func loadUser() throws {
        user = try AuthenticationManager.shared.getAuthenticatedUser()
    }
    func logOut() throws {
        try AuthenticationManager.shared.SignOut()
    }
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    self.child = document
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
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
                        Text(viewModel.child?.name ?? "N/A")
                        Text(viewModel.child?.age ?? "N/A")
                        
                        
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
                        viewModel.fetchChild(ChildId: childId)
                    }
                   
                }
                .padding([.trailing, .leading])
                .padding(.top, 100)
                .navigationTitle("Profile")
            
            }
        
     
        
            
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))

}
