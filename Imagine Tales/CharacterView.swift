//
//  CharacterView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/24/24.
//

import SwiftUI

struct Charater: Codable, Identifiable {
    let id: String
    let name: String
    let gender: String
    let emotion: String
    let age: Int
}

struct Pet: Codable, Identifiable {
    let id: String
    let name: String
    let kind: String
}

@MainActor
final class CharacterViewModel: ObservableObject {
    @Published var id = ""
    @Published var name = ""
    @Published var gender = "Male"
    @Published var emotion = "Happy"
    @Published var age = 23
    @Published var petId = ""
    @Published var petName = ""
    @Published var petKind = "Dog"
    
    @AppStorage("childId") var childId: String = "Default Value"
    
    func createChar() async throws {
        let char = Charater(id: "", name: name, gender: gender, emotion: emotion, age: age)
        
        let _ = try await UserManager.shared.addChar(childId: childId, char: char)
    }
    
    func createPet() async throws {
        let pet = Pet(id: "", name: petName, kind: petKind)
        
        let _ = try await UserManager.shared.addPet(childId: childId, pet: pet)
    }
}

struct CharacterView: View {
    @StateObject var viewModel = CharacterViewModel()
    @Environment(\.dismiss) var dismiss
    @StateObject var PviewModel = ContentViewModel()
    @State private var isSelectionPet = false
    
    let emotions = [
        "Happy", "Sad", "Angry", "Fearful", "Surprised", "Disgusted", "Excited",
        "Anxious", "Content", "Bored", "Confused", "Frustrated", "Grateful",
        "Jealous", "Proud", "Lonely", "Hopeful", "Amused", "Love", "Hate",
        "Embarrassed", "Nervous", "Curious", "Relieved"
    ]
    
    let emotionEmojis = [
        "😊", // Happy
        "😢", // Sad
        "😡", // Angry
        "😨", // Fearful
        "😲", // Surprised
        "🤢", // Disgusted
        "🤩", // Excited
        "😰", // Anxious
        "😌", // Content
        "😒", // Bored
        "😕", // Confused
        "😤", // Frustrated
        "🙏", // Grateful
        "😒", // Jealous
        "😌", // Proud
        "😔", // Lonely
        "🌈", // Hopeful
        "😆", // Amused
        "❤️", // Love
        "💢", // Hate
        "😳", // Embarrassed
        "😬", // Nervous
        "🤔", // Curious
        "😅"  // Relieved
    ]
    
    let pets = ["Dog", "Cat", "Dragon", "Unicorn", "Baby Dinasour"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFFFF1").ignoresSafeArea()
                
                
                if !isSelectionPet {
                    VStack {
                        VStack {
                            TextField("Name", text: $viewModel.name)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .background(.white.opacity(0.8))
                                .shadow(radius: 2)
                                .cornerRadius(22)
                                .tint(Color(hex: "#FF6F61"))
                            
                            
                            Picker("Gender", selection: $viewModel.gender) {
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(emotions, id: \.self) { emotion in
                                        ForEach(emotions.indices, id: \.self) { index in
                                            let emotion = emotions[index]
                                            let emoji = emotionEmojis[index]
                                            
                                            VStack {
                                                Circle()
                                                    .fill(Color.yellow.opacity(emotion == viewModel.emotion ? 0.5 : 0.3))
                                                    .frame(width: 100, height: 100)
                                                    .overlay(
                                                        VStack {
                                                            Text(emoji) // Emoji for the emotion
                                                                .font(.largeTitle)
                                                            Text(emotion) // Emotion text
                                                                .font(.caption)
                                                                .foregroundColor(.black)
                                                                .multilineTextAlignment(.center)
                                                        }
                                                    )
                                                    .onTapGesture {
                                                        withAnimation {
                                                            viewModel.emotion = emotion
                                                        }
                                                    }
                                                    .scaleEffect(emotion == viewModel.emotion ? 1.1 : 1.0)
                                                    .shadow(radius: 3)
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                .padding()
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.4))
                                        .frame(width: 100, height: 100)
                                        .shadow(radius: 3)
                                    
                                    Image(systemName: "minus")
                                        .font(.system(size: 40))
                                }
                                .onTapGesture {
                                    if viewModel.age > 3 {
                                        withAnimation {
                                            viewModel.age -= 1
                                        }
                                    }
                                }
                                Spacer()
                                Text("\(viewModel.age)")
                                    .font(.system(size: 70))
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.4))
                                        .frame(width: 100, height: 100)
                                        .shadow(radius: 3)
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 40))
                                }
                                .onTapGesture {
                                    if viewModel.age < 88 {
                                        withAnimation {
                                            viewModel.age += 1
                                        }
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                        
                            
                            
                            
                        }
                        .background(.clear)
                        
                        
                        Button("Create") {
                            Task {
                                do {
                                    try await viewModel.createChar()
                                    try PviewModel.getCharacters()
                                    dismiss()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        }
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.5)
                        .background(Color(hex: "#FF6F61"))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                        
                        
                    }
                    .background(.clear)
                    .cornerRadius(22)
                    .padding()
                } else {
                    VStack {
                        VStack {
                            TextField("Pet Name", text: $viewModel.petName)
                                .padding()
                                .frame(width:  UIScreen.main.bounds.width * 0.5)
                                .background(.white.opacity(0.8))
                                .shadow(radius: 2)
                                .cornerRadius(22)
                                .tint(Color(hex: "#FF6F61"))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(pets, id: \.self) { pet in
                                        VStack {
                                            Circle()
                                                .fill(Color.blue.opacity(pet == viewModel.petKind ? 0.5 : 0.3))
                                                .frame(width: 140, height: 140)
                                                .overlay(
                                                    VStack {
                                                        Image(pet.filter { !$0.isWhitespace })
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 70, height: 70)
                                                        Text(pet)
                                                            .font(.custom("ComicNeue-Bold", size: 16))
                                                            .foregroundColor(.black)
                                                            .multilineTextAlignment(.center)
                                                    }
                                                )
                                                .onTapGesture {
                                                    withAnimation {
                                                        viewModel.petKind = pet
                                                    }
                                                }
                                                .scaleEffect(pet == viewModel.petKind ? 1.1 : 1.0)
                                        }
                                        
                                        
                                    }
                                }
                                .padding()
                            }
                            .frame(width:  UIScreen.main.bounds.width * 0.5)
                            
                            
                            
                            
                        }
                        
                        
                        Button("Create") {
                            Task {
                                do {
                                    try await viewModel.createPet()
                                    try PviewModel.getPets()
                                    dismiss()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        }
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.5)
                        .background(Color(hex: "#FF6F61"))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
                
            }
            .navigationTitle(isSelectionPet ? "Add Pet 🐶" : "Add Person 👨🏻‍🎤")
            .toolbar {
                Button(isSelectionPet ? "Add Person 👨🏻‍🎤" : "Add Pet 🐶") {
                    withAnimation {
                        isSelectionPet.toggle()
                    }
                }
                .padding()
                .padding(.top, 20)
                .background(Color(hex: "#FF6F61"))
                .foregroundStyle(.white)
                .font(.custom("ComicNeue-Bold", size: 22))
                .cornerRadius(22)
            }
        }
    }
}

#Preview {
    CharacterView()
}

struct CustomBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
    }
}

extension View {
    func customBackground() -> some View {
        self.modifier(CustomBackgroundModifier())
    }
}
