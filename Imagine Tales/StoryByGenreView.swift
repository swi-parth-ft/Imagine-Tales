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
                            .background(.white.opacity(0.4))
                            .cornerRadius(22)
                            .contentShape(Rectangle())
                            
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.white.opacity(0))
                        .listRowSeparator(.hidden)
                        
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
