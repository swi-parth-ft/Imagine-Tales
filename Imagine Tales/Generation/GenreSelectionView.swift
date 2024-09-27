//
//  GenreSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI

struct GenreSelectionView: View {
    @Binding var isSelectingGenre: Bool
    @Binding var genre: String
    let genres: [String]

    var body: some View {
        GeometryReader { geometry in
            let height = (geometry.size.height - 40) / 7

            ScrollView(.horizontal) {
                LazyHGrid(
                    rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 4),
                    spacing: 60  // Adjust the spacing to bring the columns closer together
                ) {
                    ForEach(0..<genres.count, id: \.self) { index in
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(genres[index] == genre ? Color.cyan.opacity(0.5) : Color.cyan.opacity(0.2))
                                    .frame(width: height, height: height)
                                    .shadow(radius: 5)
                                    .scaleEffect(isSelectingGenre ? (genres[index] == genre ? 1.4 : 1.2) : 0.0)
                                    .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre)

                                Text(genres[index])
                                    .font(.custom("ComicNeue-Bold", size: 24))
                                    .opacity(isSelectingGenre ? 1.0 : 0.0)
                                    .scaleEffect(isSelectingGenre ? (genres[index] == genre ? 1.2 : 1.0) : 0.0)
                                    .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre)
                            }
                        }
                        // Apply offset for every other column to create hexagonal shape
                        .offset(y: (index / 4) % 2 == 0 ? 0 : height / 2)
                        .frame(width: height, height: height)
                        .onTapGesture {
                            withAnimation {
                                genre = genres[index]
                            }
                        }
                    }
                }
                .padding(.leading, 50)
                .padding(.bottom, 70)
            }
            Spacer()
        }
        .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
    }
}