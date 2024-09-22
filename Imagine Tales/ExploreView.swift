//
//  ExploreView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/5/24.
//

import SwiftUI
import FirebaseFirestore

final class ExploreViewModel: ObservableObject {
    @Published var topStories: [Story] = []

    func getMostLikedStories() {
        let db = Firestore.firestore()
        
        db.collection("Story")
            .order(by: "likes", descending: true)
            .limit(to: 3) // Limit to the top 3 results
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
                
                // Parse the top 3 stories
                var fetchedStories: [Story] = []
                for document in documents {
                    do {
                        let story = try document.data(as: Story.self)
                        fetchedStories.append(story)
                    } catch {
                        print("Error decoding Story: \(error.localizedDescription)")
                    }
                }
                
                // Update the topStories array on the main thread
                DispatchQueue.main.async {
                    self.topStories = fetchedStories
                   
                }
            }
    }
    
    @Published var storiesByGenre: [String: [Story]] = [:]

        private var db = Firestore.firestore()

        func fetchStories() {
            db.collection("Story").whereField("status", isEqualTo: "Approve").getDocuments { [weak self] snapshot, error in
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
  
    @State private var isFullHeight = false
    @State private var imageOffset = CGSize.zero
    @State private var currentIndex = 0 // Track current story index

    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    
                    TabView(selection: $currentIndex) { // TabView for carousel effect
                        ForEach(0..<min(viewModel.topStories.count, 3), id: \.self) { index in
                            let story = viewModel.topStories[index]
                            NavigationLink(destination: StoryFromProfileView(story: story)) {
                                ZStack {
                                    AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                        switch phase {
                                        case .empty:
                                            GradientRectView(size: isFullHeight ? 600 : 300)
                                            
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: isFullHeight ? 600 : 300)
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
                                    .frame(width: UIScreen.main.bounds.width + 30, height: isFullHeight ? 600 : 300)
                                    .ignoresSafeArea()
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [.black, .white.opacity(0.1), .white.opacity(1)], startPoint: .bottom, endPoint: .top))
                                        .frame(height: isFullHeight ? 600 : 300)
                                        .ignoresSafeArea()
                                    
                                    VStack {
                                        Spacer()
                                        ZStack {
                                            Text(story.title)
                                                .font(.system(size: 46))
                                                .foregroundStyle(.white)
                                                .padding()
                                            
                                            HStack {
                                                Text(story.genre)
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(.white)
                                                Circle()
                                                    .foregroundStyle(.white)
                                                    .frame(width: 15)
                                                    .padding(.horizontal)
                                                Text("\(story.likes) Likes")
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(.white)
                                            }
                                            .padding(.top, 30)
                                        }
                                    }
                                    .frame(height: isFullHeight ? 600 : 300)
                                    .ignoresSafeArea()
                                }
                                .tag(index)
                                
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Enable the dots for page control
                    .shadow(radius: 20)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                imageOffset = value.translation
                            }
                            .onEnded { value in
                                let verticalAmount = value.translation.height
                                if verticalAmount > 15 {
                                    withAnimation {
                                        isFullHeight = true
                                    }
                                } else if verticalAmount < -15 {
                                    withAnimation {
                                        isFullHeight = false
                                    }
                                } else {
                                    withAnimation {
                                        imageOffset = .zero
                                    }
                                }
                            }
                    )
                }
                .frame(width: UIScreen.main.bounds.width + 30, height: isFullHeight ? 600 : 300)
                .ignoresSafeArea()
                
                Spacer()
                List {
                    ForEach(viewModel.storiesByGenre.keys.sorted(), id: \.self) { genre in
                        LazyVStack(alignment: .leading) {
                            HStack {
                                Text(genre)
                                    .font(.custom("ComicNeue-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                NavigationLink(destination: StoryByGenreView(genre: genre)) {
                                    Text("View All")
                                        .underline()
                                        .font(.custom("ComicNeue-Bold", size: 28))
                                    
                                }
                                .frame(width: 150)
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 20) {
                                    ForEach(viewModel.storiesByGenre[genre] ?? []) { story in
                                        NavigationLink(destination: StoryFromProfileView(story: story)) {
                                            ZStack(alignment: .top) {
                                                RoundedRectangle(cornerRadius: 22)
                                                  //  .stroke(Color(hex: "#F4F4DA"))
                                                    .fill(LinearGradient(colors: [Color(hex: "#F4F4DA"), Color(hex: "#F4F4DA").opacity(0.3), .clear, .clear], startPoint: .bottomLeading, endPoint: .topTrailing))
                                                    .frame(width: 300, height: 260)
                                                VStack(alignment: .center, spacing: 7) {
                                                    
                                                    AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            GradientRectView(size: 150)
                                                            
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 300, height: 150)
                                                                .clipped()
                                                                .cornerRadius(12)
                                                            
                                                        case .failure(_):
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(height: 150)
                                                                .cornerRadius(10)
                                                                .padding()
                                                                .onAppear {
                                                                    if retryCount < maxRetryAttempts {
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                                            retryCount += 1
                                                                        }
                                                                    }
                                                                }
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                                    
                                                    ZStack {
                                                       
                                                        HStack {
                                                            VStack(alignment: .leading, spacing: -18) {
                                                                Text(story.title)
                                                                    .font(.system(size: 18))
                                                                
                                                                VStack(alignment: .leading) {
                                                                    Text("By \(story.childUsername)")
                                                                    HStack {
                                                                        Text(story.theme ?? "")
                                                                            .padding(7)
                                                                            .background(.green)
                                                                            .foregroundStyle(.white)
                                                                            .cornerRadius(22)
                                                                        Text("\(story.likes) Likes")
                                                                    }
                                                                }
                                                                .padding(.bottom, 30)
                                                                
                                                                
                                                            }
                                                            .foregroundStyle(.black)
                                                            
                                                            Spacer()
                                                        }
                                                        .padding(.horizontal)
                                                        .frame(width: 300)
                                                  
                                                    }
                                                    .padding(7)
                                                    .frame(width: 310)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.0))
                        .listRowSeparator(.hidden)
                    }
                }
                .ignoresSafeArea()
                .scrollContentBackground(.hidden)
                .navigationTitle("Stories by Genre")
                .padding(.bottom)
                .onAppear {
                    viewModel.fetchStories()
                }

                  
                }
                
                Spacer()
            }
            .onAppear {
                viewModel.getMostLikedStories() // Ensure this fetches the top 3 stories
            }
            
        }
    }

#Preview {
    ExploreView()
}
