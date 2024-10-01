//
//  StoryView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI
import FirebaseVertexAI
import Drops

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
    @Binding var isSelectingTheme : Bool
    @Binding var preview: Bool
    
    let vertex = VertexAI.vertexAI()
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    @AppStorage("childId") var childId: String = "Default Value"
    @StateObject private var storyViewModel = StoryViewModel()
    @State private var count = 0
    @State private var isTitleGenerated = false
    @Environment(\.colorScheme) var colorScheme
    @State private var isExpanding = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button("Reset", systemImage: "bubbles.and.sparkles.fill") {
                        resetValues()
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color(hex: "#8AC640"))
                    .cornerRadius(23)
                    
                }
                ScrollView {
                 //   ForEach(0..<storyChunk.count, id: \.self) { index in
                    if loaded && !isLoadingChunk {
                        VStack(spacing: isExpanding ? -30 : -80) {
                            Image(uiImage: storyChunk[count].1)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : UIScreen.main.bounds.width * 0.7)
                                .clipped()
                                .cornerRadius(23)
                                .padding()
                                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20) // Adds shadow at the bottom
                                .onTapGesture {
                                    withAnimation {
                                        isExpanding.toggle()
                                    }
                                    // Schedule the second toggle after 5 seconds
                                    if isExpanding {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                            withAnimation {
                                                isExpanding = false
                                            }
                                            
                                        }
                                    }
                                }
                            
                            VStack(spacing: -20) {
                                
                                HStack(spacing: 8) {
                                    ForEach(0..<storyChunk.count, id: \.self) { index in
                                                Rectangle()
                                            .fill(index == count ? Color.orange : Color.gray.opacity(0.3))
                                                    .frame(height: 10)
                                                    .cornerRadius(5)
                                            }
                                        }
                                        .padding()
                                
                                
                                Text(storyChunk[count].0)
                                    .font(.system(size: 21))
                                    .padding()
                                ZStack {
                                    HStack(spacing: 20) {
                                        Button {
                                            if count > 0 {
                                                withAnimation {
                                                    count -= 1
                                                }
                                            }
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(count == 0 ? .gray : Color(hex: "#8AC640"))
                                                    .frame(width: 64, height: 64)
                                                Image(systemName: "arrowtriangle.backward.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10) // Adds shadow at the bottom
                                        
                                        Button {
                                            if !finishKey {
                                                if count == storyChunk.count - 1 {
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
                                                } else {
                                                    withAnimation {
                                                        count += 1
                                                    }
                                                }
                                            } else {
                                                withAnimation {
                                                    count += 1
                                                }
                                            }
                                            
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: "#8AC640"))
                                                    .frame(width: 64, height: 64)
                                                Image(systemName: "arrowtriangle.forward.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10) // Adds shadow at the bottom
                                    }
                                    HStack {
                                        Spacer()
                                        if count > 1 {
                                            Button {
                                                if !finishKey {
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
                                                } else if finishKey && !isTitleGenerated {
                                                    isGeneratingTitle = true
                                                    Task {
                                                        do {
                                                            try await generateStoryWithGemini()
                                                            try await generateSummary()
                                                            storyViewModel.fetchChild(ChildId: childId)
                                                            isTitleGenerated = true
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
                                                    }
                                                } else if isTitleGenerated {
                                                    Task {
                                                        do {
                                                        
                                                            try await storyViewModel.uploadStoryToFirestore(storyTextItem: storyTextItem, childId: childId, title: title, genre: genre, theme: theme, mood: mood, summary: summary)
                                                   
                                                            Drops.show(Drop(title: "Story Uploaded, Waiting for Approval", icon: UIImage(systemName: "square.and.arrow.up.fill")))
                                                            preview = false
                                                            loaded = false
                                                            isLoading = false
                                                            resetValues()
                                                            isSelectingTheme = true
                                                        
                                                        } catch {
                                                            print(error.localizedDescription)
                                                        }
                                                    }
                                                }
                                                    
                                                } label: {
                                                    ZStack {
                                                        Text(finishKey ? (isTitleGenerated ? "Upload Story" : "Generate Title") : "Finish Story")
                                                                    .font(.system(size: 23))
                                                                    .padding()
                                                                    .background(Color(hex: "#8AC640"))
                                                                    .foregroundStyle(.white)
                                                                    .cornerRadius(23)
                                                    }
                                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                                                }
                                            
                                        }
                                        
                                    }
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#FFFFF1"))
                            .cornerRadius(23)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20) // Adds shadow at the bottom
                        }
                        .padding()
                    }
                 //   }

                    if isLoadingImage {
                        VStack(spacing: isExpanding ? -30 : -80) {
                            ZStack {
          
                                // Background blur effect for the story container
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : UIScreen.main.bounds.width * 0.7)
                                    .cornerRadius(23)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                MagicView()
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: isExpanding ? UIScreen.main.bounds.width * 0.9 : UIScreen.main.bounds.width * 0.7)
                            }
                            .onTapGesture {
                                withAnimation {
                                    isExpanding.toggle()
                                }
                                // Schedule the second toggle after 5 seconds
                                if isExpanding {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        withAnimation {
                                            isExpanding = false
                                        }
                                        
                                    }
                                }
                            }
                            
                            VStack(spacing: -20) {
                                HStack(spacing: 8) {
                                    ForEach(0..<storyChunk.count + 1, id: \.self) { index in
                                                Rectangle()
                                            .fill(index == count ? Color.orange : Color.gray.opacity(0.3))
                                                    .frame(height: 10)
                                                    .cornerRadius(5)
                                            }
                                        }
                                        .padding()
                                
                                Text(chunkOfText)
                                    .font(.system(size: 21))
                                    .padding()
                                
                                ZStack {
                                    HStack(spacing: 20) {
                                        Button {
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(.gray)
                                                    .frame(width: 64, height: 64)
                                                Image(systemName: "arrowtriangle.backward.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundStyle(.white.opacity(0.5))
                                            }
                                        }
                                        
                                        Button {
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(.gray)
                                                    .frame(width: 64, height: 64)
                                                Image(systemName: "arrowtriangle.forward.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundStyle(.white.opacity(0.5))
                                            }
                                        }
                                    }
                                  
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .background(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(hex: "#FFFFF1"))
                            .cornerRadius(23)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10) // Adds shadow at the bottom
                        }
                        .padding()
                    }

                    if isLoadingTextPart {
                        Text("Loading")
                            .frame(height: 55)
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
        
            isLoadingImage = true
        
        let prompt = promptForImage
        OpenAIService.shared.generateImage(from: prompt) { result in
           
                isImageLoading = false
            
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
               
                    self.isLoadingImage = false
                    self.loaded = true
                    self.count += 1
                
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
                isLoadingImage = true
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
