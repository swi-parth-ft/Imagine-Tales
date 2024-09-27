//  CharacterView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import SwiftUI

// View to handle character selection for the user
struct CharacterSelectionView: View {
    // Character object to display
    var character: Charater
    // Size of the circle representing the character
    var width: CGFloat
    // Binding to a string that tracks selected characters by their names
    @Binding var characters: String
    // Binding to an array of selected character objects
    @Binding var selectedChars: [Charater]

    var body: some View {
        VStack {
            ZStack {
                // Circle background, color and opacity change based on gender and selection status
                Circle()
                    .fill(characters.contains(character.name) ? (character.gender == "Female" ? Color.pink.opacity(0.5) : Color.blue.opacity(0.5)) : (character.gender == "Female" ? Color.pink.opacity(0.2) : Color.blue.opacity(0.2)))
                    .frame(width: width, height: width)
                    // Slightly enlarges if the character is selected
                    .scaleEffect(characters.contains(character.name) ? 1.1 : 1.0)
                    .shadow(radius: 5)
                
                VStack {
                    // Displays character's image based on gender
                    Image(character.gender)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.6, height: width * 0.6)
                        // Enlarges image slightly if the character is selected
                        .scaleEffect(characters.contains(character.name) ? 1.1 : 1.0)
                    
                    // Displays character's name with comic-style font
                    Text(character.name)
                        .font(.custom("ComicNeue-Bold", size: 24))
                        .multilineTextAlignment(.center)
                        // Slightly enlarges text if character is selected
                        .scaleEffect(characters.contains(character.name) ? 1.1 : 1.0)
                }
            }
        }
        .frame(width: width, height: width)
        // Handle tap to select or deselect character
        .onTapGesture {
            toggleSelection(for: character)
        }
    }

    // Function to toggle the selection state of a character
    private func toggleSelection(for character: Charater) {
        if !characters.contains(character.name) {
            // If the character is not selected, add it to the selection
            selectedChars.append(character)
            withAnimation {
                // Append character name to the list of selected names
                characters += characters.isEmpty ? character.name : ", \(character.name)"
            }
        } else {
            // If the character is already selected, remove it
            selectedChars.removeAll { $0.id == character.id }
            withAnimation {
                // Remove the character's name from the selected string
                characters = characters.replacingOccurrences(of: character.name, with: "")
            }
        }
    }
}

// View to handle pet selection for the user
struct PetView: View {
    // Pet object to display
    var pet: Pet
    // Size of the circle representing the pet
    var width: CGFloat
    // Binding to a string that tracks selected pets by their names
    @Binding var pets: String
    // Binding to an array of selected pet objects
    @Binding var selectedPets: [Pet]

    var body: some View {
        VStack {
            ZStack {
                // Circle background, color and opacity change based on pet kind and selection status
                Circle()
                    .fill(pets.contains(pet.name) ? getPetColor(pet.kind, 0.5) : getPetColor(pet.kind, 0.2))
                    .frame(width: width, height: width)
                    // Slightly enlarges if the pet is selected
                    .scaleEffect(pets.contains(pet.name) ? 1.1 : 1.0)
                    .shadow(radius: 5)
                
                VStack {
                    // Displays the pet's kind image, filtered for any whitespace
                    Image(pet.kind.filter { !$0.isWhitespace })
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.6, height: width * 0.6)
                        // Enlarges image slightly if the pet is selected
                        .scaleEffect(pets.contains(pet.name) ? 1.1 : 1.0)
                    
                    // Displays the pet's name with comic-style font
                    Text(pet.name)
                        .font(.custom("ComicNeue-Bold", size: 24))
                        .multilineTextAlignment(.center)
                        // Slightly enlarges text if pet is selected
                        .scaleEffect(pets.contains(pet.name) ? 1.1 : 1.0)
                }
            }
        }
        .frame(width: width, height: width)
        // Handle tap to select or deselect pet
        .onTapGesture {
            toggleSelection(for: pet)
        }
    }

    // Function to toggle the selection state of a pet
    private func toggleSelection(for pet: Pet) {
        if !pets.contains(pet.name) {
            // If the pet is not selected, add it to the selection
            selectedPets.append(pet)
            withAnimation {
                // Append pet name to the list of selected names
                pets += pets.isEmpty ? pet.name : ", \(pet.name)"
            }
        } else {
            // If the pet is already selected, remove it
            selectedPets.removeAll { $0.id == pet.id }
            withAnimation {
                // Remove the pet's name from the selected string
                pets = pets.replacingOccurrences(of: pet.name, with: "")
            }
        }
    }

    // Function to get the appropriate color for each pet kind
    private func getPetColor(_ kind: String, _ opacity: Double) -> Color {
        switch kind {
        case "Dog":
            return Color.brown.opacity(opacity)
        case "Cat":
            return Color.gray.opacity(opacity)
        case "Unicorn":
            return Color.purple.opacity(opacity)
        case "Baby Dinosaur":
            return Color.green.opacity(opacity)
        case "Dragon":
            return Color.red.opacity(opacity)
        default:
            return Color.black.opacity(opacity)
        }
    }
}
