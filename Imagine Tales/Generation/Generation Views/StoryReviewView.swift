//
//  StoryReviewView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/19/24.
//

import SwiftUI
import Vortex

// The StoryReviewView presents a summary of a story's theme, genre, characters, pets, and mood.
struct StoryReviewView: View {

    // Variables holding the details of the story for review
    @Binding var theme: String                   // The chosen theme of the story
    @Binding var genre: String                   // The chosen genre of the story
    var characters: String              // A string of selected characters
    var petString: String               // A string of selected pets
    var chars: [Charater]               // Array of Character objects
    var pets: [Pet]                     // Array of Pet objects
    @Binding var mood: String                    // The chosen mood of the story
    @Binding var moodEmoji: String               // Emoji representing the mood of the story
    @Environment(\.colorScheme) var colorScheme
    let genres = ["Adventure", "Fantasy", "Mystery", "Romance", "Science Fiction", "Horror", "Thriller","Historical", "Comedy", "Drama", "Detective", "Dystopian", "Fairy Tale", "Magical Realism", "Biography", "Coming-of-Age", "Action", "Paranormal", "Supernatural", "Western"]

    let themes = ["Magical Adventures", "Underwater Mysteries", "Dinosaur Discoveries", "Space Explorers", "FairyTale Kingdoms", "Superhero Chronicles", "Enchanted Forests", "Pirate Quests", "Animal Friends", "Time Traveling", "Monster Mischief", "Robot Wonders", "Mystical Creatures", "Lost Worlds", "Magical SchoolDays", "Jungle Safari", "Winter Wonderland", "Desert Dunes", "Alien Encounter", "Wizard’s Secrets"]
    
