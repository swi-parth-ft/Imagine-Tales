//
//  ParentView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/25/24.
//

import SwiftUI
import FirebaseFirestore

final class ParentViewModel: ObservableObject {
    
    @Published var children: [UserChildren] = []
    
    func logOut() throws {
        try AuthenticationManager.shared.SignOut()
    }
    
    func getChildren() throws {
       
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
       
        
        Firestore.firestore().collection("Children2").whereField("parentId", isEqualTo: authDataResult.uid).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.children = querySnapshot?.documents.compactMap { document in
                try? document.data(as: UserChildren.self)
            } ?? []
            print(self.children)
            
        }
    }
    
}

struct ParentView: View {
    @StateObject var viewModel = ParentViewModel()
    @Binding var showSigninView: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach(viewModel.children) { child in
//                            NavigationLink(destination: ChildView(child: child)) {
                                Text(child.name)
                          //  }
                        }
                        
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.logOut()
                                    showSigninView = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Children")
            .onAppear {
                Task {
                    do {
                        try viewModel.getChildren()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        
    }
}

#Preview {
    ParentView(showSigninView: .constant(false))
}
