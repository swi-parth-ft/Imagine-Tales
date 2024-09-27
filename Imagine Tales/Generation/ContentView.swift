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

    let themes = ["Magical Adventures", "Underwater Mysteries", "Dinosaur Discoveries", "Space Explorers", "Fairy Tale Kingdoms", "Superhero Chronicles", "Enchanted Forests", "Pirate Quests", "Animal Friends", "Time Traveling", "Monster Mischief", "Robot Wonders", "Mystical Creatures", "Lost Worlds", "Magical School Days", "Jungle Safari", "Winter Wonderland", "Desert Dunes", "Alien Encounter", "Wizard’s Secrets"]

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
    
    var body: some View {
        NavigationStack {
            ZStack {
               
                VStack {

                    //MARK: Story Loaded
                    if loaded || isLoading {
                        GeneratingProcessView(isLoading: $isLoading, words: $words, characters: $characters, genre: $genre, story: $story, theme: $theme, loaded: $loaded, isRandom: $isRandom, selectedChars: $selectedChars, storyChunk: $storyChunk, nextKey: $nextKey, finishKey: $finishKey, continueStory: $continueStory, chunkOfText: $chunkOfText, isLoadingChunk: $isLoadingChunk, isGeneratingTitle: $isGeneratingTitle, title: $title, displayedText: $displayedText, storyTextItem: $storyTextItem, isLoadingImage: $isLoadingImage, isLoadingTextPart: $isLoadingTextPart, mood: $mood, summary: $summary, promptForImage: $promptForImage, isImageLoading: $isImageLoading, selectedPets: $selectedPets, isGeneratingCover: $isGeneratingCover, generatedImage: $generatedImage)
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
                                            
                                            Section(header: Text("Pets").font(.custom("ComicNeue-Bold", size: 30))) {
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
                                    StoryReviewView(theme: theme, genre: genre, characters: formattedChars, petString: formattedPets, chars: selectedChars, pets: selectedPets, mood: mood, moodEmoji: selectedEmoji)
                                        .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                                    
                                    // Buttons
                                    HStack {
                                        Button(action: {
                                            withAnimation {
                                                preview = false
                                                isAddingNames = true
                                            }
                                        }) {
                                            
                                            HStack(alignment: .center) {
                                                
                                                Text("Go Back and Edit")
                                                Image(systemName: "arrowshape.turn.up.backward.fill")
                                                    .font(.system(size: 18))
                                                
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hex: "#F2F2DB"))
                                            .foregroundStyle(.black)
                                            .cornerRadius(16)
                                        }
                                        
                                        Button(action: {
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
                                        }) {
                                            HStack(alignment: .center) {
                                                  
                                                Text("Generate")
                                                    .bold()
                                                Image(systemName: "wand.and.stars")
                                                    .font(.system(size: 18))
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hex: "#FF6F61"))
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                    
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
                                        .background(Color(hex: "#D0FFD0"))
                                        .cornerRadius(22)
                                        .shadow(radius: 10)
                                    }
                                    if isSelectingGenre || isAddingNames || isSelectingMood {
                                       
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
                                                } else {
                                                    withAnimation {
                                                        preview = false
                                                        isAddingNames = true
                                                    }
                                                }
                                            } label: {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.Neumorphic.main).softOuterShadow()
                                                        .frame(width: 75, height: 75)
                                                     
                                                    Image("arrow1")
                                                        .frame(width: 55, height: 55)
                                                    
                                                }
                                            }
                                            .padding()
                                      
                                    }
                                    
                                }
                                .padding()
                                .padding(.bottom, 20)
                                
                                Spacer()
                                //MARK: Buttons
                                if !preview {
                                    VStack {
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
                                            }
                                        } label: {
                                            HStack {
                                                Text("Next")
                                                    .font(.custom("ComicNeue-Bold", size: 24))
                                                Image(systemName: "arrowtriangle.right.fill")
                                            }
                                            .padding()
                                            .frame(width: UIScreen.main.bounds.width * 0.7)
                                            .background(Color(hex: "#FF6F61"))
                                            .foregroundColor(.white)  // Use .foregroundColor for text/icons
                                            .cornerRadius(12)
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
                .padding()
                
                
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
    
    
    
    func extractWords(from input: String) -> [String] {
        // Split the string by commas and the word "and"
        let separators = [",", " and ", " and"]
        var words = input
        
        for separator in separators {
            words = words.replacingOccurrences(of: separator, with: ",")
        }
        
        // Split the string by commas
        let wordArray = words.split(separator: ",")
        
        // Trim whitespace and filter out any empty strings
        return wordArray.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    func generateImageUsingOpenAI() {
        withAnimation(.easeIn(duration: 1.5)) {
            isLoadingImage = true
        }
        let prompt = promptForImage
        OpenAIService.shared.generateImage(from: prompt) { result in
            withAnimation(.easeIn(duration: 1.5)) {
                isImageLoading = false
            }
            switch result {
            case .success(let image):
                
                self.generatedImage = image
                var iURL = ""
                self.storyChunk.append((chunkOfText, image))
                self.storyViewModel.uploadImage(image: image) { url in
                    iURL = url ?? "URL error"
                    print(iURL)
                    self.storyTextItem.append(StoryTextItem(image: iURL, text: chunkOfText))
                }
                withAnimation(.easeIn(duration: 1.5)) {
                    self.isLoadingImage = false
                    self.loaded = true
                }
                self.isLoadingChunk = false
                
            case .failure(let error):
                print("Error generating image: \(error.localizedDescription)")
            }
        }
    }
    
    func generateSummary() async throws {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        let prompt = "write me a short and kids friendly summary in 25 words for this story \(continueStory)"
        let response = try await model.generateContent(prompt)
        if let text = response.text {
            DispatchQueue.main.async {
                self.summary = text
            }
        }

    }
    
    func generateStoryWithGemini() async throws {
        
        
        isLoadingTextPart = true
        if !isGeneratingTitle {
            withAnimation(.easeIn(duration: 1.5)) {
                isLoadingImage = true
            }
        }
        words = extractWords(from: characters)
        words.append(genre)
        words.append(theme)
        chunkOfText = ""
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        let prompt = generatePrompt()
        let response = try await model.generateContent(prompt)
        if let text = response.text {
            DispatchQueue.main.async {
                if isGeneratingTitle {
                    self.title = text
                } else {
                    self.story = text
                    self.chunkOfText = text
                    self.continueStory.append(text)
                    
                }
            }
            
            Task {
                if !isGeneratingTitle {
                    do {
                        try await generateImagePrompt()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            isLoadingTextPart = false
            
        }
    }
    
    func generatePrompt() -> String {
        guard !selectedChars.isEmpty else {
            return "Please select at least one character to generate a prompt."
        }

        var prompt = ""
        print(selectedChars)

        // Building character description
        let characterDescriptions = selectedChars.map { character in
            "\(character.name), who is \(character.age) years old and feeling \(character.emotion)"
        }
        let charactersText = characterDescriptions.joined(separator: ", ")

        // Use "and" for the last character if there are more than one
        let lastSeparator = selectedChars.count > 1 ? " and " : ""

        // Building pet description if any pets are selected
        let petDescriptions = selectedPets.map { pet in
            "\(pet.name), the \(pet.kind)"
        }
        let petsText = petDescriptions.isEmpty ? "" : " along with their pet(s) \(petDescriptions.joined(separator: ", "))"

        if nextKey {
            prompt = "Write the next paragraph of \(continueStory), details: \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together\(petsText). The mood of the story is \(mood). Write in 100 words."
            
        } else if finishKey && !isGeneratingTitle {
            prompt = "Finish this story: \(continueStory) details: a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together\(petsText). Finish in 100 words."
            
        } else if isGeneratingTitle {
            prompt = "Give me a story title for this story \(continueStory) in 3 words only. The mood of the story is \(mood). Output should be only 3 words, nothing extra."
            
        } else {
            prompt = "Write the first paragraph of a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together\(petsText). The mood of the story is \(mood). Write in 100 words."
        }

        print(prompt)
        return prompt
    }
    
    func generateImagePrompt() async throws {
        let characterDescriptions = selectedChars.map { character in
            "\(character.name), a white \(character.gender), who is \(character.age) years old and feeling \(character.emotion)"
        }
        
        let charactersText = characterDescriptions.joined(separator: ", ")
        
        let petDescription = selectedPets.map { pet in
            "\(pet.name), the \(pet.kind)"
        }
        
        let petsText = petDescription.joined(separator: ", ")
        
        let lastSeparator = selectedChars.count > 1 ? " and " : ""
        let petLastSeparator = selectedPets.count > 1 ? " and " : ""
        
        if isGeneratingCover {
            
            
            promptForImage = """
                Create a 3D illustration in a soft, playful style with no text based on the following input:
                Story: \(self.story)
                • Theme: \(theme)
                • Genre: \(genre)
                • Characters: \(charactersText)\(lastSeparator)
                • Pets: \(petsText)\(petLastSeparator)
                • Mood: \(mood)  

                Each character should have a toy-like, soft appearance with smooth features and expressive faces. The design should clearly reflect their age, gender, and personality. The background should be simple and minimal, allowing the focus to remain on the characters. Their poses and expressions should align with the overall mood of the story. and there should be no text in image
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

            The background should reflect \(theme), with elements like [insert any key features from the scene like glowing trees, fireflies, etc.]. Make sure the mood of the illustration reflects \(mood) and \(genre), based on the story. Keep the design toy-like, with smooth and rounded features to appeal to children. and there should be no text in image”

            """
            generateImageUsingOpenAI()
            print(promptForImage)
            withAnimation {
                self.isLoading = false
                self.loaded = true
                
            }
        }
    }
    
}

#Preview {
    ContentView(shader: .example)
}

