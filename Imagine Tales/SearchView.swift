//
//  SearchView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//


import SwiftUI
import Firebase
import FirebaseFirestore

struct SearchView: View {
    @State private var searchText = ""
    @State private var children: [UserChildren] = []

    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemThinMaterial)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                
            VStack {
                TextField("Search...", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(22)
                
                List(children, id: \.id) { result in
                    Text(result.username)
                        .listRowBackground(Color.gray.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
                .onChange(of: searchText) {
                    performSearch(query: searchText)
                }
            }
            .padding()
        }
    }

    func performSearch(query: String) {
        let db = Firestore.firestore()
        db.collection("Children2")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let documents = snapshot?.documents ?? []
                    // Client-side filtering for partial and case-insensitive search
                    children = documents.compactMap { document -> UserChildren? in
                        if let data = try? document.data(as: UserChildren.self) {
                            // Perform case-insensitive and partial search on the desired field
                            if data.username.lowercased().contains(query.lowercased()) {
                                return data
                            }
                        }
                        return nil
                    }
                }
            }
    }
}

#Preview {
    SearchView()
}
