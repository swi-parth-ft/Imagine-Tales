//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI
import FirebaseFirestore

final class HomeViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var genre: String = ""
    
    func getStories() throws {
       
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

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    let genres = [
        "Adventure",
        "Fantasy",
        "Mystery",
        "Romance",
        "Science Fiction",
        "Horror",
        "Thriller",
        "Historical",
        "Comedy",
        "Drama",
        "Detective",
        "Dystopian",
        "Fairy Tale",
        "Magical Realism",
        "Biography",
        "Coming-of-Age",
        "Action",
        "Paranormal",
        "Supernatural",
        "Western"
    ]
    
    
    var body: some View {
        VStack {
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(genres, id: \.self) { category in
                        Button(action: {
                            withAnimation {
                                viewModel.genre = category
                                do {
                                    try viewModel.getStories()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }) {
                            Text(category)
                                .padding()
                                .background(category == viewModel.genre ? Color.green : Color.clear)
                                .foregroundColor(category == viewModel.genre ? .white : .black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: category == viewModel.genre ? 0 : 1)
                                )
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.stories, id: \.id) { story in
                        VStack {
                            Text(story.title)
                            AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                switch phase {
                                case .empty:
                                    // Placeholder while loading
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                case .success(let image):
                                    // Successfully loaded image
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                case .failure(_):
                                    // Failure to load image
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                @unknown default:
                                    // Fallback for unknown cases
                                    EmptyView()
                                }
                            }
                            .frame(width: 400, height: 200)
                        }
                        .padding(.vertical)
                    }
                }
                .onAppear {
                    do {
                        try viewModel.getStories()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
        
        }
    }
}

#Preview {
    HomeView()
}
