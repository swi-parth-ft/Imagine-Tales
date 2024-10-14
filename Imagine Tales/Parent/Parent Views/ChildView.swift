//
//  ChildView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import FirebaseAuth

// View for displaying child profile details and their associated stories
struct ChildView: View {
    @AppStorage("childId") var childId: String = "Default Value" // Persistently store the selected child's ID
    @AppStorage("ipf") private var ipf: Bool = true // Boolean to determine if the profile is viewed
    @AppStorage("dpurl") private var dpUrl = "" // Store URL for profile image
    @Binding var isiPhone: Bool // Binding to determine if the device is iPhone

    var child: UserChildren // Child user object
    @StateObject var viewModel = ParentViewModel() // State object for managing child-related data
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view
    @State var counter: Int = 0 // Counter for tap interactions
    @State var origin: CGPoint = .zero // Store the origin point of the tap
    @State private var tiltAngle: Double = 0 // Angle for 3D tilt effect
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager // Environment object for managing screen time
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingFriends = false
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var isShowingScreenTime = false
    @State private var isLandscape = UIDevice.current.orientation.isLandscape

    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea() // Custom background for the view
                ZStack(alignment: .center) {
                    List {
                        Spacer()
                            .frame(height: isiPhone ? 350 : 460)
                            .listRowBackground(Color.white.opacity(0))
                        if isShowingScreenTime {
                            // Show the screen time chart for the child
                            ScreenTimeChartView(selectedChildId: child.id)
                                .listRowBackground(Color.white.opacity(0)) // Transparent background for the chart
                        }
                        // List all the stories associated with the child
                        ForEach(viewModel.story, id: \.id) { story in
                            NavigationLink(destination: StoryView(story: story, child: child)) {
                                ZStack {
                                    HStack {
                                      
                                            Text("\(story.title.trimmingCharacters(in: .newlines))") // Display story title
                                        
                                        Spacer()
                                        // Show story status with color coding
                                        Text(story.status == "Approve" ? "Approved" : (story.status == "Reject" ? "Rejected" : "Pending"))
                                            .foregroundStyle(story.status == "Approve" ? .green : (story.status == "Reject" ? .red : .blue))
                                    }
                                }
                            }
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.4)) // Background for each story row
                        }
                        
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                let storyID = viewModel.story[index].id // Get story ID for deletion
                                viewModel.deleteStory(storyId: storyID) // Delete the story
                                