    let moods = ["Happy", "Sad", "Excited", "Scared", "Curious", "Brave", "Funny", "Surprised", "Angry", "Relaxed", "Adventurous", "Mysterious", "Silly", "Love", "Confused", "Proud", "Nervous", "Sleepy", "Joyful", "Shy"]
    let moodEmojis = ["😊", "😢", "😃", "😱", "🤔", "💪", "😄", "😮", "😠", "😌", "🧭", "🕵️‍♂️", "🤪", "❤️", "😕", "😎", "😬", "😴", "😁", "😳"]
    @State private var shouldBurst: Bool = false // State to trigger the confetti burst
    @EnvironmentObject var orientation: OrientationManager
    func getRandom() {
        let totalDuration = 4.0 // Total duration for changing
        let interval = 0.7 // Change interval
        let iterations = Int(totalDuration / interval) // Number of updates

        for i in 0..<iterations {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(i))) {
                withAnimation {
                    theme = themes.randomElement()!
                    genre = genres.randomElement()!
                    
                    // Get random mood and corresponding emoji
                    if let randomMood = moods.randomElement(),
                       let moodIndex = moods.firstIndex(of: randomMood) {
                        mood = randomMood
                        moodEmoji = moodEmojis[moodIndex] // Ensure moodEmojis has the same count as moods
                    }
                }
            }
        }
        shouldBurst = true
    }
    var body: some View {
        VStack(spacing: 20) {
            
            // Prompt section displaying a sentence summarizing the user's choices
            ZStack {
                // Create a rounded rectangle border for the prompt area
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(hex: "#F2F2DB"), lineWidth: 2)
                    .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading) {
                        // Header with "Prompt" label and shuffle icon
                        HStack {
                            Text("Prompt")
                                .font(.system(size: 28))
                            Spacer()
                            Image(systemName: "shuffle") // Icon to shuffle or randomize selections
                                .font(.system(size: 24))
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    getRandom()
                                }
                        }
                        .padding(.horizontal, 20) // Padding for the header

                        Divider() // Divider line for separation
                            .background(Color(hex: "#F2F2DB"))

                        // Descriptive text summarizing the user's choices for theme, genre, characters, and pets
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Awesome! You've chosen to create a ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text(theme)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#FF6F61")) + // Highlighting the theme
                                Text(" story with genre of ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text(genre)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.cyan) + // Highlighting the genre
                                Text(" with ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text(characters.isEmpty ? "no" : characters)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.purple) + // Highlighting the characters
                                Text(characters.isEmpty ? " characters " : " as characters ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20) // Padding for the text

                            HStack {
                                Text(petString.isEmpty ? "" : " with pets ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text(petString.isEmpty ? "" : "\(petString).")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.purple) + // Highlighting the pets
                                Text(" The mood of your story will be ")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary) +
                                Text("\(mood)!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.yellow) // Highlighting the mood
                            }
                            .padding(.horizontal, 20) // Padding for the second line of text
                        }
                    }
                    .padding() // Padding around the entire prompt area
                }
            }
            
            // Story details section displaying the theme, mood, genre, characters, and pets
            ZStack {
                // Background for the story details
                RoundedRectangle(cornerRadius: 22)
                    .fill(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#F2F2DB"))
                    .frame(height: UIDevice.current.orientation.isLandscape ? 300 : 500)
                
                VortexViewReader { proxy in
                    ZStack {
                        VortexView(.confetti.makeUniqueCopy()) {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                                .tag("square")
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 16)
                                .tag("circle")
                        }
                        .onChange(of: shouldBurst) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Adjust delay based on animation duration
                                proxy.burst() // Trigger the confetti burst
                                                       }
                                
                                shouldBurst = false // Reset after bursting
                            
                        }
                    }
                }
                .frame(height: UIDevice.current.orientation.isLandscape ? 300 : 500)
                .ignoresSafeArea(edges: .top)
                
                VStack {
                    Spacer()
                    
                    // Display images related to the chosen theme
                    HStack {
                        Image("\(theme.filter { !$0.isWhitespace })1") // First image for the theme
                            .resizable()
                            .scaledToFit()
                            .frame(width: 190)
                        
                        Spacer() // Space between the two images
                        
                        Image("\(theme.filter { !$0.isWhitespace })2") // Second image for the theme
                            .resizable()
                            .scaledToFit()
                            .frame(width: 190)
                    }
                }
                .frame(height: UIDevice.current.orientation.isLandscape ? 300 : 500)
                
                if UIDevice.current.orientation.isLandscape {
                    VStack(alignment: .center) {
                        
                        HStack {
                            // Theme section
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4"))
                                    .frame(height: 100)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Theme") // Label for the theme
                                            .font(.custom("ComicNeue-Bold", size: 20))
                                            .foregroundStyle(.secondary)
                                        Text(theme) // Display the selected theme
                                            .font(.system(size: 24))
                                    }
                                    Spacer() // Spacer to push content to the left
                                    Image("\(theme.filter { !$0.isWhitespace })") // Image related to the theme
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                }
                                .padding() // Padding for the theme section
                            }
                            .padding(.horizontal) // Horizontal padding around the section
                            
                            // Mood and Genre sections
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4"))
                                        .frame(height: 100)
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Mood") // Label for the mood
                                                .font(.custom("ComicNeue-Bold", size: 20))
                                                .foregroundStyle(.secondary)
                                            Text(mood) // Display the selected mood
                                                .font(.system(size: 24))
                                        }
                                        Spacer() // Spacer to push content to the left
                                        Text(moodEmoji) // Display the mood emoji
                                            .font(.system(size: 54))
                                    }
                                    .padding() // Padding for the mood section
                                }
                                .padding() // Padding around the mood section
                                
                                // Genre section
                                ZStack {
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4"))
                                        .frame(height: 100)
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Genre") // Label for the genre
                                                .font(.custom("ComicNeue-Bold", size: 20))
                                                .foregroundStyle(.secondary)
                                            Text(genre) // Display the selected genre
                                                .font(.system(size: 24))
                                        }
                                        Spacer() // Spacer to push content to the left
                                    }
                                    .padding() // Padding for the genre section
                                }
                                .padding() // Padding around the genre section
                            }
                        }
                        
                        // Characters and Pets section
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4").opacity(0.5)) // Semi-transparent background for characters and pets
                                .frame(width: 500, height: 120)
                            
                            HStack {
                                VStack(alignment: .center) {
                                    Text("Characters") // Label for characters
                                        .font(.custom("ComicNeue-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    
                                    // Scrollable list of characters and pets
                                    ScrollView(.horizontal) {
                                        HStack {
                                            // Loop through each character to display their names and images
                                            ForEach(chars) { character in
                                                HStack {
                                                    Text(character.name) // Character's name
                                                        .font(.system(size: 24))
                                                        .padding()
                                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for character name
                                                        .cornerRadius(22) // Rounded corners
                                                    Image(character.gender) // Character's image based on gender
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40) // Frame size for character image
                                                }
                                                .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for the entire character item
                                                .cornerRadius(22) // Rounded corners for the character item
                                            }
                                            
                                            // Loop through each pet to display their names and images
                                            ForEach(pets) { pet in
                                                HStack {
                                                    Text(pet.name) // Pet's name
                                                        .font(.system(size: 24))
                                                        .padding()
                                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for pet name
                                                        .cornerRadius(22) // Rounded corners
                                                    Image(pet.kind.filter { !$0.isWhitespace }) // Pet's image based on type
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40) // Frame size for pet image
                                                }
                                                .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for the entire pet item
                                                .cornerRadius(22) // Rounded corners for the pet item
                                            }
                                        }
                                    }
                                    .frame(width: 480) // Frame width for the scrollable list
                                    .padding(.horizontal) // Padding around the scroll view
                                }
                            }
                            .padding() // Padding around the characters and pets section
                        }
                        .padding(.horizontal) // Horizontal padding around the entire section
                    }
                    .padding() // Padding around the content in the details section
                    .cornerRadius(10) // Rounded corners for the details section
                } else {
                    // Section displaying theme, mood, and genre details
                    VStack(alignment: .center) {
                        
                        // Theme section
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4"))
                                .frame(height: 100)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Theme") // Label for the theme
                                        .font(.custom("ComicNeue-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    Text(theme) // Display the selected theme
                                        .font(.system(size: 24))
                                }
                                Spacer() // Spacer to push content to the left
                                Image("\(theme.filter { !$0.isWhitespace })") // Image related to the theme
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                            }
                            .padding() // Padding for the theme section
                        }
                        .padding(.horizontal) // Horizontal padding around the section
                        
                        // Mood and Genre sections
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4"))
                                    .frame(height: 100)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Mood") // Label for the mood
                                            .font(.custom("ComicNeue-Bold", size: 20))
                                            .foregroundStyle(.secondary)
                                        Text(mood) // Display the selected mood
                                            .font(.system(size: 24))
                                    }
                                    Spacer() // Spacer to push content to the left
                                    Text(moodEmoji) // Display the mood emoji
                                        .font(.system(size: 54))
                                }
                                .padding() // Padding for the mood section
                            }
                            .padding() // Padding around the mood section
                            
                            // Genre section
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4"))
                                    .frame(height: 100)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Genre") // Label for the genre
                                            .font(.custom("ComicNeue-Bold", size: 20))
                                            .foregroundStyle(.secondary)
                                        Text(genre) // Display the selected genre
                                            .font(.system(size: 24))
                                    }
                                    Spacer() // Spacer to push content to the left
                                }
                                .padding() // Padding for the genre section
                            }
                            .padding() // Padding around the genre section
                        }
                        
                        // Characters and Pets section
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(colorScheme == .dark ? Color(hex: "#B4B493").opacity(0.3) : Color(hex: "#F8F8E4").opacity(0.5)) // Semi-transparent background for characters and pets
                                .frame(width: 500, height: 120)
                            
                            HStack {
                                VStack(alignment: .center) {
                                    Text("Characters") // Label for characters
                                        .font(.custom("ComicNeue-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    
                                    // Scrollable list of characters and pets
                                    ScrollView(.horizontal) {
                                        HStack {
                                            // Loop through each character to display their names and images
                                            ForEach(chars) { character in
                                                HStack {
                                                    Text(character.name) // Character's name
                                                        .font(.system(size: 24))
                                                        .padding()
                                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for character name
                                                        .cornerRadius(22) // Rounded corners
                                                    Image(character.gender) // Character's image based on gender
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40) // Frame size for character image
                                                }
                                                .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for the entire character item
                                                .cornerRadius(22) // Rounded corners for the character item
                                            }
                                            
                                            // Loop through each pet to display their names and images
                                            ForEach(pets) { pet in
                                                HStack {
                                                    Text(pet.name) // Pet's name
                                                        .font(.system(size: 24))
                                                        .padding()
                                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for pet name
                                                        .cornerRadius(22) // Rounded corners
                                                    Image(pet.kind.filter { !$0.isWhitespace }) // Pet's image based on type
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40) // Frame size for pet image
                                                }
                                                .background(colorScheme == .dark ? Color(hex: "#9F9F74") : Color(hex: "#F2F2DB")) // Background color for the entire pet item
                                                .cornerRadius(22) // Rounded corners for the pet item
                                            }
                                        }
                                    }
                                    .frame(width: 480) // Frame width for the scrollable list
                                    .padding(.horizontal) // Padding around the scroll view
                                }
                            }
                            .padding() // Padding around the characters and pets section
                        }
                        .padding(.horizontal) // Horizontal padding around the entire section
                    }
                    .padding() // Padding around the content in the details section
                    .cornerRadius(10) // Rounded corners for the details section
                }
            }
        }
        .padding() // Padding for the outer view
        .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
    }
}
