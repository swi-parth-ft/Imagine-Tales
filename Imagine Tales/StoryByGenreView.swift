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
        
        NavigationStack {
            ZStack {
                BackGroundMesh()
                List {
                    ForEach(viewModel.stories) { story in
                        NavigationLink(destination: StoryFromProfileView(story: story)) {
                            VStack {
                                Spacer()
                                Text(story.title)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.4))
                        
                    }
                }
                .scrollContentBackground(.hidden)
                .onAppear {
                    viewModel.fetchStories(genre: genre)
                }
            }
            .navigationTitle(genre)
        }
    }
}

#Preview {
    StoryByGenreView(genre: "Horror")
}
