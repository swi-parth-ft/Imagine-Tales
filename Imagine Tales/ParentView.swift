//
//  ParentView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/25/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

final class ParentViewModel: ObservableObject {
    
    @Published var children: [UserChildren] = []
    @Published var story: [Story] = []
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var parent: UserModel?
    @Published var username: String = ""
    @AppStorage("dpurl") private var dpUrl = ""
    var childId = ""
    @Published var numberOfFriends = 0
    @Published var imageUrl = ""
    
    func getFriendsCount(childId: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Children2").document(childId).collection("friends")
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let documentCount = querySnapshot?.count ?? 0
                print("Number of documents: \(documentCount)")
                self.numberOfFriends = documentCount
            }
        }
    }
    
    func deleteChild(at offsets: IndexSet) {
        offsets.forEach { index in
            let childToDelete = children[index]
            if let indexToRemove = children.firstIndex(where: { $0.id == childToDelete.id }) {
                deleteChildFromFirebase(child: children[indexToRemove])
                do {
                    try getChildren()
                } catch {
                        print(error.localizedDescription)
                    }
                    
            }
        }
    }
    
    func deleteChildFromFirebase(child: UserChildren) {
        Firestore.firestore().collection("Children2").document(child.id).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
        }
        else {
          print("Document successfully removed!")
        }
      }
    }
    
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
        let _ = try await UserManager.shared.addChild2(userId: authDataResult.uid, name: name, age: age, username: username, imageUrl: imageUrl)
    }
    
    func reviewStory(status: String, id: String) throws {
      
        Firestore.firestore().collection("Story").document(id).updateData(["status": status])
    }
    
    func fetchProfileImage(dp: String) {
        
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // Assuming the profilePicture field contains "1.jpg", "2.jpg", etc.
            let imageRef = storageRef.child("profileImages/\(dp)")
            
            // Fetch the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching image URL: \(error)")
                    return
                }
                if let url = url {
                    self.dpUrl = url.absoluteString
                   
                }
            }
        
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
    let bookBackgroundColors: [Color] = [
        Color(red: 255/255, green: 235/255, blue: 190/255),  // More vivid Beige
        Color(red: 220/255, green: 220/255, blue: 220/255),  // More vivid Light Gray
        Color(red: 255/255, green: 230/255, blue: 240/255),  // More vivid Lavender Blush
        Color(red: 255/255, green: 255/255, blue: 245/255),  // More vivid Mint Cream
        Color(red: 230/255, green: 255/255, blue: 230/255),  // More vivid Honeydew
        Color(red: 230/255, green: 248/255, blue: 255/255),  // More vivid Alice Blue
        Color(red: 255/255, green: 250/255, blue: 230/255),  // More vivid Seashell
        Color(red: 255/255, green: 250/255, blue: 215/255),  // More vivid Old Lace
        Color(red: 255/255, green: 250/255, blue: 200/255)   // More vivid Cornsilk
    ]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isCompact = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: bookBackgroundColors
                ).ignoresSafeArea()
                VStack {
                    List {
                        
                        ForEach(viewModel.children) { child in
                            NavigationLink(destination: ChildView(isiPhone: $isiPhone, child: child)) {
                                HStack {
                                    AsyncDp(urlString: child.profileImage, size: 50)
                                    Text(child.name)
                                    Spacer()
                                }
                          }
                        .listRowBackground(Color.white.opacity(0.4))
                        
                        }
                        .onDelete(perform: viewModel.deleteChild)
                        Button("Add Child") {
                            isAddingNew = true
                        }
                        .listRowBackground(Color.white.opacity(0.4))

                        
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
                    .scrollContentBackground(.hidden)
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
                    AddChildForm(isCompact: isCompact)
                }
                .sheet(isPresented: $isShowingSetting) {
                    parentSettings(showSigninView: $showSigninView)
                }
                .onAppear {
                    if horizontalSizeClass == .compact {
                        isCompact = true
                    }
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

struct ChildView: View {
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = true
    @AppStorage("dpurl") private var dpUrl = ""
    @Binding var isiPhone: Bool
    let bookBackgroundColors: [Color] = [
        Color(red: 255/255, green: 235/255, blue: 190/255),  // More vivid Beige
        Color(red: 220/255, green: 220/255, blue: 220/255),  // More vivid Light Gray
        Color(red: 255/255, green: 230/255, blue: 240/255),  // More vivid Lavender Blush
        Color(red: 255/255, green: 255/255, blue: 245/255),  // More vivid Mint Cream
        Color(red: 230/255, green: 255/255, blue: 230/255),  // More vivid Honeydew
        Color(red: 230/255, green: 248/255, blue: 255/255),  // More vivid Alice Blue
        Color(red: 255/255, green: 250/255, blue: 230/255),  // More vivid Seashell
        Color(red: 255/255, green: 250/255, blue: 215/255),  // More vivid Old Lace
        Color(red: 255/255, green: 250/255, blue: 200/255)   // More vivid Cornsilk
    ]
    var child: UserChildren
    @StateObject var viewModel = ParentViewModel()
    @Environment(\.dismiss) var dismiss
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    @State private var tiltAngle: Double = 0
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: bookBackgroundColors
                ).ignoresSafeArea()
                VStack {
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: isiPhone ? 250 / 2 : 250)
                            
                            AsyncDp(urlString: child.profileImage, size: isiPhone ? 100 : 200)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                            
                            
                        }
                        .onPressingChanged { point in
                            if let point {
                                self.origin = point
                                self.counter += 1
                            }
                        }
                        .modifier(RippleEffect(at: self.origin, trigger: self.counter))
                        .shadow(radius: 3, y: 2)
                        .rotation3DEffect(
                            .degrees(tiltAngle),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                tiltAngle = 10 // Adjust this value to control the tilt range
                            }
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                
                                
                                Text("@\(child.username)")
                                    .font(.title)
                                
                                Text("\(viewModel.numberOfFriends) Friends")
                                Text("\(viewModel.story.count) Stories Posted")
                                Spacer()
                                if !isiPhone {
                                    Button("Go to \(child.name)'s Playground! 🪄") {
                                        childId = child.id
                                        ipf = false
                                        viewModel.fetchProfileImage(dp: child.profileImage)
                                        screenTimeViewModel.startScreenTime(for: childId)
                                        dismiss()
                                    }
                                    .font(.title)
                                    .foregroundStyle(.black)
                                }
                            }
                            Spacer()
                            
                        }
                        .padding()
                        Spacer()
                    }
                    .frame(height: isiPhone ? 250 / 2 : 250)
                    .padding(.leading)
                    
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
                            .listRowBackground(Color.white.opacity(0.4))
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
                    .scrollContentBackground(.hidden)
                }
                .onAppear {
                    do {
                        try viewModel.getStory(childId: child.id)
                    } catch {
                        print(error.localizedDescription)
                    }
                    viewModel.getFriendsCount(childId: child.id)
                }
            }
            .navigationTitle(child.name)
        }
    }
}

