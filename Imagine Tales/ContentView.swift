//
//  ContentView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/6/24.
//

import SwiftUI


struct ContentView: View {
    @State private var characters = ""
    @State private var genre = "Adventure"
    @State private var theme = ""
    @State private var story = ""
    @State private var isLoading = false
    @State private var words:[String] =  ["apple", "pinnaple", "orange", "tomato", "banana", "grape", "kiwi", "mango", "pear"]
    @State private var loaded = false
    @State private var isRandom = false
    
    @State private var scale: CGFloat = 1.0
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
                           
                                // Show GIF while loading
                                GifImage("Animation2") // Ensure "Animation" matches your GIF asset name
                                    .frame(width: 200, height: 150, alignment: .center)
                                    .padding(.top, 50)
                                
                                
                                
                            
                        } else {
                            // Show story text after loading
                            ScrollView {
                                Text(story)
                                    .padding()
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(height: 500) // Adjust as needed
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
                                TextField("Theme...", text: $theme)
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
                                            .padding()
                                            .background(Color.white.opacity(0.5))
                                            .cornerRadius(22)
                                            .scaleEffect(scale)
                                            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: scale)
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    
                        Button(action: generateStory) {
                            Text(!loaded ? "Generate Story ✨" : "Regenerate ✨")
                                .foregroundStyle(.white)
                        }
                        .buttonStyle()
                    
                   
                    
                    
                    
                    
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
                        theme = ""
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
    
    func generateStory() {
        withAnimation {
            isLoading = true
        }
        words = extractWords(from: characters)
        words.append(genre)
        words.append(theme)
        
        let prompt = "Create a story with characters: \(characters), genre: \(genre), and theme: \(theme) and finish it in 150 words."
        let apiKey = "\(Environment.apikey)"
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

struct GradientBackgroundModifier: ViewModifier {
    @State private var gradientOffset: CGFloat = -600
    
    func body(content: Content) -> some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink, .orange]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 100)
            .offset(x: gradientOffset)
            .animation(
                Animation.linear(duration: 4)
                    .repeatForever(autoreverses: false)
            )
            .mask(content) // Mask the gradient to the content shape
        }
        .onAppear {
            gradientOffset = 300
        }
    }
}

extension View {
    func buttonStyle() -> some View {
        modifier(ButtonViewModifier())
    }
    
    func gradientBackground() -> some View {
        self.modifier(GradientBackgroundModifier())
    }
}

#Preview {
    ContentView()
}
