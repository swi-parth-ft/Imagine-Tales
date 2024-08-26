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
    @Binding var reload: Bool
    
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(hex: "#FFFFF1").ignoresSafeArea()
                VStack {
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
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.7)
                        .background(Color(hex: "#FF6F61"))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    
                    
                    
                }
                .padding([.trailing, .leading])
                .padding(.top, 100)
                .onChange(of: reload) { 
                    try? viewModel.loadUser()
                    viewModel.fetchChild(ChildId: childId)
                                }
                
                
            }
            .navigationTitle("Hey, \(viewModel.child?.name ?? "N/A")")
            .onAppear {
                try? viewModel.loadUser()
                viewModel.fetchChild(ChildId: childId)
            }
        }
        
     
        
            
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false), reload: .constant(false))

}
