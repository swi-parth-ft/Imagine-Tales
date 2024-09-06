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
    
    @Published var storiesByGenre: [String: [Story]] = [:]

        private var db = Firestore.firestore()

        func fetchStories() {
            db.collection("Story").getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                let stories = documents.compactMap { try? $0.data(as: Story.self) }
                self?.storiesByGenre = Dictionary(grouping: stories, by: { $0.genre })
            }
        }
}
struct ExploreView: View {
    @StateObject var viewModel = ExploreViewModel()
    @State private var retryCount = 0
    @State private var maxRetryAttempts = 3 // Set max retry attempts
    @State private var retryDelay = 2.0
    @State private var themes: [String] = []
  
    var body: some View {
        VStack {
            ZStack {
                
                AsyncImage(url: URL(string: viewModel.topStory?.storyText[0].image ?? "")) { phase in
                    switch phase {
                    case .empty:
                        GradientRectView(size: 600)
                        
                    case .success(let image):
                        
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 600)
                            .clipped()
                            .cornerRadius(30)
                        
                            .shadow(radius: 5)
                        
                        
                        
                    case .failure(_):
                        
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 600)
                            .cornerRadius(10)
                            .padding()
                        
                            .onAppear {
                                if retryCount < maxRetryAttempts {
                                    // Retry logic with delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                        retryCount += 1
                                    }
                                }
                            }
                        
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 600)
                .ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [.black, .white.opacity(0.1), .white.opacity(0.1)], startPoint: .bottom, endPoint: .top))
                    .frame(height: 600)
                    .ignoresSafeArea()
                VStack(spacing: -45) { // Adjust spacing between the text views
                    Spacer()
                    
                    Text(viewModel.topStory?.title ?? "nothing")
                        .font(.system(size: 46))
                        .foregroundStyle(.white)
                    HStack {
                        Text(viewModel.topStory?.genre ?? "")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                        Circle()
                            .foregroundStyle(.white)
                            .frame(width: 15)
                            .padding(.horizontal)
                        Text("\(viewModel.topStory?.likes ?? 0) Likes")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 20) // Adjust bottom padding to control the vertical layout
                .frame(height: 600)
                .ignoresSafeArea()
            }
            .shadow(radius: 20)
            
            List {
                ForEach(viewModel.storiesByGenre.keys.sorted(), id: \.self) { genre in
                    VStack(alignment: .leading) {
                        Text(genre)
                            .font(.title2)
                            .bold()
                            .padding(.leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                               
                                ForEach(viewModel.storiesByGenre[genre] ?? []) { story in
                                    VStack {
                                        AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                            switch phase {
                                            case .empty:
                                                GradientRectView(size: 200)
                                                
                                            case .success(let image):
                                                
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 400, height: 200)
                                                    .clipped()
                                                    .cornerRadius(30)
                                                
                                            case .failure(_):
                                                
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                                    .cornerRadius(10)
                                                    .padding()
                                                    .onAppear {
                                                        if retryCount < maxRetryAttempts {
                                                            // Retry logic with delay
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                                retryCount += 1
                                                            }
                                                        }
                                                    }
                                                
                                                
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                        Text(story.title)
                                    }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    .listRowBackground(Color.white.opacity(0.0))
                        .padding(.bottom)
                  
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Stories by Genre")
            .onAppear {
                viewModel.fetchStories()
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.getMostLikedStory()
     
        }
    }
}

#Preview {
    ExploreView()
}
