//
//  HomeView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/27/24.
//

import SwiftUI
import FirebaseFirestore

// Struct for each story text item
struct StoryTextItem: Codable, Hashable {
    var image: String
    var text: String
}

// Struct for the story document
struct Story: Codable, Hashable {
    let id: String
    var parentId: String
    var childId: String
    var storyText: [StoryTextItem]
    var title: String
    var status: String
    var genre: String
    var childUsername: String
}

final class HomeViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var genre: String = "Adventure"
    
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
    @AppStorage("childId") var childId: String = "Default Value"
    
    var body: some View {
        NavigationStack {
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
                StoryListView(stories: viewModel.stories, childId: childId)
                
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

struct StoryListView: View {
    var stories: [Story]
    var childId: String
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(stories, id: \.id) { story in
                        StoryRowView(story: story, childId: childId)
                    }
                }
            }
            .padding(.bottom, 50)
        }
    }
}

import SwiftUI

struct StoryRowView: View {
    var story: Story
    var childId: String
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                VStack(spacing: -20) {
                    // Title
                    HStack(alignment: .top) {
                        
                        Text(story.title)
                            .font(.system(size: 24))
                        // Adjust font weight if needed
                            .padding(.leading, 16) // Add padding to align the text properly
                        
                        Spacer() // Spacer to push icons to the right
                        
                        
                        HStack(spacing: 20) {
                            Image(systemName: "book")
                                .font(.system(size: 20))
                            Image(systemName: "bookmark")
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Image with overlay
                    NavigationLink(destination: StoryFromProfileView(story: story)) {
                        ZStack(alignment: .topTrailing) {
                            
                            AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(height: 500)
                                case .success(let image):
                                    
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 500)
                                        .clipped()
                                        .cornerRadius(30)
                                        .overlay(
                                            // User profile overlay
                                            HStack {
                                                Image(systemName: "person.crop.circle")
                                                Text(story.childUsername)
                                                    .font(.subheadline)
                                                Spacer()
                                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                            }
                                                .padding(5)
                                                .frame(width: 200)
                                                .background(Color.black.opacity(0.7))
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                                .padding()
                                            , alignment: .topTrailing
                                        )
                                        .padding()
                                    
                                    
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 500)
                                        .cornerRadius(10)
                                        .padding()
                                    
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 500)
                            .cornerRadius(10)
                            
                        }
                        
                    }
                }
                HStack {
                    // Story description
                
                        VStack(alignment: .leading) {
                        Text("The Minions hatch a clever plan to steal the world’s biggest banana, but things go hilariously wrong when they encounter a banana-loving monkey!")
                            .font(.body)
                            .padding(.horizontal)
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                        }
                        
                    
                    
                    // Action buttons
                    HStack {
                        Spacer()
                        
                        // Like button with count
                        HStack(spacing: 5) {
                            Image(systemName: "hand.thumbsup")
                            Text("48")
                        }
                        .padding(.trailing)
                        .font(.system(size: 20))
                        
                        // Share button
                        Image(systemName: "paperplane")
                            .font(.system(size: 20))
                        
                        
                    }
                    .padding()
                }
                .padding()
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    HomeView()
}
