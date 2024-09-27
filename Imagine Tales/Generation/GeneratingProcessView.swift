//
//  StoryView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI
import FirebaseVertexAI

struct GeneratingProcessView: View {
    @Binding var isLoading: Bool
    @Binding var words: [String]
    @Binding var characters: String
    @Binding var genre: String
    @Binding var story: String
    @Binding var theme: String
    @Binding var loaded: Bool
    @Binding var isRandom: Bool
    @Binding var selectedChars: [Charater]
    @Binding var storyChunk: [(String, UIImage)]
    @Binding var nextKey: Bool
    @Binding var finishKey: Bool
    @Binding var continueStory: String
    @Binding var chunkOfText: String
    @Binding var isLoadingChunk: Bool
    @Binding var isGeneratingTitle: Bool
    @Binding var title: String
    @Binding var displayedText: String
    @Binding var storyTextItem: [StoryTextItem]
    @Binding var isLoadingImage: Bool
    @Binding var isLoadingTextPart: Bool
    @Binding var mood: String
    @Binding var summary: String
    @Binding var promptForImage: String
    @Binding var isImageLoading: Bool
    @Binding var selectedPets: [Pet]
    @Binding var isGeneratingCover: Bool
    @Binding var generatedImage: UIImage?
    
    let vertex = VertexAI.vertexAI()
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    @AppStorage("childId") var childId: String = "Default Value"
    @StateObject private var storyViewModel = StoryViewModel()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.5))
            VStack {
                Button("Reset") {
                    resetValues()
                }
                ScrollView {
                    ForEach(0..<storyChunk.count, id: \.self) { index in
                        VStack {
                            Image(uiImage: storyChunk[index].1)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 500)
                                .clipped()
                                .padding()
                                .transition(shader.transition)

                            Text(storyChunk[index].0)
                                .padding()
                        }
                        .padding()
                    }

                    if isLoadingImage {
                        VStack {
                            GradientRectView(size: 500)
                                .transition(shader.transition)

                            Text(chunkOfText)
                                .padding()
                        }
                        .padding()
                    }

                    if isLoadingTextPart {
                        Text("Loading")
                            .frame(height: 55)
                    }

                    if loaded && !isLoadingChunk {
                        actionButtons()
                    }
                }
            }
        }
    }

    private func resetValues() {
        isLoading = false
        words = []
        characters = ""
        genre = "Adventure"
        story = ""
        theme = "Forest"
        loaded = false
        isRandom = false
        selectedChars = []
        storyChunk = []
        nextKey = false
        finishKey = false
        continueStory = ""
        chunkOfText = ""
        isLoadingChunk = false
        isGeneratingTitle = false
        title = ""
        displayedText = ""
        storyTextItem = []
    }

    @ViewBuilder
    private func actionButtons() -> some View {
        HStack {
            Button("Clear") {
                resetValues()
            }
            if !finishKey {
                Button("Next") {
                    nextKey = true
                    isLoadingChunk = true
                    displayedText = ""
                    Task {
                        do {
                            try await generateStoryWithGemini()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }

                Button("Finish") {
                    nextKey = false
                    finishKey = true
                    isLoadingChunk = true
                    Task {
                        do {
                            try await generateStoryWithGemini()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else {
                Button("Share") {
                    Task {
                        do {
                            try await storyViewModel.uploadStoryToFirestore(stroTextItem: storyTextItem, childId: childId, title: title, genre: genre, theme: theme, mood: mood, summary: summary)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }

                Button("Generate Title") {
                    isGeneratingTitle = true
                    Task {
                        do {
                            try await generateStoryWithGemini()
                            try await generateSummary()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
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
