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
  
    @State private var isFullHeight = true // State to determine if the view is in full height mode
    @State private var imageOffset = CGSize.zero // Track image offset for drag gestures
    @State private var currentIndex = 0 // Track the currently displayed story index
    @Environment(\.colorScheme) var colorScheme
    @State var counter: Int = 0 // Counter for gesture effects
    @State var origin: CGPoint = .zero // Origin point for ripple effect
    @State private var offset = CGSize.zero // Offset for any animation (unused)
    @EnvironmentObject var orientation: OrientationManager
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {

                
              //  Spacer()
                
                // List to display stories grouped by genre
                List {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Top Stories")
                                .font(.custom("ComicNeue-Bold", size: 22))
                            DeckView()
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.white.opacity(0.0))
                    .listRowSeparator(.hidden) // Hide list row separator
                    Text("Stories By Genre")
                        .font(.custom("ComicNeue-Bold", size: 32))
                        .padding(.leading)
                        .listRowBackground(Color.white.opacity(0.0))
                        .listRowSeparator(.hidden) // Hide list row separator
                    ForEach(Array(viewModel.storiesByGenre.keys.sorted().enumerated()), id: \.element) { index, genre in
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
                                                            MagicView()
                                                                .frame(width: 300, height: 150)
                                                            
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
                                                            VStack(alignment: .leading) {
                                                                Text(story.title.trimmingCharacters(in: .newlines)) // Story title
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
                        .onAppear {
                            if !orientation.isLandscape {
                                
                                if index == 3 {
                                    // Do something when the 4th genre appears on screen
                                    withAnimation {
                                        isFullHeight = false
                                    }
                                    // Call a function or trigger an action here
                                }
                                if index == 1 {
                                    // Do something when the 4th genre appears on screen
                                    withAnimation {
                                        isFullHeight = true
                                    }
                                    // Call a function or trigger an action here
                                }
                            } else {
                                isFullHeight = false
                            }
                                }
                    }
                }
                .scrollContentBackground(.hidden)
                //.navigationTitle("Stories by Genre") // Set navigation title
                .padding(.bottom)
                .onAppear {
                    viewModel.fetchStories() // Fetch stories on appear
                }
                Spacer()
            }
            .navigationTitle("Explore")
            
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