                                do {
                                    try viewModel.getStory(childId: child.id) // Refresh story list
                                } catch {
                                    print(error.localizedDescription) // Handle errors
                                }
                            }
                        }
                    }
                    .padding(.top, -20)
                    .scrollContentBackground(.hidden) // Hide default background of the list
                    VStack {
                        ZStack {
                            VStack {
                                ZStack {
                                    VisualEffectBlur(blurStyle: .systemThinMaterial)
                                        .clipShape(RoundedCorners(radius: 50, corners: [.bottomLeft, .bottomRight]))
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                    VStack {
                                        if isiPhone {
                                            Spacer()
                                        }
                                        HStack(alignment: .center) {
                                            Spacer()
                                            VStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : .white) // Background circle for profile image
                                                        .frame(width: isiPhone ? 250 / 2 : 250 * 0.8)
                                                    Image(child.profileImage.removeJPGExtension()) // Display profile image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: isiPhone ? 100 : 200 * 0.8)
                                                        .cornerRadius(isiPhone ? 50 : 100)
                                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                                }
                                                .onPressingChanged { point in // Detect tapping on the profile image
                                                    if let point {
                                                        self.origin = point // Capture tap location
                                                        self.counter += 1 // Increment counter on tap
                                                    }
                                                }
                                                .modifier(RippleEffect(at: self.origin, trigger: self.counter)) // Add ripple effect on tap
                                                .shadow(radius: 3, y: 2)
                                                .rotation3DEffect(
                                                    .degrees(tiltAngle), // 3D tilt effect
                                                    axis: (x: 0, y: 1, z: 0)
                                                )
                                                .onAppear {
                                                    withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                                        tiltAngle = 10 // Control the tilt range
                                                    }
                                                }
                                                
                                                if isiPhone {
                                                    Text("\(child.name)")
                                                        .font(.title)
                                                    
                                                    Text("@\(child.username)")
                                                        .font(.title2)
                                                        .foregroundStyle(.secondary)
                                                }
                                                
                                                
                                            }
                                            
                                            HStack {
                                                VStack {
                                                    if !isiPhone {
                                                        Text("\(child.name)")
                                                            .font(.title)
                                                        
                                                        Text("@\(child.username)")
                                                            .font(.title2)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    HStack {
                                                        // Display child's username and stats
                                                        VStack {
                                                            Text("\(viewModel.numberOfFriends)") // Friends count
                                                                .font(.system(size: 28))
                                                            Text("Friends")
                                                        }
                                                        .onTapGesture {
                                                            isShowingFriends.toggle()
                                                        }
                                                        .popover(isPresented: $isShowingFriends) {
                                                            List {
                                                                ForEach(friendsViewModel.children) { child in
                                                                    Text(child.name)
                                                                }
                                                            }
                                                            .scrollContentBackground(.hidden)
                                                            .frame(width: 200, height: 200)
                                                        }
                                                        Spacer()
                                                            .frame(width: !isiPhone ? 50 : 10)
                                                        VStack {
                                                            Text("\(viewModel.story.count)") // Stories count
                                                                .font(.system(size: 28))
                                                            Text("Stories Posted")
                                                        }
                                                    }
                                                    .padding()
                                                    
                                                }
                                            }
                                            .padding()
                                            Spacer()
                                        }
                                        // .padding(.top, isiPhone ? 90 : 0)
                                        
                                        .padding(.leading)
                                        
                                        
                                        
                                    }
                                    .padding(.bottom, isiPhone ? 20 : 0)
                                    
                                }
                                .frame(width: UIScreen.main.bounds.width, height: isiPhone ? 300 : 350)
                                if isiPhone || isLandscape {
                                    HStack {
                                        Text(isShowingScreenTime ? "Close" : "Show Screen Time")
                                            .padding()
                                            .frame(width: isShowingScreenTime ? 100 : isiPhone ? UIScreen.main.bounds.width * 0.9 : UIScreen.main.bounds.width * 0.3)
                                            .background(VisualEffectBlur(blurStyle: .systemThinMaterial))
                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                            .cornerRadius(22)
                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                            .onTapGesture {
                                                withAnimation {
                                                    isShowingScreenTime.toggle()
                                                }
                                            }
                                        
                                        if isShowingScreenTime {
                                            Spacer()
                                        }
                                        
                                        if !isiPhone {
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            if !isiPhone {
                                ZStack {
                                    VStack {
                                        Spacer()
                                            Button {
                                                viewModel.removeFCMToken(childId: childId)
                                                childId = child.id // Set the selected child's ID
                                                viewModel.AddFCMToken(childId: child.id)
                                                viewModel.removeFCMTokenParent(parentId: Auth.auth().currentUser?.uid ?? "")
                                                ipf = false // Update profile view state
                                                viewModel.fetchProfileImage(dp: child.profileImage) // Fetch profile image
                                                screenTimeViewModel.startScreenTime(for: childId) // Start tracking screen time
                                                dismiss() // Dismiss the view
                                            } label: {
                                                HStack {
                                                    Image(systemName: "lasso.sparkles")
                                                    Text("Go to \(child.name)'s Playground!")
                                                }
                                                .font(.title2)
                                                .padding()
                                                .background(BackGroundMesh())
                                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                .cornerRadius(16)
                                                .shadow(radius: 10)
                                            }
                                            
                                        
                                    }
                                }
                                .frame(height: isLandscape ? 370 : 410)
                        
                            }
                        }
                        Spacer()
                    }
                    
                    
                    
                }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    // Add observer to listen for orientation changes
                    NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                        // Update the state when the orientation changes
                        isLandscape = UIDevice.current.orientation.isLandscape
                        if isLandscape {
                            isShowingScreenTime = false
                        } else {
                            isShowingScreenTime = true
                        }
                    }
                    if !isiPhone {
                        isShowingScreenTime = true
                    }
                    if isLandscape {
                        isShowingScreenTime = false
                    }
                    friendsViewModel.fetchFriends(childId: childId)
                    // Fetch stories and friends count when the view appears
                    do {
                        try viewModel.getStory(childId: child.id) // Get stories for the selected child
                    } catch {
                        print(error.localizedDescription) // Handle errors
                    }
                    viewModel.getFriendsCount(childId: child.id) // Get friends count for the selected child
                }
                .onDisappear {
                            // Remove observer when view disappears to prevent memory leaks
                            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
                        }
            }
            //.navigationTitle(child.name) // Set the navigation title to the child's name
            
        }
    }
}
