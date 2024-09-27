//
//  CharacterViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI
// ViewModel for handling character and pet creation logic
@MainActor
final class CharacterViewModel: ObservableObject {
    // Published properties to track character details and update the UI when they change
    @Published var id = ""
    @Published var name = ""
    @Published var gender = "Male" // Default to "Male"
    @Published var emotion = "Happy" // Default to "Happy"
    @Published var age = 23 // Default age
    @Published var petId = ""
    @Published var petName = ""
    @Published var petKind = "Dog" // Default pet type is "Dog"
    
    // AppStorage to persist childId in user defaults
    @AppStorage("childId") var childId: String = "Default Value"
    
    // Function to create a new character asynchronously
    func createChar() async throws {
        // Create a new character object with the current state values
        let char = Charater(id: "", name: name, gender: gender, emotion: emotion, age: age)
        
        // Use UserManager to save the character under the child's ID
        let _ = try await UserManager.shared.addChar(childId: childId, char: char)
    }
    
    // Function to create a new pet asynchronously
    func createPet() async throws {
        // Create a new pet object with the current state values
        let pet = Pet(id: "", name: petName, kind: petKind)
        
        // Use UserManager to save the pet under the child's ID
        let _ = try await UserManager.shared.addPet(childId: childId, pet: pet)
    }
}
