//
//  StoryReviewView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/19/24.
//


import SwiftUI

struct StoryReviewView: View {
   
    var theme: String
    var genre: String
    var characters: String
    var chars: [Charater]?
    var mood: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Prompt section
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(hex: "#F2F2DB"), lineWidth: 2)
                    .frame(height: 200)
                VStack(alignment: .leading, spacing: 10) {
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Prompt")
                                .font(.system(size: 28))
                            Spacer()
                            Image(systemName: "shuffle")
                                .font(.system(size: 24))
                                .frame(width: 20, height: 20)
                        }
                        .padding(.horizontal, 30)
                        
                        Divider()
                            .background(Color(hex: "#F2F2DB"))
                        HStack {
                        Text("I want to generate a story book of ")
                            .font(.system(size: 24))
                            .foregroundColor(.primary) +
                        Text(theme)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#FF6F61")) +
                        Text(" theme with genre of ")
                            .font(.system(size: 24))
                            .foregroundColor(.primary) +
                        Text(genre)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.cyan) +
                        Text(" with ")
                            .font(.system(size: 24))
                            .foregroundColor(.primary) +
                        Text(characters.isEmpty ? "no" : characters)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.purple) +
                        Text(characters.isEmpty ? " characters" : " as characters")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 30)

                    }
                    .padding()
                }
            }
            // Story Details Section
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "#F2F2DB"))
                    .frame(height: 500)
                VStack(alignment: .center) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "#F8F8E4"))
                            .frame(height: 100)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Theme")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.secondary)
                                Text(theme)
                                    .font(.system(size: 24))
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "#F8F8E4"))
                                .frame(height: 100)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Mood")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.secondary)
                                    Text(mood)
                                        .font(.system(size: 24))
                                }
                                Spacer()
                                Text("🤩")
                                    .font(.system(size: 54))
                            }
                            .padding()
                        }
                        .padding()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "#F8F8E4"))
                                .frame(height: 100)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Genre")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.secondary)
                                    Text(genre)
                                        .font(.system(size: 24))
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .padding()
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "#F8F8E4"))
                            .frame(width: 200, height: 120)
                        HStack {
                            
                            VStack {
                                Text("Characters")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Text("Sam")
                                        .font(.system(size: 24))
                                        .padding()
                                        .background(Color(hex: "#F2F2DB"))
                                        .cornerRadius(22)
                                    
                                    Text("Jade")
                                        .font(.system(size: 24))
                                        .padding()
                                        .background(Color(hex: "#F2F2DB"))
                                        .cornerRadius(22)
                                    
                                }
                            }
                            
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                 
                }
                .padding()
                .cornerRadius(10)
            }
          

            
        }
        .padding()
    }
        
}



#Preview {
    StoryReviewView(theme: "Forest", genre: "science fiction", characters: "Parth and sara", mood: "happy")
}
