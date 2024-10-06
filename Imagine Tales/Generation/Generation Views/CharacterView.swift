//
//  CharacterView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/24/24.
//

import SwiftUI



struct CharacterView: View {
    // Instantiate the ViewModel as a StateObject so it persists during view updates
    @StateObject var viewModel = CharacterViewModel()
    
    // Dismiss environment for dismissing the current view
    @Environment(\.dismiss) var dismiss
    
    // Another ViewModel (assumed to handle fetching characters and pets)
    @StateObject var PviewModel = ContentViewModel()
    
    // State to track if the user is in pet creation mode
    @State private var isSelectionPet = false
    
    // Available emotions for the character selection
    let emotions = [
        "Happy", "Sad", "Angry", "Fearful", "Surprised", "Disgusted", "Excited",
        "Anxious", "Content", "Bored", "Confused", "Frustrated", "Grateful",
        "Jealous", "Proud", "Lonely", "Hopeful", "Amused", "Love", "Hate",
        "Embarrassed", "Nervous", "Curious", "Relieved"
    ]
    
    // Corresponding emojis for each emotion
    let emotionEmojis = [
        "😊", "😢", "😡", "😨", "😲", "🤢", "🤩", "😰", "😌", "😒", "😕", "😤",
        "🙏", "😒", "😌", "😔", "🌈", "😆", "❤️", "💢", "😳", "😬", "🤔", "😅"
    ]
    
    // Available pets for selection
    let pets = ["Dog", "Cat", "Dragon", "Monkey", "Wolf", "Tiger", "Unicorn", "Baby Dinosaur"]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color for the entire screen
//                Color(hex: "#FFFFF1").ignoresSafeArea()
                BackGroundMesh().ignoresSafeArea()
                
                // Check if in pet creation mode or character creation mode
                if !isSelectionPet {
                    // Character creation view
                    VStack {
                        // TextField for entering character name
                        HStack {
                            TextField("Name", text: $viewModel.name)
                                .padding()
                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white.opacity(0.8)) // Semi-transparent background
                                .cornerRadius(22)
                                .frame(width: UIScreen.main.bounds.width * 0.4)
                            
                            Spacer()
                            
                            // Gender selection buttons
                            HStack {
                                Image("Male")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .scaleEffect(viewModel.gender == "Male" ? 1.3 : 1) // Scale based on selection
                                    .onTapGesture { withAnimation { viewModel.gender = "Male" } }
                                
                                Image("Female")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .scaleEffect(viewModel.gender == "Female" ? 1.3 : 1) // Scale based on selection
                                    .onTapGesture { withAnimation { viewModel.gender = "Female" } }
                            }
                            
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.5,height: 70)
                        
                        // Display selected gender and emotion
                        Text("\(viewModel.gender == "Male" ? "He" : "She") is a \(viewModel.emotion) Person")
                            .font(.custom("ComicNeue-Bold", size: 20))
                            .padding(.top)
                        
                        // Horizontal scroll view for selecting emotion
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Loop through emotions and display each with its corresponding emoji
                                ForEach(emotions.indices, id: \.self) { index in
                                    let emotion = emotions[index]
                                    let emoji = emotionEmojis[index]
                                    
                                    VStack {
                                        Circle()
                                            .fill(Color.yellow.opacity(emotion == viewModel.emotion ? 0.5 : 0.3))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                VStack {
                                                    Text(emoji) // Display emoji
                                                        .font(.largeTitle)
                                                    Text(emotion) // Display emotion text
                                                        .font(.caption)
                                                }
                                            )
                                            .onTapGesture { withAnimation { viewModel.emotion = emotion } } // Update selected emotion
                                            .scaleEffect(emotion == viewModel.emotion ? 1.1 : 1.0)
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                            .padding([.leading, .vertical])
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        
                        
                        // Age selection label
                        Text("Age").font(.custom("ComicNeue-Bold", size: 20))
                        
                        // Age selection with + and - buttons
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 70, height: 70)
                                Image(systemName: "minus").font(.system(size: 30)) // Decrease age button
                            }
                            .onTapGesture { if viewModel.age > 3 { viewModel.age -= 1 } }
                            
                           
                            
