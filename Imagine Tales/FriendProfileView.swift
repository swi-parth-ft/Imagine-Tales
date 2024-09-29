//
//  FriendProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/3/24.
//

import SwiftUI
import FirebaseFirestore
import Drops

final class FriendProfileViewModel: ObservableObject {
    @Published var child: UserChildren?
    @Published var numberOfFriends = 0
    @Published var story: [Story] = []
    @Published var profileImage = ""
    @Published var isFriendRequest = false
    
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
    
    func checkFriendRequest(childId: String, friendId: String) {
            // Assuming currentUserId is the user's ID whose friend requests you are checking
            let db = Firestore.firestore()
            let docRef = db.collection("Children2")
            .document(childId)
                .collection("friendRequests")
                .document(friendId)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Document exists
                    self.isFriendRequest = true
                } else {
                    // Document does not exist
                    self.isFriendRequest = false
                }
            }
        }
}
struct FriendProfileView: View {
    var friendId: String
    var dp: String
    @StateObject var viewModel = FriendProfileViewModel()
    @StateObject var friendViewModel = FriendsViewModel()
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    @State private var tiltAngle: Double = 0
    @StateObject var parentViewModel = ParentViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    
    @State private var isRemoved = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white)
                                .frame(width: 250, height: 250)
                                
                            Image(dp.removeJPGExtension())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .cornerRadius(100)
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
                                if childId != friendId {
                                    if viewModel.isFriendRequest {
                                        HStack {
                                            // Button to accept the friend request
                                            Button(action: {
                                                var requestId = ""
                                                if let request = friendViewModel.friendRequests.first(where: { $0.fromUserId == friendId }) {
                                                    requestId = request.requestId
                                                    print("Request ID: \(requestId)")
                                                } else {
                                                    print("No request found for the given user ID.")
                                                }
                                                friendViewModel.respondToFriendRequest(childId: childId, requestId: requestId, response: "accepted", friendUserId: friendId)
                                                friendViewModel.deleteRequest(childId: childId, docID: friendId)
                                                let drop = Drop(title: "You're now friends!", icon: UIImage(systemName: "figure.2.left.holdinghands"))
                                                Drops.show(drop)
                                                viewModel.checkFriendRequest(childId: childId, friendId: friendId)
                                                viewModel.status = "Friends"
                                                
                                            }) {
                                                Text("Accept")
                                                 
                                            }
                                            Button(action: {
                                                var requestId = ""
                                                if let request = friendViewModel.friendRequests.first(where: { $0.fromUserId == friendId }) {
                                                    requestId = request.requestId
                                                    print("Request ID: \(requestId)")
                                                } else {
                                                    print("No request found for the given user ID.")
                                                }
                                                friendViewModel.respondToFriendRequest(childId: childId, requestId: requestId, response: "denied", friendUserId: friendId)
                                                friendViewModel.deleteRequest(childId: childId, docID: friendId)
                                                let drop = Drop(title: "Request Denied!", icon: UIImage(systemName: "person.fill.xmark"))
                                                Drops.show(drop)
                                                viewModel.checkFriendRequest(childId: childId, friendId: friendId)
                                            }) {
                                                Text("Deny")
                                            }
                                        }
                                    } else {
                                        if viewModel.status == "Friends" {
                                            if !isRemoved {
                                                Button("Remove", systemImage: "person.crop.circle.fill.badge.minus") {
                                                    viewModel.removeFriend(childId: childId, docID: friendId)
                                                    viewModel.removeFriend(childId: friendId, docID: childId)
                                                    viewModel.checkFriendshipStatus(childId: childId, friendChildId: friendId)
                                                    isRemoved = true
                                                    let drop = Drop(title: "Removed Friend", icon: UIImage(systemName: "person.crop.circle.fill.badge.minus"))
                                                    Drops.show(drop)
                                                    
                                                }
                                                .foregroundStyle(.primary)
                                            }
                                        }
                                        
                                        if viewModel.status != "Friends" && viewModel.status != "Pending" {
                                            Button("Add Friend") {
                                                
                                                viewModel.sendFriendRequest(toChildId: friendId, fromChildId: childId)
                                                viewModel.checkFriendshipStatus(childId: childId, friendChildId: friendId)
                                                let drop = Drop(title: "Friend request sent.", icon: UIImage(systemName: "plus"))
                                                Drops.show(drop)
                                            }
                                            .foregroundStyle(.primary)
                                        }
                                        
                                        if viewModel.status == "Pending" {
                                            Text("Request Sent.")
                                                .foregroundStyle(.primary)
                                        }
                                    }
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
                            if viewModel.story.isEmpty {
                                ContentUnavailableView {
                                    Label("No Stories Yet", systemImage: "book.fill")
                                } description: {
                                    Text("It looks like there's no stories posted yet.")
                                } actions: {
                                }
                                .listRowBackground(Color.clear)
                            }
                            ForEach(viewModel.story, id: \.id) { story in
                                NavigationLink(destination: StoryFromProfileView(story: story)) {
                                    ZStack {
                                        HStack {
                                            Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")1")
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(0.3)
                                                .frame(width: 300, height: 300)
                                            Spacer()
                                            Image("\(story.theme?.filter { !$0.isWhitespace } ?? "")2")
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(0.5)
                                                .frame(width: 70, height: 70)
                                            Spacer()
                                        }
                                        .frame(height: 100)
                                        HStack {
                                            VStack {
                                                
                                                Text("\(story.title)")
                                                    .font(.custom("ComicNeue-Bold", size: 32))
                                                    .padding([.leading, .bottom])
                                                
                                                
                                            }
                                            Spacer()
                                            
                                           
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .padding(.vertical)
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4)) // Background for story item
                                        .cornerRadius(22) // Rounded corners for story item
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 0)
                                        .contentShape(Rectangle()) // Expand tappable area
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.white.opacity(0)) // Transparent row background
                                    .listRowSeparator(.hidden) // Hide row separator
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        do {
                            viewModel.fetchChild(ChildId: friendId)
                            try viewModel.getStory(childId: friendId)
                            viewModel.getFriendsCount(childId: friendId)
                            viewModel.checkFriendRequest(childId: childId, friendId: friendId)
                            
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
                friendViewModel.fetchFriendRequests(childId: childId) // Fetch friend requests when the view appears
            }
        }
    }
}

#Preview {
    FriendProfileView(friendId: "3n5X2ipZdgBb0x8BAHOn", dp: "dp1.jpg")
}
