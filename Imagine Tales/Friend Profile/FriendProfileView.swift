//
//  FriendProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/3/24.
//

import SwiftUI
import FirebaseFirestore
import Drops


struct FriendProfileView: View {
    var friendId: String
    var dp: String
    @StateObject var viewModel = FriendProfileViewModel()
    @StateObject var friendViewModel = FriendsViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    @State private var tiltAngle: Double = 0
    @StateObject var parentViewModel = ParentViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    
    @State private var isRemoved = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @State private var retryCount = 0 // Count for retry attempts when loading images
    @State private var maxRetryAttempts = 3 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retries
    @State private var selectedStory: Story? // The currently selected story for navigation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var orientation: OrientationManager
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .center) {
                BackGroundMesh().ignoresSafeArea()
                ZStack {
                    ScrollView {
                        Spacer()
                            .frame(height: orientation.isLandscape ? UIScreen.main.bounds.height * 0.35 : UIScreen.main.bounds.height * 0.31)
                        Text("\(viewModel.child?.name ?? "Loading...")'s Stories (\(viewModel.storyCount))")
                            .font(.title2)
                        
                        if viewModel.story.isEmpty {
                            ContentUnavailableView {
                                Label("No Stories Yet", systemImage: "book.fill")
                            } description: {
                                Text("It looks like there's no stories posted yet.")
                            } actions: {
                            }
                            .listRowBackground(Color.clear)
                        }
                                LazyVGrid(columns: columns, spacing: 23) {
                                    
                                    
                                    ForEach(viewModel.story, id: \.id) { story in
                                        ZStack {
                                            // Load the story image asynchronously
                                            AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                                switch phase {
                                                case .empty:
                                                    MagicView()
                                                        .frame(width: UIScreen.main.bounds.width * 0.45, height: 500)
                                                    
                                                case .success(let image):
                                                    // Successfully loaded image
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: UIScreen.main.bounds.width * 0.45, height: 500)
                                                        .clipped()
                                                        .cornerRadius(16)
                                                    
                                                case .failure(_):
                                                    // Placeholder for failed load
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: UIScreen.main.bounds.width * 0.45, height: 500)
                                                        .cornerRadius(16)
                                                        .padding()
                                                        .onAppear {
                                                            // Retry loading logic
                                                            if retryCount < maxRetryAttempts {
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                                    retryCount += 1
                                                                }
                                                            }
                                                        }
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Add shadow to the image
                                            
                                            VStack {
                                                Spacer()
                                                
                                                ZStack {
//                                                    RoundedRectangle(cornerRadius: 0)
//                                                        .fill(Color.white.opacity(0.8))
//                                                        .frame(width: UIScreen.main.bounds.width * 0.43, height: 200)
//                                                        .cornerRadius(16)
                                                    
                                                    VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                        .frame(width: UIScreen.main.bounds.width * 0.43, height: 200)
                                                        .cornerRadius(16)
                                                    
                                                    VStack(spacing: 0) {
                                                        
                                                        Text(story.title.trimmingCharacters(in: .newlines))
                                                            .font(.system(size: 18))
                                                        
                                                        HStack {
                                                            Image(systemName: "heart.fill")
                                                                .foregroundStyle(.red)
                                                            Text("\(story.likes) Likes")
                                                                .padding(.trailing)
                                                            
                                                            Text(story.theme ?? "")
                                                                .padding(7)
                                                                .background(colorScheme == .dark ? Color(hex: "#4B8A1C") : .green)
                                                                .foregroundStyle(.white)
                                                                .cornerRadius(22)
                                                                
                                                        }
                                                        .font(.system(size: 16))
                                                        .padding(.top)
                                                        Button {
                                                            selectedStory = story
                                                        } label: {
                                                            HStack {
                                                                Text("Read Now")
                                                                Image(systemName: "book.pages")
                                                            }
                                                            .frame(width: UIScreen.main.bounds.width * 0.35)
                                                        }
                                                        .padding()
                                                        .font(.system(size: 16))
                                                        .background(Color(hex: "#FF6F61"))
                                                        .foregroundStyle(.white)
                                                        .cornerRadius(16)
                                                        .padding(.top)
                                                    }
                                                    .foregroundStyle(.primary)
                                                    
                                                }
                                                .padding(.bottom)
                                            }
                                        }
                                        
                                        if story == viewModel.story.last {
                                            ProgressView()
                                                .onAppear {
                                                    Task {
                                                        await viewModel.getStorie(isLoadMore: true, childId: friendId)
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding()
                            }
                    .fullScreenCover(item: $selectedStory) { story in
                            StoryFromProfileView(story: story)
                    }
                    .onAppear {
                        viewModel.getStoryCount(childId: friendId)
                        Task {
                            
                            await viewModel.getStorie(childId: friendId)
                        }
                
                            viewModel.fetchChild(ChildId: friendId)
                          //  try viewModel.getStory(childId: friendId)
                            viewModel.getFriendsCount(childId: friendId)
                            viewModel.checkFriendRequest(childId: childId, friendId: friendId)
                            
                       
                    }
                    VStack {
                        ZStack(alignment: .top) {
                            ZStack {
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .clipShape(RoundedCorners(radius: 50, corners: [.bottomLeft, .bottomRight]))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                         
                                
                                
                                HStack { // Landscape mode
                                    ProfileCircleView(dp: dp.removeJPGExtension())
                                    
                                    VStack {
                                        ProfileInfoView(viewModel: viewModel)
                                        
                                        if orientation.isLandscape {
                                            if childId != friendId {
                                                VStack {
                                                    
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
                                                                homeViewModel.sendRequestRespoceNotification(fromId: childId, toUserId: friendId, fromChildUsername: viewModel.currentChild?.username ?? "", fromChildProfilePic: viewModel.currentDp, status: "Accepted")
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
                                                                homeViewModel.sendRequestRespoceNotification(fromId: childId, toUserId: friendId, fromChildUsername: viewModel.currentChild?.username ?? "", fromChildProfilePic: viewModel.currentDp, status: "Rejected")
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
                                                            }
                                                        }
                                                        
                                                        if viewModel.status != "Friends" && viewModel.status != "Pending" {
                                                            Button("Add Friend") {
                                                                
                                                                viewModel.sendFriendRequest(toChildId: friendId, fromChildId: childId)
                                                                viewModel.checkFriendshipStatus(childId: childId, friendChildId: friendId)
                                                                let drop = Drop(title: "Friend request sent.", icon: UIImage(systemName: "plus"))
                                                                Drops.show(drop)
                                                            }
                                                        }
                                                        
                                                        if viewModel.status == "Pending" {
                                                            Text("Request Sent.")
                                                        }
                                                    }
                                                }
                                                
                                                
                                                .padding()
                                                .frame(width: UIScreen.main.bounds.width * 0.2)
                                                .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#FFFFF1"))
                                                .cornerRadius(23)
                                                .shadow(radius: 10)
                                            }
                                        }
                                    }
                                }
                                
                                .padding(.top)
                            }
                            .frame(height: !orientation.isLandscape ? UIScreen.main.bounds.height * 0.28 : UIScreen.main.bounds.height * 0.33)
                            ZStack {
                                if !orientation.isLandscape {
                                    VStack {
                                        Spacer()
                                        if childId != friendId {
                                            VStack {
                                                
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
                                                            homeViewModel.sendRequestRespoceNotification(fromId: childId, toUserId: friendId, fromChildUsername: viewModel.currentChild?.username ?? "", fromChildProfilePic: viewModel.currentDp, status: "Accepted")
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
                                                            homeViewModel.sendRequestRespoceNotification(fromId: childId, toUserId: friendId, fromChildUsername: viewModel.currentChild?.username ?? "", fromChildProfilePic: viewModel.currentDp, status: "Denied")
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
                                                        }
                                                    }
                                                    
                                                    if viewModel.status != "Friends" && viewModel.status != "Pending" {
                                                        Button("Add Friend") {
                                                            
                                                            viewModel.sendFriendRequest(toChildId: friendId, fromChildId: childId)
                                                            viewModel.checkFriendshipStatus(childId: childId, friendChildId: friendId)
                                                            let drop = Drop(title: "Friend request sent.", icon: UIImage(systemName: "plus"))
                                                            Drops.show(drop)
                                                        }
                                                    }
                                                    
                                                    if viewModel.status == "Pending" {
                                                        Text("Request Sent.")
                                                    }
                                                }
                                            }
                                            
                                            
                                            .padding()
                                            .frame(width: UIScreen.main.bounds.width * 0.3)
                                            .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#FFFFF1"))
                                            .cornerRadius(23)
                                            .shadow(radius: 10)
                                        }
                                        
                                    }
                                }
                            }
                            .frame(height: !orientation.isLandscape ? UIScreen.main.bounds.height * 0.30 : UIScreen.main.bounds.height * 0.35)
                        }
                        .padding(.bottom)
                        Spacer()
                    }
                    
                    
                }
                .onAppear {
                    viewModel.fetchChild(ChildId: friendId)
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(edges: .top)
            .onAppear {
               
                viewModel.fetchChild(ChildId: friendId)
                viewModel.getFriendsCount(childId: friendId)
                viewModel.checkFriendshipStatus(childId: childId, friendChildId: friendId)
                viewModel.fetchCurrentChild(ChildId: childId)
                friendViewModel.fetchFriendRequests(childId: childId) // Fetch friend requests when the view appears
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

struct ProfileCircleView: View {
    @State private var tiltAngle: Double = 0
    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0
    @Environment(\.colorScheme) var colorScheme
    var dp: String
    @State private var size: CGFloat = 200 * 0.8
    @State private var sizeCircle: CGFloat = 250 * 0.8
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white)
                    .frame(width: sizeCircle, height: sizeCircle)
                
                Image(dp.removeJPGExtension())
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
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
        }
     
    }
}

struct ProfileInfoView: View {
    @ObservedObject var viewModel: FriendProfileViewModel
    
    var body: some View {
        HStack {
            VStack {
                Text("\(viewModel.child?.name ?? "Loading...")")
                    .font(.title)
                
                Text("@\(viewModel.child?.username ?? "Loading...")")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("\(viewModel.numberOfFriends) Friends")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    FriendProfileView(friendId: "3n5X2ipZdgBb0x8BAHOn", dp: "dp1.jpg")
}
