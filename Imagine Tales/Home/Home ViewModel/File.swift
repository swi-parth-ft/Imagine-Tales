//
//  File.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
@MainActor
class StoryModel: ObservableObject {
    @Published var stories: [Story] = []
    private var lastDocument: DocumentSnapshot? = nil
    private let limit = 1  // Set a limit of 10 stories per batch
    
    // Function to load stories with pagination
    func getStories(isLoadMore: Bool = false) async {
        // Reset the stories and pagination if not loading more
        if !isLoadMore {
            stories = []
            lastDocument = nil
        }
        
        do {
            // Fetch a batch of stories from Firestore
            let (newStories, lastDoc) = try await StoriesManager.shared.getAllStories(count: limit, genre: "Horror", lastDocument: lastDocument)
            
            // Update UI in main thread
            DispatchQueue.main.async {
                self.stories.append(contentsOf: newStories)
                self.lastDocument = lastDoc // Update last document for pagination
            }
        } catch {
            print("Error fetching stories: \(error.localizedDescription)")
        }
    }
}



struct myView: View {
    @StateObject var viewModel = StoryModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                Text("\(viewModel.stories.count)")
                ForEach(viewModel.stories) { story in
                    Text(story.title)
                  
                    
                    // Load more when reaching the last story
                    if story == viewModel.stories.last {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await viewModel.getStories(isLoadMore: true)
                                }
                            }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.getStories()
            }
        }
    }
}

#Preview {
    myView()
}
