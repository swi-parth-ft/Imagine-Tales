//
//  ThemeSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI

struct ThemeSelectionView: View {
    @Binding var isSelectingTheme: Bool
    @Binding var theme: String
    let themes: [String]
    let themeColors: [Color]

    var body: some View {
        GeometryReader { geometry in
            let height = (geometry.size.height - 40) / 5

            ScrollView(.horizontal) {
                LazyHGrid(
                    rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 3),
                    spacing: 60  // Adjust the spacing to bring the columns closer together
                ) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(themes[index] == theme ? themeColors[index].opacity(0.5) : themeColors[index].opacity(0.2))
                                    .frame(width: height, height: height)
                                    .shadow(radius: 5)
                                    .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.4 : 1.2) : 0.0)
                                    .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)

                                VStack {
                                    Image("\(themes[index].filter { !$0.isWhitespace })")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: height * 0.7, height: height * 0.7, alignment: .center)
                                        .shadow(radius: 5)
                                        .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.2 : 1.0) : 0.0)
                                        .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)

                                    let words = themes[index].split(separator: " ")

                                    VStack {
                                        ForEach(words, id: \.self) { word in
                                            Text(String(word))
                                                .font(.custom("ComicNeue-Bold", size: 24))
                                                .multilineTextAlignment(.center)
                                                .opacity(isSelectingTheme ? 1.0 : 0.0)
                                                .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.2 : 1.0) : 0.0)
                                                .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)
                                        }
                                    }
                                }
                                .padding()

                            }

                        }
                        // Apply offset for every other column to create hexagonal shape
                        .offset(y: (index / 3) % 2 == 0 ? 0 : height / 2)
                        .frame(width: height, height: height)
                        .onTapGesture {
                            withAnimation {
                                theme = themes[index]
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