                            // Display current age
                            Text("\(viewModel.age)").font(.custom("ComicNeue-Bold", size: 70)).padding(.horizontal)
                            
                            
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 70, height: 70)
                                Image(systemName: "plus").font(.system(size: 30)) // Increase age button
                            }
                            .onTapGesture { if viewModel.age < 88 { viewModel.age += 1 } }
                        }
                        
                        // Create character button
                        Button {
                            Task {
                                do {
                                    // Try to create the character and update the list
                                    try await viewModel.createChar()
                                    try PviewModel.getCharacters()
                                    dismiss() // Dismiss the view after successful creation
                                } catch {
                                    print(error.localizedDescription) // Handle errors
                                }
                            }
                        } label: {
                            Text("Create Character")
                                .foregroundStyle(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                        .cornerRadius(12)
                    }
                    .padding()
                } else {
                    // Main container for pet creation view
                    VStack {
                        // VStack for pet name input and pet selection
                        VStack {
                            // TextField for entering pet name
                            TextField("Pet Name", text: $viewModel.petName)
                                .padding() // Padding around the TextField
                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white.opacity(0.8)) // Semi-transparent white background
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .shadow(radius: 2) // Slight shadow around the TextField
                                .cornerRadius(22) // Rounded corners
                                .tint(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#FF6F61")) // Custom tint color for text cursor
                            
                            
                            // Display the selected pet type dynamically
                            Text("It's a \(viewModel.petKind)")
                                .font(.custom("ComicNeue-Bold", size: 20)) // Custom font for pet type text
                                .padding(.top) // Padding at the top
                            
                            // ScrollView to display available pet options horizontally
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // Iterate over the list of pets
                                    ForEach(pets, id: \.self) { pet in
                                        VStack {
                                            // Circle representing the pet selection
                                            Circle()
                                                .fill(Color.blue.opacity(pet == viewModel.petKind ? 0.5 : 0.3)) // Highlight if selected
                                                .frame(width: 140, height: 140) // Size of each circle
                                                .overlay(
                                                    VStack {
                                                        // Display pet image dynamically by filtering spaces in name
                                                        Image(pet.filter { !$0.isWhitespace })
                                                            .resizable()
                                                            .scaledToFit() // Maintain aspect ratio
                                                            .frame(width: 70, height: 70) // Image size
                                                        
                                                        // Pet name below the image
                                                        Text(pet)
                                                            .font(.custom("ComicNeue-Bold", size: 16)) // Custom font for pet names
                                                            .multilineTextAlignment(.center) // Center align the text
                                                    }
                                                )
                                            // On tap, update the selected pet with animation
                                                .onTapGesture {
                                                    withAnimation {
                                                        viewModel.petKind = pet
                                                    }
                                                }
                                            // Scale up if selected, otherwise normal size
                                                .scaleEffect(pet == viewModel.petKind ? 1.1 : 1.0)
                                        }
                                    }
                                }
                                .padding() // Padding for the horizontal stack
                            }
                            .padding(.leading)
                            .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        
                        // Button for creating the pet
                        Button {
                            // Perform asynchronous task to create the pet
                            Task {
                                do {
                                    // Attempt to create the pet and fetch updated list
                                    try await viewModel.createPet()
                                    try PviewModel.getPets()
                                    dismiss() // Dismiss the view on success
                                } catch {
                                    print(error.localizedDescription) // Print error if something goes wrong
                                }
                            }
                        } label: {
                            Text("Create Pet")
                                .foregroundStyle(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                        }
                        .padding() // Padding around the button
                        .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61")) // Custom background color for button
                        .cornerRadius(12) // Rounded corners for the button
                    }
                    .padding() // Padding for the whole VStack
                }
                
            }
            // Dynamically set the navigation title based on whether the user is adding a pet or a person
            .navigationTitle(isSelectionPet ? "Add Pet 🐶" : "Add Person 👨🏻‍🎤")
            
            // Toolbar containing a toggle button to switch between adding a pet and adding a person
            .toolbar {
                // Button label dynamically changes based on the current mode (pet or person)
                Button(isSelectionPet ? "Add Person 👨🏻‍🎤" : "Add Pet 🐶") {
                    // Toggle between pet and person selection with a smooth animation
                    withAnimation {
                        isSelectionPet.toggle()
                    }
                }
                // Padding around the button
                .padding()
                // Extra top padding for spacing
                .padding(.top, 20)
                // Custom background color for the button
                .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                // White text color for the button label
                .foregroundStyle(.white)
                // Custom font for the button label
                .font(.custom("ComicNeue-Bold", size: 22))
                // Rounded corners for the button
                .cornerRadius(22)
            }
        }
    }
}

#Preview {
    CharacterView()
}


