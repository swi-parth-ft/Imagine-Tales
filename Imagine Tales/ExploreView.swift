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
    @State private var retryCount = 0
    @State private var maxRetryAttempts = 3 // Set max retry attempts
    @State private var retryDelay = 2.0
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
                                        Image(systemName: "smallcircle.filled.circle.fill")
                                            .font(.system(size: 15))
                                            .foregroundStyle(.white)
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
