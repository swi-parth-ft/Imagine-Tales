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
    @State private var char = ""
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
    @State private var displayPrompt = "I want to generate a story book of"
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
        "Action",
        "Paranormal",
        "Supernatural",
        "Western"
    ]
    let themes = ["Forest", "Car", "Plane", "Dark", "Colorful", "Cartoon", "Space", "Underwater", "Desert", "Cityscape", "Fantasy", "Sci-Fi", "Nature", "Retro", "Abstract", "Minimalist", "Industrial", "Vintage", "Cyberpunk", "Steampunk"]
    
    
    @State private var isSelectingTheme = true
    @State private var isSelectingGenre = false
    @State private var isAddingNames = false
    
    @State private var formattedChars = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFFFF1").ignoresSafeArea()
                VStack {
                    if story == "" && !isLoading {

                        
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
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 350, height: 470)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !isLoading && !loaded{
                        
                        //Taking Input
                        VStack {
                            //prompt view
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.white)
                                    .shadow(radius: 10)
                                
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Prompt")
                                            .foregroundStyle(Color(hex: "#DA70D6"))
                                            .font(.system(size: 24, weight: .bold))
                                        Spacer()
                                        Image(systemName: "shuffle")
                                            .font(.system(size: 24))
                                            .frame(width: 20, height: 20)
                                            .onTapGesture {
                                                isRandom = true
                                                characters = "Random 2-3 characters"
                                                genre = genres.randomElement()!
                                                theme = "random theme"
                                                generateStory()
                                            }
                                    }
                                    .padding(.horizontal, 30)
                                    
                                    
                                    HStack {
                                        Text(displayPrompt)
                                            .font(.system(size: 20))
                                        
                                        Text(theme)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(Color(hex: "#FF6F61"))
                                        
                                        Text("theme")
                                            .font(.system(size: 20))
                                        
                                        if isSelectingGenre || isAddingNames {
                                            Text("with genre of")
                                                .font(.system(size: 20))
                                            
                                            Text(genre)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(.green)
                                        }
                                        
                                        
                                        
                                    }
                                    .padding(.leading, 30)
                                    HStack {
                                        if isAddingNames {
                                            Text("with")
                                                .font(.system(size: 20))
                                            
                                            Text(characters == "" ? "no" : formattedChars)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(.purple)
                                            
                                            Text(characters == "" ? "characters" : "as characters")
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding(.leading, 30)
                                    
                                    
                                }
                            }
                            .frame(height: isAddingNames ? 150 : 120)
                            
                            
                            //Selection Title
                            Text(isSelectingTheme ? "Select Theme" : isAddingNames ? "Add Characters" : "Select Genre")
                                .font(.system(size: 24))
                                .padding()
                            
                            //Selecting Theme
                            if isSelectingTheme {
                                GeometryReader { geometry in
                                    // Calculate dynamic width based on available width and desired number of items per row
                                    let width = (geometry.size.width - 40) / 7 // Subtract padding and divide by the number of items
                                    
                                    ScrollView {
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.fixed(width), spacing: 7), count: 4),
                                            spacing: -10  // Adjust the spacing to bring the rows closer together
                                        ) {
                                            
                                            ForEach(0..<themes.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(themes[index] == theme ? Color.orange.opacity(0.5) : Color.orange.opacity(0.2))
                                                            .frame(width: width, height: width)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(themes[index] == theme ? 1.1 : 1.0)
                                                        
                                                        Text(themes[index])
                                                            .font(.caption)
                                                            .multilineTextAlignment(.center)
                                                        
                                                    }
                                                }
                                                // Apply offset for every other row to create hexagonal shape
                                                .offset(x: (index / 4) % 2 == 0 ? 0 : width / 2)
                                                .frame(width: width, height: width)
                                                .onTapGesture {
                                                    withAnimation {
                                                        theme = themes[index]
                                                    }
                                                }
                                            }
                                           
                                            
                                        }
                                        .padding()
                                    }
                                }
                                .frame(height: 600)
                                .padding()
                            }
                            
                            //Selecting Genre
                            else if isSelectingGenre {
                                GeometryReader { geometry in
                                    // Calculate dynamic width based on available width and desired number of items per row
                                    let width = (geometry.size.width - 40) / 7 // Subtract padding and divide by the number of items
                                    
                                    ScrollView {
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.fixed(width), spacing: 7), count: 4),
                                            spacing: -10  // Adjust the spacing to bring the rows closer together
                                        ) {
                                            
                                            ForEach(0..<genres.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(genres[index] == genre ? Color.green.opacity(0.5) : Color.green.opacity(0.2))
                                                            .frame(width: width, height: width)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(genres[index] == genre ? 1.1 : 1.0)
                                                        
                                                        Text(genres[index])
                                                            .font(.caption)
                                                            .multilineTextAlignment(.center)
                                                        
                                                    }
                                                }
                                                // Apply offset for every other row to create hexagonal shape
                                                .offset(x: (index / 4) % 2 == 0 ? 0 : width / 2)
                                                .frame(width: width, height: width)
                                                .onTapGesture {
                                                    withAnimation {
                                                        genre = genres[index]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        .padding()
                                    }
                                }
                                .frame(height: 600)
                                .padding()
                            }
                            
                            //Adding Charactors
                            else if isAddingNames {
                                HStack(spacing: -20) {
                                    TextField("Name", text: $char)
                                        .padding()
                                        .frame(width:  UIScreen.main.bounds.width * 0.2, height: 55)
                                        .background(.purple.opacity(0.1))
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                        .tint(.purple)
                                    
                                    Button("Add") {
                                        withAnimation {
                                            characters.append(characters == "" ? char : ", \(char)")
                                            char = ""
                                        }
                                        
                                        words = extractWords(from: characters)
                                        if words.count > 1 {
                                            let lastName = words.removeLast()
                                            withAnimation {
                                                formattedChars = words.joined(separator: ", ") + " and " + lastName
                                            }
                                        } else {
                                            withAnimation {
                                                formattedChars = words.first ?? ""
                                            }
                                        }
                                        
                                    }
                                    .frame(width:  100, height: 55)
                                    .background(.purple)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                }
                            }
                            
                            Spacer()
                            
                            //Buttons
                            VStack {
                                Button("Next", systemImage: "arrowtriangle.right.fill") {
                                    if isSelectingTheme {
                                        withAnimation {
                                            isSelectingTheme = false
                                            isSelectingGenre = true
                                        }
                                    } else if isSelectingGenre {
                                        withAnimation {
                                            isSelectingGenre = false
                                            isAddingNames = true
                                        }
                                    } else if isAddingNames {
                                        generatedImage = nil
                                        Task {
                                            do {
                                                try await generateStoryWithGemini()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                    
                                }
                                .padding()
                                .frame(width:  UIScreen.main.bounds.width * 0.7)
                                .background(Color(hex: "#FF6F61"))
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                                
                                if isSelectingGenre || isAddingNames {
                                    Button("back", systemImage: "arrowtriangle.left.fill") {
                                        if isAddingNames {
                                            withAnimation {
                                                isSelectingGenre = true
                                                isAddingNames = false
                                            }
                                        } else {
                                            withAnimation {
                                                isSelectingTheme = true
                                                isSelectingGenre = false
                                            }
                                        }
                                        
                                    }
                                    .padding()
                                    .frame(width:  UIScreen.main.bounds.width * 0.7)
                                    .background(isAddingNames ? Color.purple.opacity(0.2) : Color(hex: "#DFFFDF"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(12)
                                }
                            }
                        }

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
                    
                }
                .onAppear {
                    withAnimation {
                        scale = 1.1
                    }
                }
                .padding()
                .padding(.top, 50)
                .padding(.bottom, 70)
            }
            .toolbar {
//                if loaded {
//                    Button("Clear") {
//                        isLoading = false
//                        words = []
//                        characters = ""
//                        genre = "Adventure"
//                        story = ""
//                        theme = "Forest"
//                        loaded = false
//                        isRandom = false
//                    }
//                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(systemName: "person.circle.fill") // Replace with your image name
                        .resizable()
                        .frame(width: 40, height: 40) // Adjust the size as needed
                        .clipShape(Circle())
                }
                
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("search", systemImage: "sparkle.magnifyingglass") {
                        
                    }
                    
                    
                    Button("Notifications", systemImage: "bell") {
                        
                    }
                }
            }
            .tint(.black)
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
