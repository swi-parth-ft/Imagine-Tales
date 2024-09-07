//
//  StoryByGenreView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/7/24.
//

import SwiftUI
import FirebaseFirestore

final class StoryByGenreViewModel: ObservableObject {
    @Published var stories: [Story] = []
    private var db = Firestore.firestore()
    
    func fetchStories(genre: String) {
        Firestore.firestore().collection("Story").whereField("status", isEqualTo: "Approve").whereField("genre", isEqualTo: genre).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.stories = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Story.self)
            } ?? []
            print(self.stories)
        }
    }
}
struct StoryByGenreView: View {
    @StateObject var viewModel = StoryByGenreViewModel()
    var genre: String
    
    var body: some View {
        List {
            ForEach(viewModel.stories) { story in
                Text(story.title)
                
            }
        }
        .onAppear {
            viewModel.fetchStories(genre: genre)
        }
    }
}

#Preview {
    StoryByGenreView(genre: "Horror")
}
