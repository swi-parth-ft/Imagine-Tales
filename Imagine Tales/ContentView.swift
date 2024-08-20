//
//  ContentView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/6/24.
//

import SwiftUI
import DotLottie
import FirebaseVertexAI

struct ContentView: View {
    @State private var characters = ""
    @State private var genre = "Adventure"
    @State private var theme = "Forest"
    @State private var story = ""
    @State private var isLoading = false
    @State private var words:[String] =  ["apple", "pinnaple", "orange", "tomato", "banana", "grape", "kiwi", "mango", "pear"]
    @State private var loaded = false
    @State private var isRandom = false
    @State private var scale: CGFloat = 1.0
    @State private var generatedImage: UIImage? = nil
    @State private var isImageLoading = true
    @State private var promptForImage = ""
 
    let vertex = VertexAI.vertexAI()
    
    let genres = [
        "Adventure",
        "Fantasy",
        "Mystery",
        "Romance",
        "Science Fiction",
        "Horror",
        "Thriller",
        "Historical",
        "Comedy",
        "Drama",
        "Detective",
        "Dystopian",
        "Fairy Tale",
        "Magical Realism",
        "Biography",
        "Coming-of-Age",
        "Young Adult",
        "Action",
        "Paranormal",
        "Supernatural",
        "Western"
    ]
    let themes = ["Forest", "Car", "Plane", "Dark", "Colorful", "Cartoon", "Space", "Underwater", "Desert", "Cityscape", "Fantasy", "Sci-Fi", "Nature", "Retro", "Abstract", "Minimalist", "Industrial", "Vintage", "Cyberpunk", "Steampunk"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.purple, .black, .black], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                VStack {
                    if story == "" && !isLoading {
                        VStack {
                            ContentUnavailableView("Imagine Tales", systemImage: "moon.stars.fill", description: Text("Provide Characters, Genre and Theme to create your tale!"))
                                .foregroundColor(.white)
                            
                            Button("🪄 Random") {
                                isRandom = true
                                characters = "Random 2-3 characters"
                                genre = genres.randomElement()!
                                theme = "random theme"
                                generateStory()
                            }
                            .buttonStyle()
                            .shadow(radius: 15)
                        }
                        .frame(height: 250)
                        .padding()
                        
                    } else {
                        if isLoading {
                            DotLottieAnimation(fileName: "StoryLoading", config: AnimationConfig(autoplay: true, loop: true)).view()
                                .frame(width: 340, height: 150)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 360, height: 480)
                                VStack {
                                    ScrollView {
                                        if let image = generatedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .padding([.bottom, .top])
                                                .frame(width: 340, height: 250)
                                                .cornerRadius(22)
                                                .shadow(radius: 10)
                                        }
                                        
                                        if isImageLoading {
                                            DotLottieAnimation(fileName: "imageLoading", config: AnimationConfig(autoplay: true, loop: true)).view()
                                                .frame(width: 340, height: 150)
                                        }
                                        
                                        Text(story)
                                            .padding()
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 350, height: 470)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !isLoading && !loaded{
                        Form {
                            Section {
                                TextField("Characters: Tom, John, and Jenny", text: $characters)
                                Picker("Genre", selection: $genre) {
                                    ForEach(genres, id: \.self) { genre in
                                        Text(genre).tag(genre)
                                    }
                                }
                                Picker("Theme", selection: $theme) {
                                    ForEach(themes, id: \.self) { theme in
                                        Text(theme).tag(theme)
                                    }
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.5))
                        }
                        .frame(height: 200)
                        .scrollContentBackground(.hidden)
                    } else {
                        ForEach(chunkArray(array: words, chunkSize: 3), id: \.self) { row in
                            HStack {
                                if !isRandom {
                                    ForEach(row, id: \.self) { word in
                                        Text(word)
                                            .padding(10)
                                            .background(Color.white.opacity(0.5))
                                            .cornerRadius(22)
                                    }
                                }
                            }
                        }
                    }
                    Button{
                        generatedImage = nil
                        Task {
                            do {
                                try await generateStoryWithGemini()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    } label: {
                        Text(!loaded ? "Generate Story ✨" : "Regenerate ✨")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle()
                    .padding(.bottom, 70)
                }
                .onAppear {
                    withAnimation {
                        scale = 1.1
                    }
                }
                .padding()
            }
            .toolbar {
                if loaded {
                    Button("Clear") {
                        isLoading = false
                        words = []
                        characters = ""
                        genre = "Adventure"
                        story = ""
                        theme = "Forest"
                        loaded = false
                        isRandom = false
                    }
                    .tint(.white)
                }
            }
        }
    }
    
    func chunkArray<T>(array: [T], chunkSize: Int) -> [[T]] {
        var result: [[T]] = []
        let count = array.count
        for i in stride(from: 0, to: count, by: chunkSize) {
            let chunk = Array(array[i..<min(i + chunkSize, count)])
            result.append(chunk)
        }
        return result
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
        let prompt = """
Create an image that depicts a story with the following prompt: \(promptForImage)
"""
        OpenAIService.shared.generateImage(from: prompt) { result in
            isImageLoading = false
            switch result {
            case .success(let image):
                self.generatedImage = image
            case .failure(let error):
                print("Error generating image: \(error.localizedDescription)")
            }
        }
    }
    
    func generateStoryWithGemini() async throws {
        withAnimation {
            isLoading = true
        }
        words = extractWords(from: characters)
        words.append(genre)
        words.append(theme)
        
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        let prompt = "Create a story with characters: \(characters), genre: \(genre), and theme: \(theme) and finish it in 150 words."
        let response = try await model.generateContent(prompt)
        if let text = response.text {
            DispatchQueue.main.async {
                self.story = text
                withAnimation {
                    self.isLoading = false
                    self.loaded = true
                }
            }
            Task {
                do {
                    try await generateImagePrompt()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func generateImagePrompt() async throws {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        let prompt = "Generate me a prompt to create a story book Image using this story \(self.story). within 100 words"
        print("PROMT FOR IMAGE IS : \(prompt)")
        let response = try await model.generateContent(prompt)
        if let text = response.text {
            DispatchQueue.main.async {
                self.promptForImage = text
                generateImageUsingOpenAI()
                print(promptForImage)
                withAnimation {
                    self.isLoading = false
                    self.loaded = true
                }
            }
        }
    }
    
    func generateStory() {
        withAnimation {
            isLoading = true
        }
        words = extractWords(from: characters)
        words.append(genre)
        words.append(theme)
        
        let prompt = "Create a story with characters: \(characters), genre: \(genre), and theme: \(theme) and finish it in 150 words."
        let apiKey = "\(Env.apikey)"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 250 // Optional: Adjust as needed
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = responseDict["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.story = content
                        withAnimation {
                            self.isLoading = false
                            self.loaded = true
                        }
                        
                    }
                }
            }
        }.resume()
    }
}

struct ButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.4))
            .cornerRadius(20)
            .shadow(radius: 10)
    }
}

extension View {
    func buttonStyle() -> some View {
        modifier(ButtonViewModifier())
    }
    
}

#Preview {
    ContentView()
}
