//
//  FriendProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/3/24.
//

import SwiftUI
import FirebaseFirestore

final class FriendProfileViewModel: ObservableObject {
    @Published var child: UserChildren?
    @Published var numberOfFriends = 0
    @Published var story: [Story] = []
    @Published var profileImage = ""
    
    @Published var status = ""
    func getStory(childId: String) throws {
       
        Firestore.firestore().collection("Story").whereField("childId", isEqualTo: childId).whereField("status", isEqualTo: "Approve").getDocuments() { (querySnapshot, error) in
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
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
            switch result {
            case .success(let document):
                self.child = document
                self.profileImage = document.profileImage
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
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
    
    func removeFriend(childId: String, docID: String) {
        
        let db = Firestore.firestore()
        db.collection("Children2").document(childId).collection("friends").document(docID).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func sendFriendRequest(toChildId: String, fromChildId: String) {
            let db = Firestore.firestore()
            let friendRequestData: [String: Any] = [
                "fromUserId": fromChildId,
                "status": "pending"
            ]
            
        // Use toChildId as the document ID for the friend request
        let requestRef = db.collection("Children2").document(toChildId).collection("friendRequests").document(fromChildId)
            
            // Set the data for the friend request document
            requestRef.setData(friendRequestData) { error in
                if let error = error {
                    print("Error sending friend request: \(error.localizedDescription)")
                } else {
                    print("Friend request sent successfully!")
                }
            }
        }
    
    func checkFriendshipStatus(childId: String, friendChildId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Children2").document(childId)
        let friendRequestRef = db.collection("Children2").document(friendChildId).collection("friendRequests").document(childId)
          
          // Check if already friends
          userRef.collection("friends").document(friendChildId).getDocument { [weak self] (document, error) in
              if let document = document, document.exists {
                  self?.status = "Friends"
                  return
              }
              
              // Check for pending requests
              friendRequestRef.getDocument { [weak self] (document, error) in
                  if let document = document, document.exists  {
                      self?.status = "Pending"
                  } else {
                      self?.status = "Send Request"
                  }
              }
          }
      }
}
struct FriendProfileView: View {
    var friendId: String
    var dp: String
    @StateObject var viewModel = FriendProfileViewModel()
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    @State private var tiltAngle: Double = 0
    @StateObject var parentViewModel = ParentViewModel()
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
    @State private var isRemoved = false
    @Environment(\.dismiss) var dismiss
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
                                .frame(width: 250, height: 250)
                                
                            AsyncDp(urlString: dp, size: 200)
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
                                
                                
                                Text("@\(viewModel.child?.username ?? "N/A")")
                                    .font(.title)
                                
                                
                                
                                
                                Text("\(viewModel.numberOfFriends) Friends")
                                    .font(.title2)
                                Spacer()
                                if viewModel.status == "Friends" {
                                    
                                    
                                    if !isRemoved {
                                        Button("Remove", systemImage: "person.crop.circle.fill.badge.minus") {
                                            viewModel.removeFriend(childId: childId, docID: friendId)
                                            viewModel.removeFriend(childId: friendId, docID: childId)
                                            isRemoved = true
                                            
                                        }
                                        .foregroundStyle(.black)
                                    }
                                }
                                
                                if viewModel.status != "Friends" && viewModel.status != "Pending" {
                                    Button("Add Friend") {
                                        
                                        viewModel.sendFriendRequest(toChildId: friendId, fromChildId: childId)
                                        
                                    }
                                    .foregroundStyle(.black)
                                }
                                
                                if viewModel.status == "Pending" {
                                    Text("Request Sent.")
                                        .foregroundStyle(.black)
                                }
                            }
                            Spacer()
                            VStack {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.white)
                                        .frame(width: 75, height: 75)
                                        .shadow(radius: 10)
                                    
                                    Image("arrow1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 55)
                                }
                                .onTapGesture {
                                    dismiss()
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    .frame(height: 250)
                    .padding(.leading)
                    
                    List {
                        Section("\(viewModel.child?.name ?? "")'s Stories") {
                            ForEach(viewModel.story, id: \.id) { story in
                                NavigationLink(destination: StoryFromProfileView(story: story)) {
                                    
                                    
                                        VStack {
                                            Spacer()
                                            Text("\(story.title)")
                                        }
                                     
                                    
                                }
                                .listRowBackground(Color.white.opacity(0.5))
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        do {
                            viewModel.fetchChild(ChildId: friendId)
                            try viewModel.getStory(childId: friendId)
                            viewModel.getFriendsCount(childId: friendId)
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                   
                    
                }
                .padding([.trailing, .leading])
                .padding(.bottom, 50)
                .onAppear {
                    viewModel.fetchChild(ChildId: friendId)
                }
     
                
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("\(viewModel.child?.name ?? "N/A")")
            .onAppear {
               
                viewModel.fetchChild(ChildId: friendId)
                viewModel.getFriendsCount(childId: friendId)
                viewModel.checkFriendshipStatus(childId: childId, friendChildId: friendId)
            }
        }
    }
}

#Preview {
    FriendProfileView(friendId: "3n5X2ipZdgBb0x8BAHOn", dp: "dp1.jpg")
}