struct StoryView: View {
    var story: Story
    @StateObject var viewModel = ParentViewModel()
    @State private var status = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh()
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
                                            .frame(height: 300)
                                            .clipped()
                                            .cornerRadius(30)
                                            
                                    case .failure(_):
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: 300)
                                .cornerRadius(10)
                            }
                            
                            Text(story.storyText[index].text)
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
    
}

struct AddChildForm: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ParentViewModel()
    @State private var isSelectingImage = false
    @State private var selectedImageName = ""
    var isCompact: Bool
     var body: some View {
         ZStack {
             BackGroundMesh()
             VStack {
                 VStack {
                     ZStack {
                         Circle()
                             .fill(Color.white)
                             .frame(width: 250, height: 250)
                         
                         if selectedImageName == "" {
                             Image(systemName: "plus.circle.fill")
                                 .font(.system(size: 200))
                                 .foregroundStyle(.gray.opacity(0.4))
                                 .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                         } else {
                             Image(selectedImageName)
                                 .resizable()
                                 .scaledToFill()
                                 .frame(width: 200, height: 200)
                                 .clipShape(Circle())
                                 .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                              
                             
                         }
                         
                     }
                     .onTapGesture {
                         isSelectingImage = true
                     }
                     .padding()
                     
                     VStack {
                         TextField("Name", text: $viewModel.name)
                             .padding()
                             .background(.white.opacity(0.4))
                         TextField("Age", text: $viewModel.age)
                             .padding()
                             .background(.white.opacity(0.4))
                         TextField("username", text: $viewModel.username)
                             .padding()
                             .background(.white.opacity(0.4))
                     }
                 }
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
                 .frame(width:  UIScreen.main.bounds.width * 0.5, height: 55)
                 .background(Color(hex: "#FF6F61"))
                 .foregroundStyle(.white)
                 .cornerRadius(12)
                 
             }
             .padding()
             .sheet(isPresented: $isSelectingImage, onDismiss: {
                 viewModel.imageUrl = "\(selectedImageName).jpg"
                 
             }) {
                 DpSelection(selectedImageName: $selectedImageName, isCompact: isCompact)
             }
         }
    }
}

struct parentSettings: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ParentViewModel()
    @Binding var showSigninView: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh()
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
            .navigationTitle("Settings")
        }
    }
}

struct DpSelection: View {
    @Binding var selectedImageName: String
    let images: [String] = ["dp2", "dp1", "dp3", "dp4", "dp5", "dp6", "dp7", "dp8", "dp9", "dp10", "dp11", "dp12" ] // Use image names as an array of strings
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    @Environment(\.dismiss) var dismiss
    
    var isCompact: Bool
    
    var body: some View {
       
            ZStack {
               
                VisualEffectBlur(blurStyle: .systemThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                VStack(alignment: .leading) {
                    Text("Select Profile Image")
                        .font(.title)
                        .padding([.leading, .top])
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            
                            ForEach(images, id: \.self) { image in
                                VStack {
                                    
                                    ZStack {
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: isCompact ? 170 / 2 : 170)
                                        Image(image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: isCompact ? 150 / 2 : 150)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                        
                                        
                                            .scaleEffect(image == selectedImageName ? 1.1 : 1)
                                        
                                        VStack {
                                            
                                            if image == selectedImageName {
                                                Button("Set", systemImage: "checkmark.circle.fill") {
                                                        dismiss()
                                                }
                                                .padding()
                                                .background(Color.white.opacity(0.9))
                                                .foregroundStyle(.black)
                                                .cornerRadius(22)
                                            }
                                            
                                        }
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        selectedImageName = image
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                }
                
            

        }
    }
}

#Preview {
    ParentView(showSigninView: .constant(false), reload: .constant(false), isiPhone: .constant(false))
}
