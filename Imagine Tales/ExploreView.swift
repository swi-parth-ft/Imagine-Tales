//
//  ExploreView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/5/24.
//

import SwiftUI
import FirebaseFirestore

final class ExploreViewModel: ObservableObject {
    @Published var topStory: Story?

    func getMostLikedStory() {
            let db = Firestore.firestore()
            
            db.collection("Story")
                .order(by: "likes", descending: true)
                .limit(to: 1) // Limit to the top result
                .getDocuments { (querySnapshot, error) in
                    // Log any error that occurs
                    if let error = error {
                        print("Error getting documents: \(error.localizedDescription)")
                        return
                    }
                    
                    // Check if the snapshot exists
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        print("No documents found")
                        return
                    }
                    
                    // Update topStory with the most liked story
                    if let firstDocument = documents.first {
                        do {
                            let story = try firstDocument.data(as: Story.self)
                            // Update UI on main thread if needed
                            DispatchQueue.main.async {
                                self.topStory = story
                                print("Top story successfully fetched and parsed: \(story)")
                            }
                        } catch {
                            print("Error decoding Story: \(error.localizedDescription)")
                        }
                    }
                }
        }
}
struct ExploreView: View {
    @StateObject var viewModel = ExploreViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.topStory?.title ?? "nothing")
        }
            .onAppear {
                viewModel.getMostLikedStory()
            }
    }
}

#Preview {
    ExploreView()
}
