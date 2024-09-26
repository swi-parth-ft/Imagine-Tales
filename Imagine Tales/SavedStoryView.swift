//
//  SavedStoryView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/29/24.
//

import SwiftUI
import FirebaseFirestore

final class SavedStoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var savedStories: [Story] = []
    @Published var genre: String = "Adventure"
    
    // Other existing methods...
    
    func getSavedStories(forChild childId: String) {
        let db = Firestore.firestore()
        let savedStoriesRef = db.collection("Children2").document(childId).collection("savedStories")
        
        savedStoriesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting saved stories: \(error)")
                return
            }
            
            var storyDictionary = [String: Story]()
            let storyIds = snapshot?.documents.compactMap { $0.data()["storyId"] as? String } ?? []
            
            let storyGroup = DispatchGroup()
            
            for storyId in storyIds {
                storyGroup.enter()
                db.collection("Story").document(storyId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let story = try? document.data(as: Story.self) {
                            // Use story ID as the key to ensure uniqueness
                            storyDictionary[storyId] = story
                        }
                    }
                    storyGroup.leave()
                }
            }
            
            storyGroup.notify(queue: .main) {
                // Convert dictionary values to array
                self.savedStories = Array(storyDictionary.values)
                self.savedStories.sort(by: { $0.title < $1.title })  // Example sorting, modify as needed
            }
        }
    }
   
}

struct SavedStoryView: View {
    @ObservedObject var viewModel = SavedStoryViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    @Binding var reload: Bool
   
    
    var body: some View {
        NavigationStack {
            if viewModel.savedStories.isEmpty {
                ContentUnavailableView {
                    Label("No Saved Stories Yet", systemImage: "book.fill")
                } description: {
                    Text("It looks like there's no stories saved yet.")
                } actions: {
//                                    Button {
//                                        /// Function that creates a new note
//                                    } label: {
//                                        Label("Create a new note", systemImage: "plus")
//                                    }
                }
                .listRowBackground(Color.clear)
            }
            List(viewModel.savedStories, id: \.id) { story in
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
                                .opacity(0.7)
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
            .scrollContentBackground(.hidden)
            .navigationTitle("Saved Stories")
            .onAppear {
                viewModel.getSavedStories(forChild: childId)
                
            }
            .onChange(of: reload) {
                viewModel.getSavedStories(forChild: childId)
            }
        }
    }
    
}

#Preview {
    SavedStoryView(reload: .constant(false))
}
