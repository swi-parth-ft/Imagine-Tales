//
//  StoryView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// View for displaying a child's story and allowing the parent to review it
struct StoryView: View {
    var story: Story // The story object containing story details
    @StateObject var viewModel = ParentViewModel() // State object for managing parent-related data
    @StateObject var homeViewModel = HomeViewModel()
    @State private var status = "" // Current review status of the story (Approve/Reject)
    @State private var comment = "" // Comment for the review
    @State private var isAddingCmt = false // State for showing comment input
    @State private var isRejecting = false // State for confirming rejection
    var child: UserChildren
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh() // Custom background for the view
                ScrollView {
                    // Loop through story text to display each segment
                    ForEach(0..<story.storyText.count, id: \.self) { index in
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                // Asynchronously load the story image
                                AsyncImage(url: URL(string: story.storyText[index].image)) { phase in
                                    switch phase {
                                    case .empty:
                                        // Show progress view while loading
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    case .success(let image):
                                        // Display the loaded image
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 300)
                                            .clipped()
                                            .cornerRadius(30)
                                    case .failure(_):
                                        // Show a placeholder image on failure
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                    @unknown default:
                                        EmptyView() // Handle any unknown states
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: 300)
                                .cornerRadius(10)
                            }
                            
                            // Display the story text
                            Text(story.storyText[index].text)
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .padding()
                    }
                    
                    // Review status and action buttons
                    HStack {
                        Spacer()
                        // Check if the story is rejected
                        if status == "Reject" {
                            HStack {
                                // Button to approve the story
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.black)
                                    .font(.title)
                                    .padding(.leading)
                                    .onTapGesture {
                                        do {
                                            try viewModel.reviewStory(status: "Approve", id: story.id)
                                            homeViewModel.sendStatusNotification(toUserId: child.id, storyId: story.id, storyTitle: story.title.trimmingCharacters(in: .newlines), type: "status", status: "Approved")
                                            withAnimation {
                                                status = "Approve" // Update status to approved
                                            }
                                        } catch {
                                            print(error.localizedDescription) // Handle errors
                                        }
                                    }
                                
                                // Show rejection label
                                Text("Rejected")
                                    .padding()
                                    .background(.red.opacity(0.4))
                                    .foregroundStyle(.black)
                                    .cornerRadius(22)
                            }
                            .background(.white)
                            .cornerRadius(22)
                            .padding()
                        } else {
                            // Buttons for approving or rejecting the story
                            HStack {
                                Button(status == "Approve" ? "Approved" : "Approve?") {
                                    do {
                                        try viewModel.reviewStory(status: "Approve", id: story.id)
                                        homeViewModel.sendStatusNotification(toUserId: child.id, storyId: story.id, storyTitle: story.title.trimmingCharacters(in: .newlines), type: "status", status: "Approved")
                                        withAnimation {
                                            status = "Approve" // Update status to approved
                                        }
                                    } catch {
                                        print(error.localizedDescription) // Handle errors
                                    }
                                }
                                .padding()
                                .background(.white)
                                .foregroundStyle(.black)
                                .cornerRadius(22)
                                
                                // Button to initiate rejection
                                Image(systemName: "x.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        isRejecting.toggle() // Toggle rejection confirmation
                                    }
                            }
                            .background(.red.opacity(0.4))
                            .cornerRadius(22)
                            .padding()
                        }
                    }
                    .padding()
                }
                .padding()
                .navigationTitle(story.title) // Set the navigation title to the story title
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: "message") {
                            isAddingCmt.toggle() // Toggle comment input
                        }
                    }
                }
                .onAppear {
                    // Fetch story status when the view appears
                    status = story.status
                    viewModel.fetchStoryAndReview(storyID: story.id)
                }
                // Alert for adding a review
                .alert("Add Review", isPresented: $isAddingCmt, actions: {
                    TextField("Enter your review here", text: $comment) // Text field for review input
                    Button("Submit") {
                        viewModel.addReview(storyID: story.id, reviewNotes: comment) // Submit review
                    }
                    Button("Cancel", role: .cancel, action: {}) // Cancel action
                }, message: {
                    Text("Please add your review for the child's story.")
                        .onAppear {
                            comment = viewModel.comment // Populate comment field if necessary
                        }
                })
                // Alert for confirming story rejection
                .alert("Reject Story", isPresented: $isRejecting, actions: {
                    Button("Reject") {
                        do {
                            try viewModel.reviewStory(status: "Reject", id: story.id) // Reject the story
                            homeViewModel.sendStatusNotification(toUserId: child.id, storyId: story.id, storyTitle: story.title.trimmingCharacters(in: .newlines), type: "status", status: "Rejected")
                            withAnimation {
                                status = "Reject" // Update status to rejected
                            }
                        } catch {
                            print(error.localizedDescription) // Handle errors
                        }
                    }
                    Button("Cancel", role: .cancel, action: {}) // Cancel action
                }, message: {
                    Text("Are you sure you want to reject this story?")
                })
            }
        }
    }
}
