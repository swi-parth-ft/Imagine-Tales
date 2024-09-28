//
//  ExploreView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/5/24.
//

import SwiftUI

struct ExploreView: View {
    @StateObject var viewModel = ExploreViewModel() // Instantiate the ViewModel
    @State private var retryCount = 0 // Count for retry attempts when loading images
    @State private var maxRetryAttempts = 3 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retries
    @State private var themes: [String] = [] // Array for themes (not used in the current code)
  
    @State private var isFullHeight = false // State to determine if the view is in full height mode
    @State private var imageOffset = CGSize.zero // Track image offset for drag gestures
    @State private var currentIndex = 0 // Track the currently displayed story index
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    // TabView for displaying a carousel of stories
                    TabView(selection: $currentIndex) {
                        ForEach(0..<min(viewModel.topStories.count, 3), id: \.self) { index in
                            let story = viewModel.topStories[index] // Get the current story
                            NavigationLink(destination: StoryFromProfileView(story: story)) {
                                ZStack {
                                    // Load the story image asynchronously
                                    AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                        switch phase {
                                        case .empty:
                                            // Placeholder for loading
                                            GradientRectView(size: isFullHeight ? 600 : 300)
                                            
                                        case .success(let image):
                                            // Successfully loaded image
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: isFullHeight ? 600 : 300)
                                                .clipped()
                                                .cornerRadius(30)
                                                .shadow(radius: 5)
                                            
                                        case .failure(_):
                                            // Placeholder for failed load
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 600)
                                                .cornerRadius(10)
                                                .padding()
                                                .onAppear {
                                                    // Retry loading if the count is below max attempts
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
                                    .frame(width: UIScreen.main.bounds.width + 30, height: isFullHeight ? 600 : 300)
                                    .ignoresSafeArea()
                                    
                                    // Overlay gradient rectangle for styling
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [.black, .white.opacity(0.1), .white.opacity(1)], startPoint: .bottom, endPoint: .top))
                                        .frame(height: isFullHeight ? 600 : 300)
                                        .ignoresSafeArea()
                                    
                                    // Display story title and genre
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
                                .tag(index) // Tag for identifying the current story
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Enable pagination indicators
                    .shadow(radius: 20)
                    .ignoresSafeArea()
                    .gesture(
                        // Drag gesture for expanding and collapsing the image view
                        DragGesture()
                            .onChanged { value in
                                imageOffset = value.translation // Update image offset during drag
                            }
                            .onEnded { value in
                                let verticalAmount = value.translation.height
                                // Expand or collapse based on drag direction
                                if verticalAmount > 15 {
                                    withAnimation {
                                        isFullHeight = true // Expand
                                    }
                                } else if verticalAmount < -15 {
                                    withAnimation {
                                        isFullHeight = false // Collapse
                                    }
                                } else {
                                    withAnimation {
                                        imageOffset = .zero // Reset offset
                                    }
                                }
                            }
                    )
                }
                .frame(width: UIScreen.main.bounds.width + 30, height: isFullHeight ? 600 : 300)
                .ignoresSafeArea()
                
                Spacer()
                // List to display stories grouped by genre
                List {
                    ForEach(viewModel.storiesByGenre.keys.sorted(), id: \.self) { genre in
                        LazyVStack(alignment: .leading) {
                            HStack {
                                Text(genre)
                                    .font(.custom("ComicNeue-Bold", size: 28)) // Genre title
                                    .padding(.leading)
                                Spacer()
                                // Navigation link to view all stories of this genre
                                NavigationLink(destination: StoryByGenreView(genre: genre)) {
                                    Text("View All")
                                        .underline()
                                        .font(.custom("ComicNeue-Bold", size: 28))
                                }
                                .frame(width: 150)
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            
                            // Horizontal scroll view for stories of the genre
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 20) {
                                    ForEach(viewModel.storiesByGenre[genre] ?? []) { story in
                                        NavigationLink(destination: StoryFromProfileView(story: story)) {
                                            ZStack(alignment: .top) {
                                         
                                                RoundedRectangle(cornerRadius: 22)
                                                    .fill(LinearGradient(colors: [colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#F4F4DA"), colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#F4F4DA").opacity(0.3), .clear, .clear], startPoint: .bottomLeading, endPoint: .topTrailing))
                                                    .frame(width: 300, height: 260)
                                                
                                                VStack(alignment: .center, spacing: 7) {
                                                    // Load the story image asynchronously
                                                    AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            // Placeholder for loading
                                                            GradientRectView(size: 150)
                                                            
                                                        case .success(let image):
                                                            // Successfully loaded image
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 300, height: 150)
                                                                .clipped()
                                                                .cornerRadius(12)
                                                            
                                                        case .failure(_):
                                                            // Placeholder for failed load
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(height: 150)
                                                                .cornerRadius(10)
                                                                .padding()
                                                                .onAppear {
                                                                    // Retry loading logic
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
                                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Add shadow to the image
                                                    
                                                    // Stack for story details
                                                    ZStack {
                                                        HStack {
                                                            VStack(alignment: .leading, spacing: -18) {
                                                                Text(story.title) // Story title
                                                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                                    .font(.system(size: 18))
                                                                    
                                                                
                                                                VStack(alignment: .leading) {
                                                                    Text("By \(story.childUsername)")
                                                                        .foregroundStyle(colorScheme == .dark ? .white : .black)// Author username
                                                                    HStack {
                                                                        Text(story.theme ?? "") // Story theme
                                                                            .padding(7)
                                                                            .background(colorScheme == .dark ? Color(hex: "#4B8A1C") : .green)
                                                                            .foregroundStyle(.white)
                                                                            .cornerRadius(22)
                                                                        Text("\(story.likes) Likes") // Likes count
                                                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                                    }
                                                                }
                                                                .padding(.bottom, 30) // Padding below
                                                            }
                                                            .foregroundStyle(.primary)
                                                            
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
                        .listRowBackground(Color.white.opacity(0.0)) // Transparent background for list row
                        .listRowSeparator(.hidden) // Hide list row separator
                    }
                }
                .ignoresSafeArea()
                .scrollContentBackground(.hidden)
                .navigationTitle("Stories by Genre") // Set navigation title
                .padding(.bottom)
                .onAppear {
                    viewModel.fetchStories() // Fetch stories on appear
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.getMostLikedStories() // Fetch top 3 stories on appear
        }
    }
}

// Preview provider for SwiftUI previews
#Preview {
    ExploreView()
}
