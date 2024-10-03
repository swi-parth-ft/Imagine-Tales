//
//  StoryView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
import Drops

// View for displaying a child's story and allowing the parent to review it
struct StoryView: View {
    var story: Story // The story object containing story details
    @StateObject var viewModel = ParentViewModel() // State object for managing parent-related data
    @StateObject var homeViewModel = HomeViewModel()
    @State private var status = "" // Current review status of the story (Approve/Reject)
    @State private var comment = "" // Comment for the review
    @State private var isAddingCmt = false // State for showing comment input
    @State private var isExpanding = false
    var child: UserChildren
    @Environment(\.colorScheme) var colorScheme
    @State var counter: Int = 0 // Counter for ripple effect on the profile image
    @State var origin: CGPoint = .zero // Origin point for the ripple effect
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
                                            .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : 300)
                                            .clipped()
                                            .cornerRadius(30)
                                            .onPressingChanged { point in
                                                if let point {
                                                    self.origin = point
                                                    self.counter += 1
                                                }
                                            }
                                            .modifier(RippleEffect(at: self.origin, trigger: self.counter)) // Custom ripple effect
                                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20) // Adds shadow at the bottom
                                            
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
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : 300)
                                .cornerRadius(10)
                                .onTapGesture {
                                    withAnimation {
                                        isExpanding.toggle()
                                    }
                               
                                }
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
                    
                    HStack {
                        
                        Button {
                            do {
                                try viewModel.reviewStory(status: "Approve", id: story.id)
                                homeViewModel.sendStatusNotification(toUserId: child.id, storyId: story.id, storyTitle: story.title.trimmingCharacters(in: .newlines), type: "status", status: "Approved")
                                Drops.show("Story Approved")
                                withAnimation {
                                    status = "Approve" // Update status to approved
                                }
                            } catch {
                                print(error.localizedDescription) // Handle errors
                            }
                        } label: {
                            if status != "Reject" {
                                Text(status == "Approve" ? "Approved" : "Approve")
                                    .padding()
                                    .frame(width: 200)
                                    .background(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#F2F2DB"))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black )
                                    .cornerRadius(12)
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                    .padding()
                                    .frame(width: 50)
                            }
                            
                                
                        }
                        
                        Button {
                            do {
                                try viewModel.reviewStory(status: "Reject", id: story.id) // Reject the story
                                homeViewModel.sendStatusNotification(toUserId: child.id, storyId: story.id, storyTitle: story.title.trimmingCharacters(in: .newlines), type: "status", status: "Rejected")
                                Drops.show("Story Rejected")
                                withAnimation {
                                    status = "Reject" // Update status to rejected
                                }
                            } catch {
                                print(error.localizedDescription) // Handle errors
                            }
                        } label: {
                            if status != "Approve" {
                                Text(status == "Reject" ? "Rejected" : "Reject")
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color(hex: "#FF6F61"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            } else {
                                Image(systemName: "xmark.seal.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(width: 50)
                            }
                            
                            
                        }
                        
                    }
                   
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
                        homeViewModel.sendStatusNotification(toUserId: child.id, storyId: story.id, storyTitle: story.title.trimmingCharacters(in: .newlines), type: "Comment", status: "")
                    }
                    Button("Cancel", role: .cancel, action: {}) // Cancel action
                }, message: {
                    Text("Please add your review for the child's story.")
                        .onAppear {
                            comment = viewModel.comment // Populate comment field if necessary
                        }
                })
             
            }
        }
    }
}
