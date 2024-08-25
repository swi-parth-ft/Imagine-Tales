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

@MainActor
final class CharacterViewModel: ObservableObject {
    @Published var id = ""
    @Published var name = ""
    @Published var gender = ""
    @Published var emotion = ""
    @Published var age = 23
    
    @AppStorage("childId") var childId: String = "Default Value"
    
    func createChar() async throws {
        let char = Charater(id: "", name: name, gender: gender, emotion: emotion, age: age)
        
        let _ = try await UserManager.shared.addChar(childId: childId, char: char)
    }
}

struct CharacterView: View {
    @StateObject var viewModel = CharacterViewModel()
    @Environment(\.dismiss) var dismiss
    @StateObject var PviewModel = ContentViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFFFF1").ignoresSafeArea()
                VStack {
                    
                        TextField("Name", text: $viewModel.name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        TextField("Gender", text: $viewModel.gender)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        TextField("Emotion", text: $viewModel.emotion)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        Stepper("Age \(viewModel.age)", value: $viewModel.age, in: 3...150)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
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
                .padding()
            }
            .navigationTitle("Add Character")
        }
    }
}

#Preview {
    CharacterView()
}
