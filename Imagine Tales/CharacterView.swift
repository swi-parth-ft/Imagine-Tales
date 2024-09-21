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
    @Published var gender = ""
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
    
    let pets = ["Dog", "Cat", "Horse", "Dragon", "Unicorn", "Baby Dinasour"]
    
    var body: some View {
        NavigationStack {
            ZStack {
               Color(hex: "#FFFFF1").ignoresSafeArea()
               
                    
                    if !isSelectionPet {
                        VStack {
                            VStack {
                                Button("Add Pet") {
                                    isSelectionPet.toggle()
                                }
                                .customBackground()
                                TextField("Name", text: $viewModel.name)
                                    .customBackground()
                                
                                
                                Picker("Gender", selection: $viewModel.gender) {
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                }
                                .pickerStyle(.segmented)
                                .customBackground()
                                
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(emotions, id: \.self) { emotion in
                                            VStack {
                                                Circle()
                                                    .fill(Color.blue.opacity(emotion == viewModel.emotion ? 0.5 : 0.3))
                                                    .frame(width: 100, height: 100)
                                                    .overlay(
                                                        Text(emotion)
                                                            .font(.caption)
                                                            .foregroundColor(.black)
                                                            .multilineTextAlignment(.center)
                                                            .padding(10)
                                                    )
                                                    .onTapGesture {
                                                        withAnimation {
                                                            viewModel.emotion = emotion
                                                        }
                                                    }
                                                    .scaleEffect(emotion == viewModel.emotion ? 1.1 : 1.0)
                                            }
                                            
                                            
                                        }
                                    }
                                    .padding()
                                }
                                .customBackground()
                                Stepper("Age \(viewModel.age)", value: $viewModel.age, in: 3...150)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                
                                
                                
                            }
                            .background(.white)
                            
                            
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
                        .cornerRadius(22)
                        .padding()
                    } else {
                        VStack {
                            VStack {
                                Button("Add Person") {
                                    isSelectionPet.toggle()
                                }
                                .customBackground()
                                TextField("Pet Name", text: $viewModel.petName)
                                    .customBackground()
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(pets, id: \.self) { pet in
                                            VStack {
                                                Circle()
                                                    .fill(Color.blue.opacity(pet == viewModel.petKind ? 0.5 : 0.3))
                                                    .frame(width: 100, height: 100)
                                                    .overlay(
                                                        Text(pet)
                                                            .font(.caption)
                                                            .foregroundColor(.black)
                                                            .multilineTextAlignment(.center)
                                                            .padding(10)
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
                                .customBackground()
                        
                                
                                
                                
                            }
                            .background(.white)
                            
                            
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
                    }
            
            }
            .navigationTitle("Add Character")
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
