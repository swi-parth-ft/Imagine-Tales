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
    var petString: String
    var chars: [Charater]
    var pets: [Pet]
    var mood: String
    var moodEmoji: String
    var body: some View {
        VStack(spacing: 20) {
            // Prompt section
            Text("Preview")
                .font(.custom("ComicNeue-Bold", size: 32))
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
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Awesome! You've chosen to create a ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text(theme)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#FF6F61")) +
                                Text(" story with genre of ")
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
                                Text(characters.isEmpty ? " characters " : " as characters ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                                
                            }
                            .padding(.leading, 30)
                            HStack {
                                Text(petString.isEmpty ? "" : " with ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text(petString.isEmpty ? "" : petString)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.purple) +
                                Text(". The mood of your story will be ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text("\(mood)!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                            }
                            .padding(.leading, 25)
                        }
                    }
                    .padding()
                }
            }
            // Story Details Section
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "#F2F2DB"))
                    .frame(height: 600)
                VStack {
                    Spacer()
                    
                    HStack {
                        Image("\(theme.filter { !$0.isWhitespace })1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220)
                        
                        Spacer()
                        
                        Image("\(theme.filter { !$0.isWhitespace })2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220)
                        
                    }
                }
                .frame(height: 600)
                VStack(alignment: .center) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "#F8F8E4"))
                            .frame(height: 100)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Theme")
                                    .font(.custom("ComicNeue-Bold", size: 20))
                                    .foregroundStyle(.secondary)
                                Text(theme)
                                    .font(.system(size: 24))
                            }
                            Spacer()
                            Image("\(theme.filter { !$0.isWhitespace })")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .shadow(radius: 5)
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
                                        .font(.custom("ComicNeue-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    Text(mood)
                                        .font(.system(size: 24))
                                }
                                Spacer()
                                Text(moodEmoji)
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
                                        .font(.custom("ComicNeue-Bold", size: 20))
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
                            .fill(Color(hex: "#F8F8E4").opacity(0.5))
                            .frame(width: 500, height: 120)
                        HStack {
                            
                            VStack(alignment: .center) {
                                Text("Characters")
                                    .font(.custom("ComicNeue-Bold", size: 20))
                                    .foregroundStyle(.secondary)
                                
                                
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(chars) { character in
                                                HStack {
                                                    Text(character.name)
                                                        .font(.system(size: 24))
                                                        .padding()
                                                        .background(Color(hex: "#F2F2DB"))
                                                        .cornerRadius(22)
                                                    Image(character.gender)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                }
                                                .background(Color(hex: "#F2F2DB"))
                                                .cornerRadius(22)
                                            }
                                            
                                            ForEach(pets) { pet in
                                                HStack {
                                                    Text(pet.name)
                                                        .font(.system(size: 24))
                                                        .padding()
                                                        .background(Color(hex: "#F2F2DB"))
                                                        .cornerRadius(22)
                                                    Image(pet.kind.filter { !$0.isWhitespace })
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                }
                                                .background(Color(hex: "#F2F2DB"))
                                                .cornerRadius(22)
                                            }
                                        }
                                        
                                    }
                                    .frame(width: 480)
                                    .padding(.horizontal)
                                
                           
                                       
                                    
                                
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



//#Preview {
//    StoryReviewView(theme: "Forest", genre: "science fiction", characters: "Parth and sara", mood: "happy")
//}
