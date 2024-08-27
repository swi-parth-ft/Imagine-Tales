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
    
    func getStories() throws {
       
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
       
        
        Firestore.firestore().collection("Story").whereField("status", isEqualTo: "Approve").getDocuments() { (querySnapshot, error) in
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
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.stories, id: \.id) { story in
                    Text(story.title)
                }
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

#Preview {
    HomeView()
}
