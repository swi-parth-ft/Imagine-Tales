//
//  ContentView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/6/24.
//

import SwiftUI
import DotLottie
import FirebaseVertexAI
import FirebaseFirestore
import FirebaseStorage
import Neumorphic

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var storyViewModel = StoryViewModel()
    
    @State private var characters = ""
    @State private var pets = ""
    @State private var char = ""
    @State private var genre = "Detective"
    @State private var theme = "Underwater Mysteries"
    @State private var story = ""
    @State private var isLoading = false
    @State private var words:[String] =  []
    @State private var petWords:[String] =  []
    @State private var loaded = false
    @State private var isRandom = false
    @State private var scale: CGFloat = 1.0
    @State private var generatedImage: UIImage? = nil
    @State private var isImageLoading = true
    @State private var promptForImage = ""
    @State private var displayPrompt = "I want to generate a story book of"
    let vertex = VertexAI.vertexAI()
    
    let genres = ["Adventure", "Fantasy", "Mystery", "Romance", "Science Fiction", "Horror", "Thriller","Historical", "Comedy", "Drama", "Detective", "Dystopian", "Fairy Tale", "Magical Realism", "Biography", "Coming-of-Age", "Action", "Paranormal", "Supernatural", "Western"]

    let themes = ["Magical Adventures", "Underwater Mysteries", "Dinosaur Discoveries", "Space Explorers", "FairyTale Kingdoms", "Superhero Chronicles", "Enchanted Forests", "Pirate Quests", "Animal Friends", "Time Traveling", "Monster Mischief", "Robot Wonders", "Mystical Creatures", "Lost Worlds", "Magical SchoolDays", "Jungle Safari", "Winter Wonderland", "Desert Dunes", "Alien Encounter", "Wizard’s Secrets"]

    let themeColors: [Color] = [.purple, .teal, .green, .blue, .pink, .red, .green, .brown, .orange, .indigo, .purple, .gray, .purple, .green, .yellow, .green, .blue, .orange, .yellow, .gray]
    
    @State private var isSelectingTheme = true
    @State private var isSelectingGenre = false
    @State private var isAddingNames = false
    @State private var formattedChars = ""
    @State private var formattedPets = ""
    @State private var isAddingChar = false
    
    @State private var selectedChars: [Charater] = []
    @State private var selectedPets: [Pet] = []
    
    @State private var storyChunk: [(String, UIImage)] = []
    @State private var chunkOfText = ""
    @State private var nextKey = false
    @State private var finishKey = false
    @State private var continueStory = ""
    @State private var isLoadingChunk = true
    @State private var storyTextItem: [StoryTextItem] = []
    @AppStorage("childId") var childId: String = "Default Value"
    @State private var title = ""
    @State private var isGeneratingTitle = false
    @State private var isLoadingImage = false
    @State private var isLoadingTextPart = false
    @State private var mood = "Brave"
    let moods = ["Happy", "Sad", "Excited", "Scared", "Curious", "Brave", "Funny", "Surprised", "Angry", "Relaxed", "Adventurous", "Mysterious", "Silly", "Love", "Confused", "Proud", "Nervous", "Sleepy", "Joyful", "Shy"]
    let moodEmojis = ["😊", "😢", "😃", "😱", "🤔", "💪", "😄", "😮", "😠", "😌", "🧭", "🕵️‍♂️", "🤪", "❤️", "😕", "😎", "😬", "😴", "😁", "😳"]
  @State private var selectedEmoji = ""
    @State private var isSelectingMood = false
    @State private var displayedText: String = ""
        @State private var charIndex: Int = 0

    @State private var summary: String = ""
    @State private var isGeneratingSummary = false
  
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    
    @State private var isGeneratingCover = true
    @State private var preview = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
               
                VStack {

                    //MARK: Story Loaded
                    if loaded || isLoading {
                        GeneratingProcessView(isLoading: $isLoading, words: $words, characters: $characters, genre: $genre, story: $story, theme: $theme, loaded: $loaded, isRandom: $isRandom, selectedChars: $selectedChars, storyChunk: $storyChunk, nextKey: $nextKey, finishKey: $finishKey, continueStory: $continueStory, chunkOfText: $chunkOfText, isLoadingChunk: $isLoadingChunk, isGeneratingTitle: $isGeneratingTitle, title: $title, displayedText: $displayedText, storyTextItem: $storyTextItem, isLoadingImage: $isLoadingImage, isLoadingTextPart: $isLoadingTextPart, mood: $mood, summary: $summary, promptForImage: $promptForImage, isImageLoading: $isImageLoading, selectedPets: $selectedPets, isGeneratingCover: $isGeneratingCover, generatedImage: $generatedImage, isSelectingTheme: $isSelectingTheme, preview: $preview)
                            .padding(.bottom, 50)
                    }
                    //MARK: Taking Input
                    if !isLoading && !loaded{
                        ZStack {
                            //MARK: Selecting Theme
                            if isSelectingTheme {
                                ThemeSelectionView(
                                    isSelectingTheme: $isSelectingTheme,
                                    theme: $theme,
                                    themes: themes,
                                    themeColors: themeColors
                                )
                            }
                            
                            //MARK: Selecting Genre
                            else if isSelectingGenre {
                                GenreSelectionView(
                                    isSelectingGenre: $isSelectingGenre,
                                    genre: $genre,
                                    genres: genres
                                )
                            }
                            
                            //MARK: Selecting Mood
                            else if isSelectingMood {
                                MoodSelectionView(
                                    isSelectingMood: $isSelectingMood,
                                    mood: $mood,
                                    selectedEmoji: $selectedEmoji,
                                    moods: moods,
                                    moodEmojis: moodEmojis
                                )
                            }
                            
                            //MARK: Adding Charactors
                            else if isAddingNames {
                                GeometryReader { geometry in
                                    let width = (geometry.size.width - 40) / 5
                                    
                                    ScrollView {
                                        VStack {
                                            Section(header: Text("Persons").font(.custom("ComicNeue-Bold", size: 30))) {
                                                if viewModel.characters.isEmpty {
                                                    // Placeholder when no stories are available
                                                    ContentUnavailableView {
                                                        Label("No Characters Yet", systemImage: "person.fill")
                                                    } description: {
                                                        Text("Create your first character")
                                                    } actions: {
                                                    }
                                                    .frame(height: 300)
                                                    .listRowBackground(Color.clear)
                                                } else {
                                                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(width), spacing: 17), count: 4), spacing: 10) {
                                                        ForEach(viewModel.characters.indices, id: \.self) { index in
                                                            CharacterSelectionView(character: viewModel.characters[index], width: width, characters: $characters, selectedChars: $selectedChars)
                                                                .contextMenu {
                                                                    Button(action: {
                                                                        viewModel.deleteChar(char: viewModel.characters[index])
                                                                        Task { do { try viewModel.getCharacters() } catch { print(error.localizedDescription) } }
                                                                    }) {
                                                                        Label("Delete", systemImage: "trash")
                                                                    }
                                                                }
                                                                .offset(x: (index / 4) % 2 == 0 ? 0 : width / 2)
                                                        }
                                                    }
                                                    .padding()
                                                }
                                            }
                                            
                                            Section(header: Text("Pets").font(.custom("ComicNeue-Bold", size: 30))) {
                                                if viewModel.pets.isEmpty {
                                                    // Placeholder when no stories are available
                                                    ContentUnavailableView {
                                                        Label("No Pets Yet", systemImage: "pawprint.fill")
                                                    } description: {
                                                        Text("Create your first Pet")
                                                    } actions: {
                                                    }
                                                    .frame(height: 300)
                                                    .listRowBackground(Color.clear)
                                                } else {
                                                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(width), spacing: 17), count: 4), spacing: -10) {
                                                        ForEach(viewModel.pets.indices, id: \.self) { index in
                                                            PetView(pet: viewModel.pets[index], width: width, pets: $pets, selectedPets: $selectedPets)
                                                                .contextMenu {
                                                                    Button(action: {
                                                                        viewModel.deletePet(pet: viewModel.pets[index])
                                                                        Task { do { try viewModel.getPets() } catch { print(error.localizedDescription) } }
                                                                    }) {
                                                                        Label("Delete", systemImage: "trash")
                                                                    }
                                                                }
                                                                .offset(x: (index / 4) % 2 == 0 ? 0 : width / 2)
                                                        }
                                                    }
                                                    .padding()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 90)
                                    .onAppear {
                                        Task {
                                            do {
                                                try viewModel.getCharacters()
                                                try viewModel.getPets()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                                .padding()
                            }
                            
                            //MARK: Preview
                            else if preview {
                                VStack {
                                    StoryReviewView(theme: theme, genre: genre, characters: characters, petString: pets, chars: selectedChars, pets: selectedPets, mood: mood, moodEmoji: selectedEmoji)
                                        .opacity(preview ? 1.0 : 0.0)
                                        .scaleEffect(preview ? 1.0 : 0.0) // Scale effect on the text when selected
                                        .animation(.easeInOut(duration: 0.6), value: preview) // Animate the scaling
      
                                }
                                
                                .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                                    
                            }
                            
                            VStack {
                                //MARK: Title Section
                                HStack {
                                    
                                    //Selection Title
                                    Text(isSelectingTheme ? "Select Theme" : isSelectingGenre ? "Select Genre" : isAddingNames ? "Select Characters" : isSelectingMood ? "Select Mood" : "")
                                        .font(.custom("ComicNeue-Bold", size: 32))
                                        .frame(height: 75)
                                        .padding()
                                    
                                    Spacer()
                                    
                                    if isAddingNames {
                                        Button("Add Character", systemImage: "plus") {
                                            isAddingChar = true
                                        }
                                        .font(.custom("ComicNeue-Bold", size: 24))
                                        .padding()
                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#D0FFD0"))
                                        .cornerRadius(22)
                                        .shadow(radius: 10)
                                    }
                                    
                                    
                                }
                                .padding()
                                
                                Spacer()
                                //MARK: Buttons
                            
                                    VStack {
                                        HStack {
                                            if !isSelectingTheme {
                                               
                                                    Button {
                                                        if isAddingNames {
                                                            withAnimation {
                                                                isSelectingMood = true
                                                                isAddingNames = false
                                                            }
                                                        } else if isSelectingGenre {
                                                            withAnimation {
                                                                isSelectingTheme = true
                                                                isSelectingGenre = false
                                                            }
                                                        } else if isSelectingMood {
                                                            withAnimation {
                                                                isSelectingMood = false
                                                                isSelectingGenre = true
                                                            }
                                                        } else if preview {
                                                            withAnimation {
                                                                preview = false
                                                                isSelectingTheme = true
                                                            }
                                                        }
                                                    } label: {
                                                        HStack(alignment: .center) {
                                                            
                                                            Text("Back")
                                                                .font(.custom("ComicNeue-Bold", size: 24))
                                                            Image(systemName: "arrowshape.turn.up.backward.fill")
                                                                .font(.system(size: 24))
                                                            
                                                        }
                                                        .padding()
                                                        .frame(width: UIScreen.main.bounds.width * 0.2)
                                                        .background(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#F2F2DB"))
                                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                        .cornerRadius(16)
                                                    }
                                              
                                            }
                                            
                                            Button {
                                                if isSelectingTheme {
                                                    withAnimation {
                                                        isSelectingTheme = false
                                                        isSelectingGenre = true
                                                    }
                                                } else if isSelectingGenre {
                                                    withAnimation {
                                                        isSelectingGenre = false
                                                        isSelectingMood = true
                                                    }
                                                } else if isSelectingMood {
                                                    withAnimation {
                                                        isSelectingMood = false
                                                        isAddingNames = true
                                                    }
                                                } else if isAddingNames {
                                                    isAddingNames = false
                                                    preview = true
                                                } else if preview {
                                                    generatedImage = nil
                                                    isLoading = true
                                                    isLoadingChunk = true
                                                    
                                                    Task {
                                                        do {
                                                            try await generateStoryWithGemini()
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Text(preview ? "Generate" : "Next")
                                                        .font(.custom("ComicNeue-Bold", size: 24))
                                                    Image(systemName: preview ? "wand.and.stars" : "arrowtriangle.right.fill")
                                                }
                                                .padding()
                                                .frame(width: UIScreen.main.bounds.width * 0.6)
                                                .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                                .foregroundColor(.white)  // Use .foregroundColor for text/icons
                                                .cornerRadius(16)
                                            }
                                            .contentShape(Rectangle())
                                        }
                                    }
                                
                            }
                        }
                        .padding(.bottom, 50)
                    }
                        
                }
                .onAppear {
                    withAnimation {
                        scale = 1.1
                    }
                    
                    storyViewModel.fetchChild(ChildId: childId)
                }
                .padding([.leading, .bottom])
                
                
            }
            .navigationTitle(isGeneratingTitle ? "\(title)" : "Imagine a Story")
            .sheet(isPresented: $isAddingChar, onDismiss: {
                // This code will run when the sheet is dismissed
                Task {
                    do {
                        try viewModel.getCharacters()
                        try viewModel.getPets()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }) {
                CharacterView()
            }
        }
    }
    
    
    
    // Function to extract words from a given input string, separating them by commas and the word "and"
    func extractWords(from input: String) -> [String] {
        // Define the separators to split by (commas and variations of "and")
        let separators = [",", " and ", " and"]
        var words = input
        
        // Replace each separator with a comma
        for separator in separators {
            words = words.replacingOccurrences(of: separator, with: ",")
        }
        
        // Split the modified string into an array by commas
        let wordArray = words.split(separator: ",")
        
        // Trim any leading/trailing whitespace from each word and filter out any empty strings
        return wordArray.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    // Function to generate an image using the OpenAI API
    func generateImageUsingOpenAI() {
        // Start an animation while the image is loading
        
            isLoadingImage = true
        
        
        // Use the provided prompt to generate the image
        let prompt = promptForImage
        OpenAIService.shared.generateImage(from: prompt) { result in
            // End the animation once the image is no longer loading
            
                isImageLoading = false
            
            
            // Handle the result of the image generation
            switch result {
            case .success(let image):
                // Store the generated image
                self.generatedImage = image
                var iURL = ""
                // Append the image to the current story chunk
                self.storyChunk.append((chunkOfText, image))
                
                // Upload the image to the server and get the URL
                self.storyViewModel.uploadImage(image: image) { url in
                    iURL = url ?? "URL error"
                    print(iURL)
                    // Append the image and associated text to the story item
                    self.storyTextItem.append(StoryTextItem(image: iURL, text: chunkOfText))
                }
                
                // Update the state after successfully generating the image
                
                    self.isLoadingImage = false
                    self.loaded = true
                
                self.isLoadingChunk = false
                
            case .failure(let error):
                // Handle any errors that occur during image generation
                print("Error generating image: \(error.localizedDescription)")
            }
        }
    }

    // Function to generate a short and kid-friendly summary of the story using the Vertex AI generative model
    func generateSummary() async throws {
        // Initialize the Vertex AI generative model
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        // Define a prompt to generate a kid-friendly summary in 25 words
        let prompt = "write me a short and kids friendly summary in 25 words for this story \(continueStory)"
        let response = try await model.generateContent(prompt)
        
        // Update the summary in the UI on the main thread
        if let text = response.text {
            DispatchQueue.main.async {
                self.summary = text
            }
        }
    }

    // Function to generate a story using the Gemini generative model
    func generateStoryWithGemini() async throws {
        isLoadingTextPart = true  // Show loading state for text generation

        // Start loading animation for the image if not generating the title
        if !isGeneratingTitle {
            
                isLoadingImage = true
            
        }
        
        // Extract key words from the characters, genre, and theme
        words = extractWords(from: characters)
        words.append(genre)
        words.append(theme)
        chunkOfText = ""
        
        // Initialize the Vertex AI generative model
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        // Generate a prompt for story generation
        let prompt = generatePrompt()
        let response = try await model.generateContent(prompt)
        
        // Update the story on the main thread
        if let text = response.text {
            DispatchQueue.main.async {
                if isGeneratingTitle {
                    self.title = text  // Set the generated title
                } else {
                    self.story = text  // Update the story text
                    self.chunkOfText = text
                    self.continueStory.append(text)  // Append the new chunk to the ongoing story
                }
            }
            
            // If not generating a title, generate the image prompt
            Task {
                if !isGeneratingTitle {
                    do {
                        try await generateImagePrompt()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            isLoadingTextPart = false  // End loading state for text generation
        }
    }

    // Function to generate a prompt for generating the story based on selected characters, pets, and other attributes
    func generatePrompt() -> String {
        guard !selectedChars.isEmpty else {
            return "Please select at least one character to generate a prompt."
        }

        var prompt = ""
        print(selectedChars)

        // Build a description of the selected characters
        let characterDescriptions = selectedChars.map { character in
            "\(character.name), who is \(character.age) years old and feeling \(character.emotion)"
        }
        let charactersText = characterDescriptions.joined(separator: ", ")
        let lastSeparator = selectedChars.count > 1 ? " and " : ""

        // Build a description of the selected pets, if any
        let petDescriptions = selectedPets.map { pet in
            "\(pet.name), the \(pet.kind)"
        }
        let petsText = petDescriptions.isEmpty ? "" : " along with their pet(s) \(petDescriptions.joined(separator: ", "))"

        // Generate a prompt based on the current state of the story
        if nextKey {
            prompt = "Write the next paragraph of \(continueStory), details: \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together\(petsText). The mood of the story is \(mood). Write in 80 words."
        } else if finishKey && !isGeneratingTitle {
            prompt = "Finish this story: \(continueStory) details: a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together\(petsText). Finish in 100 words."
        } else if isGeneratingTitle {
            prompt = "Give me a story title for this story \(continueStory) in 3 words only. The mood of the story is \(mood). Output should be only 3 words, nothing extra."
        } else {
            prompt = "Write the first paragraph of a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together\(petsText). The mood of the story is \(mood). Write in 80 words."
        }

        print(prompt)
        return prompt
    }

    // Function to generate an image prompt based on the story and characters
    func generateImagePrompt() async throws {
        // Build descriptions of the selected characters
        let characterDescriptions = selectedChars.map { character in
            "\(character.name), a white \(character.gender), who is \(character.age) years old and feeling \(character.emotion)"
        }
        let charactersText = characterDescriptions.joined(separator: ", ")
        
        // Build descriptions of the selected pets
        let petDescription = selectedPets.map { pet in
            "\(pet.name), the \(pet.kind)"
        }
        let petsText = petDescription.joined(separator: ", ")
        let lastSeparator = selectedChars.count > 1 ? " and " : ""
        let petLastSeparator = selectedPets.count > 1 ? " and " : ""

        // Generate the image prompt based on whether it is for a cover or an illustration of a story chunk
        if isGeneratingCover {
            promptForImage = """
                Create a 3D illustration in a soft, playful style with no text based on the following input:
                Story: \(self.story)
                • Theme: \(theme)
                • Genre: \(genre)
                • Characters: \(charactersText)\(lastSeparator)
                • Pets: \(petsText)\(petLastSeparator)
                • Mood: \(mood)

                Each character should have a toy-like, soft appearance with smooth features and expressive faces. The design should clearly reflect their age, gender, and personality. The background should be simple and minimal, allowing the focus to remain on the characters. Their poses and expressions should align with the overall mood of the story, and there should be no text at all in the image nor any signboards or anything.
                """
            print(promptForImage)
            isGeneratingCover = false
            generateImageUsingOpenAI()
        } else {
            promptForImage = """
            Create a 3D illustration in a soft, playful style based on the following paragraph from a children’s story:

            Story: \(self.story)

            Illustrate the following:

                • Characters: \(charactersText)\(lastSeparator)
                • Pets: \(petsText)\(petLastSeparator)

            The background should reflect \(theme), with elements like [insert any key features from the scene like glowing trees, fireflies, etc.]. Make sure the mood of the illustration reflects \(mood) and \(genre), based on the story. Keep the design toy-like, with smooth and rounded features to appeal to children, and there should be no text at all in the image nor any signboards or anything.
            """
            generateImageUsingOpenAI()
            print(promptForImage)
            
                self.isLoading = false
                self.loaded = true
            
        }
    }
    
}

#Preview {
    ContentView(shader: .example)
}

