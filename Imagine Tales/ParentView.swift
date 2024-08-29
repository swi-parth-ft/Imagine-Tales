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
    @Published var story: [Story] = []
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var parent: UserModel?
    @Published var username: String = ""
    
    
    func deleteStory(storyId: String) {
        Firestore.firestore().collection("Story").document(storyId).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
        }
        else {
          print("Document successfully removed!")
        }
      }
    }
    
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
    
    func getStory(childId: String) throws {
       
        Firestore.firestore().collection("Story").whereField("childId", isEqualTo: childId).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.story = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Story.self)
            } ?? []
            print(self.story)
            
        }
    }
    
    func fetchParent() throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let docRef = Firestore.firestore().collection("users").document(authDataResult.uid)
        
        
        docRef.getDocument(as: UserModel.self) { result in
                switch result {
                case .success(let document):
                    self.parent = document
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
        }
    func addChild() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        let _ = try await UserManager.shared.addChild(userId: authDataResult.uid, name: name, age: age)
        let _ = try await UserManager.shared.addChild2(userId: authDataResult.uid, name: name, age: age, username: username)
    }
    
    func reviewStory(status: String, id: String) throws {
      
        Firestore.firestore().collection("Story").document(id).updateData(["status": status])
    }
    
}

struct ParentView: View {
    @StateObject var viewModel = ParentViewModel()
    @Binding var showSigninView: Bool
    @State private var isAddingNew = false
    @State private var isShowingSetting = false
    @Binding var reload: Bool
    @Binding var isiPhone: Bool
    @AppStorage("ipf") private var ipf: Bool = true
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        
                        ForEach(viewModel.children) { child in
                            NavigationLink(destination: ChildView(isiPhone: $isiPhone, child: child)) {
                                Text(child.name)
                          }
                        }
                        Button("Add Child") {
                            isAddingNew = true
                        }
                        
                    
                        
                        
                    }
                    .onAppear {
                        Task {
                            do {
                                try viewModel.getChildren()
                                try viewModel.fetchParent()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .onChange(of: reload) {
                        Task {
                            do {
                                try viewModel.getChildren()
                                try viewModel.fetchParent()
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
            .navigationTitle("Hey, \(viewModel.parent?.name ?? "Children")")
            .toolbar {
                Button("Profile", systemImage: "person.fill") {
                    isShowingSetting = true
                }
            }
            
        }
        
        
    }
}

#Preview {
    ParentView(showSigninView: .constant(false), reload: .constant(false), isiPhone: .constant(false))
}

struct ChildView: View {
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = true
    @Binding var isiPhone: Bool
    
    var child: UserChildren
    @StateObject var viewModel = ParentViewModel()
    var body: some View {
        VStack {
            if !isiPhone {
                Button("back to \(child.name)'s playground") {
                    childId = child.id
                    ipf = false
                }
            }
            
            List {
                ForEach(viewModel.story, id: \.id) { story in
                    NavigationLink(destination: StoryView(story: story)) {
                        ZStack {
                            HStack {
                                VStack {
                                    Spacer()
                                    Text("\(story.title)")
                                }
                                Spacer()
                                Text(story.status == "Approve" ? "Approved" : (story.status == "Reject" ? "Rejected" : "Pending"))
                                    .foregroundStyle(story.status == "Approve" ? .green : (story.status == "Reject" ? .red : .blue))
                            }
                            
                        }
                  }
                }
                .onDelete { indexSet in
                                if let index = indexSet.first {
                                    let storyID = viewModel.story[index].id
                                    viewModel.deleteStory(storyId: storyID)
                                    
                                    do {
                                        try viewModel.getStory(childId: child.id)
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
            }
        }
        .onAppear {
            do {
                try viewModel.getStory(childId: child.id)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct StoryView: View {
    var story: Story
    @StateObject var viewModel = ParentViewModel()
    @State private var status = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(0..<story.storyText.count, id: \.self) { index in
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            AsyncImage(url: URL(string: story.storyText[index].image)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 500)
                                        .clipped()
                                        .cornerRadius(30)
                                        .padding()
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: 500)
                            .cornerRadius(10)
                        }
                        
                        Text(story.storyText[index].text)
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .padding()
                        
                        
                        
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle(story.title)
            .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                              
                                    Button("Approve") {
                                        do {
                                            try viewModel.reviewStory(status: "Approve", id: story.id)
                                            status = "Approve"
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    .foregroundStyle(status == "Approve" ? .gray : .green)
                                
                                Spacer()
                                Text(status == "Approve" ? "Approved" : (status == "Reject" ? "Rejected" : "Pending"))
                                    .foregroundStyle(status == "Approve" ? .green : (status == "Reject" ? .red : .blue ))
                                Spacer()
                                
                                Button("Reject") {
                                    do {
                                        try viewModel.reviewStory(status: "Reject", id: story.id)
                                        status = "Reject"
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                                .foregroundStyle(status == "Reject" ? .gray : .red)
                            }
                        }
            .onAppear {
                status = story.status
            }
            
        }
    }
    
}
struct AddChildForm: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ParentViewModel()
    
     var body: some View {
        VStack {
            TextField("Name", text: $viewModel.name)
            TextField("Age", text: $viewModel.age)
            TextField("username", text: $viewModel.username)
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
