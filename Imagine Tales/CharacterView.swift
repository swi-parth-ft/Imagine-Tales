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
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("name", text: $viewModel.name)
                    TextField("gender", text: $viewModel.gender)
                    TextField("emotion", text: $viewModel.emotion)
                    Stepper("age", value: $viewModel.age, in: 3...150)
                                    .padding()
                    Text("\(viewModel.age)")
                    Button("Create") {
                        Task {
                            do {
                                try await viewModel.createChar()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
}

#Preview {
    CharacterView()
}
