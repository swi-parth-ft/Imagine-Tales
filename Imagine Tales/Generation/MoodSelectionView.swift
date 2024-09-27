//
//  MoodSelectionView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI

struct MoodSelectionView: View {
    @Binding var isSelectingMood: Bool
    @Binding var mood: String
    @Binding var selectedEmoji: String
    let moods: [String]
    let moodEmojis: [String]
    
    var body: some View {
        GeometryReader { geometry in
            let height = (geometry.size.height - 40) / 8
            
            ScrollView(.horizontal) {
                LazyHGrid(
                    rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 4),
                    spacing: 60  // Adjust the spacing to bring the columns closer together
                ) {
                    ForEach(0..<moods.count, id: \.self) { index in
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(moods[index] == mood ? Color.yellow.opacity(0.5) : Color.yellow.opacity(0.2))
                                    .frame(width: height, height: height)
                                    .shadow(radius: 5)
                                    .scaleEffect(isSelectingMood ? (moods[index] == mood ? 1.4 : 1.2) : 0.0)
                                    .animation(.easeInOut(duration: moods[index] == mood ? 0.6 : 0.3), value: isSelectingMood)
                                
                                VStack {
                                    Text(moodEmojis[index])
                                        .font(.system(size: 32))
                                    Text(moods[index])
                                        .font(.custom("ComicNeue-Bold", size: 24))
                                        .opacity(isSelectingMood ? 1.0 : 0.0)
                                        .scaleEffect(isSelectingMood ? (moods[index] == mood ? 1.2 : 1.0) : 0.0)
                                        .animation(.easeInOut(duration: moods[index] == mood ? 0.6 : 0.3), value: isSelectingMood)
                                }
                            }
                        }
                        // Apply offset for every other column to create a hexagonal shape
                        .offset(y: (index / 4) % 2 == 0 ? 0 : height / 2)
                        .frame(width: height, height: height)
                        .onTapGesture {
                            withAnimation {
                                mood = moods[index]
                                selectedEmoji = moodEmojis[index]
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