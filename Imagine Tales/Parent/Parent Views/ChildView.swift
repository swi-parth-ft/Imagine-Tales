//
//  ChildView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

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
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea() // Custom background for the view
                VStack {
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white) // Background circle for profile image
                                .frame(width: isiPhone ? 250 / 2 : 250)
                            Image(child.profileImage.removeJPGExtension()) // Display profile image
                                .resizable()
                                .scaledToFit()
                                .frame(width: isiPhone ? 100 : 200)
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
                        HStack {
                            VStack(alignment: .leading) {
                                // Display child's username and stats
                                Text("@\(child.username)")
                                    .font(.title)
                                Text("\(viewModel.numberOfFriends) Friends") // Friends count
                                Text("\(viewModel.story.count) Stories Posted") // Stories count
                                Spacer()
                                if !isiPhone {
                                    Button("Go to \(child.name)'s Playground! 🪄") {
                                        childId = child.id // Set the selected child's ID
                                        ipf = false // Update profile view state
                                        viewModel.fetchProfileImage(dp: child.profileImage) // Fetch profile image
                                        screenTimeViewModel.startScreenTime(for: childId) // Start tracking screen time
                                        dismiss() // Dismiss the view
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
                        // Show the screen time chart for the child
                        ScreenTimeChartView(selectedChildId: child.id)
                            .listRowBackground(Color.white.opacity(0)) // Transparent background for the chart
                        
                        // List all the stories associated with the child
                        ForEach(viewModel.story, id: \.id) { story in
                            NavigationLink(destination: StoryView(story: story)) {
                                ZStack {
                                    HStack {
                                        VStack {
                                            Spacer()
                                            Text("\(story.title)") // Display story title
                                        }
                                        Spacer()
                                        // Show story status with color coding
                                        Text(story.status == "Approve" ? "Approved" : (story.status == "Reject" ? "Rejected" : "Pending"))
                                            .foregroundStyle(story.status == "Approve" ? .green : (story.status == "Reject" ? .red : .blue))
                                    }
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.4)) // Background for each story row
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
                    .scrollContentBackground(.hidden) // Hide default background of the list
                }
                .onAppear {
                    // Fetch stories and friends count when the view appears
                    do {
                        try viewModel.getStory(childId: child.id) // Get stories for the selected child
                    } catch {
                        print(error.localizedDescription) // Handle errors
                    }
                    viewModel.getFriendsCount(childId: child.id) // Get friends count for the selected child
                }
            }
            .navigationTitle(child.name) // Set the navigation title to the child's name
        }
    }
}
