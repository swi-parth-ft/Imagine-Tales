//
//  CharacterView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//
import SwiftUI

struct CharacterSelectionView: View {
    var character: Charater
    var width: CGFloat
    @Binding var characters: String
    @Binding var selectedChars: [Charater]

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(characters.contains(character.name) ? (character.gender == "Female" ? Color.pink.opacity(0.5) : Color.blue.opacity(0.5)) : (character.gender == "Female" ? Color.pink.opacity(0.2) : Color.blue.opacity(0.2)))
                    .frame(width: width, height: width)
                    .scaleEffect(characters.contains(character.name) ? 1.1 : 1.0)
                    .shadow(radius: 5)
                VStack {
                    Image(character.gender)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.6, height: width * 0.6)
                        .scaleEffect(characters.contains(character.name) ? 1.1 : 1.0)
                        
                    Text(character.name)
                        .font(.custom("ComicNeue-Bold", size: 24))
                        .multilineTextAlignment(.center)
                        .scaleEffect(characters.contains(character.name) ? 1.1 : 1.0)
                }
            }
        }
        .frame(width: width, height: width)
        .onTapGesture {
            toggleSelection(for: character)
        }
    }

    private func toggleSelection(for character: Charater) {
        if !characters.contains(character.name) {
            selectedChars.append(character)
            withAnimation {
                characters += characters.isEmpty ? character.name : ", \(character.name)"
            }
        } else {
            selectedChars.removeAll { $0.id == character.id }
            withAnimation {
                characters = characters.replacingOccurrences(of: character.name, with: "")
            }
        }
    }
}

struct PetView: View {
    var pet: Pet
    var width: CGFloat
    @Binding var pets: String
    @Binding var selectedPets: [Pet]

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(pets.contains(pet.name) ? getPetColor(pet.kind, 0.5) : getPetColor(pet.kind, 0.2))
                    .frame(width: width, height: width)
                    .scaleEffect(pets.contains(pet.name) ? 1.1 : 1.0)
                    .shadow(radius: 5)
                VStack {
                    Image(pet.kind.filter { !$0.isWhitespace })
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.6, height: width * 0.6)
                        .scaleEffect(pets.contains(pet.name) ? 1.1 : 1.0)
                    
                    Text(pet.name)
                        .font(.custom("ComicNeue-Bold", size: 24))
                        .multilineTextAlignment(.center)
                        .scaleEffect(pets.contains(pet.name) ? 1.1 : 1.0)
                }
            }
        }
        .frame(width: width, height: width)
        .onTapGesture {
            toggleSelection(for: pet)
        }
    }

    private func toggleSelection(for pet: Pet) {
        if !pets.contains(pet.name) {
            selectedPets.append(pet)
            withAnimation {
                pets += pets.isEmpty ? pet.name : ", \(pet.name)"
            }
        } else {
            selectedPets.removeAll { $0.id == pet.id }
            withAnimation {
                pets = pets.replacingOccurrences(of: pet.name, with: "")
            }
        }
    }
    
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
