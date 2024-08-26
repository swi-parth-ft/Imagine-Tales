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
    @Published var name: String = ""
    @Published var age: String = ""
    
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
    
    func addChild() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        let _ = try await UserManager.shared.addChild(userId: authDataResult.uid, name: name, age: age)
        let _ = try await UserManager.shared.addChild2(userId: authDataResult.uid, name: name, age: age)
    }
    
}

struct ParentView: View {
    @StateObject var viewModel = ParentViewModel()
    @Binding var showSigninView: Bool
    @State private var isAddingNew = false
    @State private var isShowingSetting = false
    @Binding var reload: Bool
    
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
                        Button("Add Child") {
                            isAddingNew = true
                        }
                        
                        
                    }
                    .onAppear {
                        Task {
                            do {
                                try viewModel.getChildren()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .onChange(of: reload) {
                        Task {
                            do {
                                try viewModel.getChildren()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                                    }
                }
                .sheet(isPresented: $isAddingNew, onDismiss: {
                    Task {
                        do {
                            try viewModel.getChildren()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }) {
                    AddChildForm()
                }
                .sheet(isPresented: $isShowingSetting) {
                    parentSettings(showSigninView: $showSigninView)
                }
                
            }
            .navigationTitle("Children")
            .toolbar {
                Button("Profile", systemImage: "person.fill") {
                    isShowingSetting = true
                }
            }
            
        }
        
        
    }
}

#Preview {
    ParentView(showSigninView: .constant(false), reload: .constant(false))
}


struct AddChildForm: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ParentViewModel()
    
     var body: some View {
        VStack {
            TextField("Name", text: $viewModel.name)
            TextField("Age", text: $viewModel.age)
            Button("Add Child") {
                Task {
                    do {
                        try await viewModel.addChild()
                        
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
               
            }
        }
    }
}

struct parentSettings: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ParentViewModel()
    @Binding var showSigninView: Bool
    
    var body: some View {
        VStack {
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.logOut()
                            showSigninView = true
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
