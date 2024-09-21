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

final class StoryViewModel: ObservableObject {
    @Published var storyText: [StoryTextItem] = []
    @Published var imageURL = ""
    @Published var child: UserChildren?
    
    func uploadImage(image: UIImage, completion: @escaping (_ url: String?) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data.")
            completion(nil)
            return
        }

        // Create a reference to Firebase Storage
        let storageRef = Storage.storage().reference()
        let imageName = UUID().uuidString // Unique name for the image
        let imageRef = storageRef.child("images/\(imageName).jpg")

        // Upload the image data
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Fetch the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let downloadURL = url else {
                    print("Error: Download URL is nil.")
                    completion(nil)
                    return
                }

                completion(downloadURL.absoluteString)
            }
        }

        // Handle upload progress and completion (optional)
        uploadTask.observe(.progress) { snapshot in
            // Observe upload progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload is \(percentComplete)% complete")
        }

        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("Upload completed successfully")
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Upload failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func uploadStoryToFirestore(stroTextItem: [StoryTextItem], childId: String, title: String, genre: String, theme: String, mood: String) async throws {
        
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        
        
        let document = Firestore.firestore().collection("Story").document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "parentId" : authDataResult.uid,
            "childId" : childId,
            "storyText": stroTextItem.map { item in
                        [
                            "image": item.image,
                            "text": item.text
                        ]
                    },
            "title" : title,
            "status" : "pending",
            "genre" : genre,
            "childUsername" : child?.username ?? "",
            "likes" : 0,
            "theme" : theme,
            "mood" : mood,
            "dateCreated" : Timestamp()
        ]
        
        try await document.setData(data, merge: true)
        
    }
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    self.child = document
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
}

final class ContentViewModel: ObservableObject {
    @Published var characters: [Charater] = []
    @AppStorage("childId") var childId: String = "Default Value"
    
    func getCharacters() throws {
      
        
        Firestore.firestore().collection("Children2").document(childId).collection("Characters").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.characters = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Charater.self)
            } ?? []
            print(self.characters)
            
        }
    }
    
    func deleteChar(char: Charater) {
        Firestore.firestore().collection("Children2").document(childId).collection("Characters").document(char.id).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
        }
        else {
          print("Document successfully removed!")
        }
      }
    }
}


struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var storyViewModel = StoryViewModel()
    
    @State private var characters = ""
    @State private var char = ""
    @State private var genre = "Adventure"
    @State private var theme = "Dinosaur Discoveries"
    @State private var story = ""
    @State private var isLoading = false
    @State private var words:[String] =  []
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
    let themes = [
        "Magical Adventures",
        "Underwater Mysteries",
        "Dinosaur Discoveries",
        "Space Explorers",
        "Fairy Tale Kingdoms",
        "Superhero Chronicles",
        "Enchanted Forests",
        "Pirate Quests",
        "Animal Friends",
        "Time Traveling",
        "Monster Mischief",
        "Robot Wonders",
        "Mystical Creatures",
        "Lost Worlds",
        "Magical School Days",
        "Jungle Safari",
        "Winter Wonderland",
        "Desert Dunes",
        "Alien Encounter",
        "Wizard’s Secrets"
    ]
    
    let themeColors: [Color] = [
        Color.purple,   // "Magical Adventures"
        Color.teal,     // "Underwater Mysteries"
        Color.green,    // "Dinosaur Discoveries"
        Color.blue,     // "Space Explorers"
        Color.pink,     // "Fairy Tale Kingdoms"
        Color.red,      // "Superhero Chronicles"
        Color.green,    // "Enchanted Forests"
        Color.brown,    // "Pirate Quests"
        Color.orange,   // "Animal Friends"
        Color.indigo,   // "Time Traveling"
        Color.purple,   // "Monster Mischief"
        Color.gray,     // "Robot Wonders"
        Color.purple,   // "Mystical Creatures"
        Color.green,    // "Lost Worlds"
        Color.yellow,   // "Magical School Days"
        Color.green,    // "Jungle Safari"
        Color.blue,     // "Winter Wonderland"
        Color.orange,   // "Desert Dunes"
        Color.yellow,     // "Alien Encounter"
        Color.gray      // "Wizard’s Secrets"
    ]
    
    @State private var isSelectingTheme = true
    @State private var isSelectingGenre = false
    @State private var isAddingNames = false
    @State private var formattedChars = ""
    @State private var isAddingChar = false
    
    @State private var selectedChars: [Charater] = []
    
    
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
    @State private var mood = ""
    let moods = ["Happy", "Sad", "Excited", "Scared", "Curious", "Brave", "Funny", "Surprised", "Angry", "Relaxed", "Adventurous", "Mysterious", "Silly", "Love", "Confused", "Proud", "Nervous", "Sleepy", "Joyful", "Shy"]
    let moodEmojis = ["😊", "😢", "😃", "😱", "🤔", "💪", "😄", "😮", "😠", "😌", "🧭", "🕵️‍♂️", "🤪", "❤️", "😕", "😎", "😬", "😴", "😁", "😳"]
  @State private var selectedEmoji = ""
    @State private var isSelectingMood = false
    @State private var displayedText: String = ""
        @State private var charIndex: Int = 0
        let typingSpeed = 0.03
    
    func startTyping(chunk: String) {
            displayedText = ""
            charIndex = 0
            
            Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
                if charIndex < chunk.count {
                    let index = chunk.index(chunk.startIndex, offsetBy: charIndex)
                    displayedText.append(chunk[index])
                    charIndex += 1
                } else {
                    timer.invalidate()
                }
            }
        }
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    
    let bookBackgroundColors: [Color] = [
        Color(red: 255/255, green: 235/255, blue: 190/255),  // More vivid Beige
        Color(red: 220/255, green: 220/255, blue: 220/255),  // More vivid Light Gray
        Color(red: 255/255, green: 230/255, blue: 240/255),  // More vivid Lavender Blush
        Color(red: 255/255, green: 255/255, blue: 245/255),  // More vivid Mint Cream
        Color(red: 230/255, green: 255/255, blue: 230/255),  // More vivid Honeydew
        Color(red: 230/255, green: 248/255, blue: 255/255),  // More vivid Alice Blue
        Color(red: 255/255, green: 250/255, blue: 230/255),  // More vivid Seashell
        Color(red: 255/255, green: 250/255, blue: 215/255),  // More vivid Old Lace
        Color(red: 255/255, green: 250/255, blue: 200/255)   // More vivid Cornsilk
    ]
    @State private var isGeneratingCover = true
    @State private var preview = false
    
    var body: some View {
        NavigationStack {
            ZStack {
               
                VStack {

                        //MARK: Story Loaded
                    if loaded || isLoading {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.white.opacity(0.5))
                                VStack {
                                    
                                    Button("reset") {
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
                                                
//                                                Text(displayedText)
//                                                    .padding()
                                                
                                                
                                            }
                                            .padding()
                                        }
                                        
                                        if isLoadingTextPart {
                                            
                                            TextPlaceholderView()
                                                .frame(height: 55)
//                                            DotLottieAnimation(fileName: "StoryLoading", config: AnimationConfig(autoplay: true, loop: true)).view()
//                                                .frame(width: 340 * 2, height: 150 * 2)
                                        }
                                        
                                        if loaded && !isLoadingChunk {
                                            HStack {
                                                Button("Clear") {
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
                                                                try await storyViewModel.uploadStoryToFirestore(stroTextItem: storyTextItem, childId: childId, title: title, genre: genre, theme: theme, mood: mood)
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
                                                                
                                                            } catch {
                                                                print(error.localizedDescription)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                
                    
                    //MARK: Taking Input
                    if !isLoading && !loaded{
                        
                        
                        ZStack {
                            
                            
                            //MARK: Selecting Theme
                            if isSelectingTheme {
                                GeometryReader { geometry in
                                    let height = (geometry.size.height - 40) / 5

                                    ScrollView(.horizontal) {
                                        LazyHGrid(
                                            rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 3),
                                            spacing: 60  // Adjust the spacing to bring the columns closer together
                                        ) {

                                            ForEach(0..<themes.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(themes[index] == theme ? themeColors[index].opacity(0.5) : themeColors[index].opacity(0.2))
                                                            .frame(width: height, height: height)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.4 : 1.2) : 0.0)
                                                            .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)
                                                        
                                                        VStack {
                                                            Image("\(themes[index].filter { !$0.isWhitespace })")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: height * 0.7, height: height * 0.7, alignment: .center)
                                                                .shadow(radius: 5)
                                                                .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.2 : 1.0) : 0.0)
                                                                .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)
                                                            
                                                            let words = themes[index].split(separator: " ")

                                                            VStack {
                                                                ForEach(words, id: \.self) { word in
                                                                    Text(String(word))
                                                                        .font(.caption)
                                                                        .multilineTextAlignment(.center)
                                                                        .opacity(isSelectingTheme ? 1.0 : 0.0)
                                                                        .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.2 : 1.0) : 0.0)
                                                                        .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)
                                                                }
                                                            }
                                                        }
                                                        .padding()

                                                    }
                                                    
                                                }
                                                // Apply offset for every other column to create hexagonal shape
                                                .offset(y: (index / 3) % 2 == 0 ? 0 : height / 2)
                                                .frame(width: height, height: height)
                                                .onTapGesture {
                                                    withAnimation {
                                                        theme = themes[index]
                                                    }
                                                }
                                            }

                                        }
                                        .padding(.leading, 50)
                                        .padding(.bottom, 70)
                                    }
                                    Spacer()
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                            }
                            
                            //MARK: Selecting Genre
                            else if isSelectingGenre {
                                GeometryReader { geometry in
                                    let height = (geometry.size.height - 40) / 7

                                    ScrollView(.horizontal) {
                                        LazyHGrid(
                                            rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 4),
                                            spacing: 60  // Adjust the spacing to bring the columns closer together
                                        ) {

                                            ForEach(0..<genres.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(genres[index] == genre ? Color.cyan.opacity(0.5) : Color.cyan.opacity(0.2))
                                                            .frame(width: height, height: height)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(isSelectingGenre ? (genres[index] == genre ? 1.4 : 1.2) : 0.0)
                                                            .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre)
                                                        
                                                        Text(genres[index])
                                                            .font(.caption)
                                                            .opacity(isSelectingGenre ? 1.0 : 0.0)
                                                            .scaleEffect(isSelectingGenre ? (genres[index] == genre ? 1.2 : 1.0) : 0.0)
                                                            .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre)
                                                        

                                                    }
                                                    
                                                }
                                                // Apply offset for every other column to create hexagonal shape
                                                .offset(y: (index / 4) % 2 == 0 ? 0 : height / 2)
                                                .frame(width: height, height: height)
                                                .onTapGesture {
                                                    withAnimation {
                                                        genre = genres[index]
                                                    }
                                                }
                                            }

                                        }
                                        .padding(.leading, 50)
                                        .padding(.bottom, 70)
                                    }
                                    Spacer()
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                               
                            }
                            
                            //MARK: Adding Charactors
                            else if isAddingNames {
                                
                                GeometryReader { geometry in
                                    // Calculate dynamic width based on available width and desired number of items per row
                                    let width = (geometry.size.width - 40) / 8 // Subtract padding and divide by the number of items
                                    
                                    ScrollView {
                                        Button {
                                            isAddingChar = true
                                            
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.purple.opacity(0.2))
                                                    .frame(width: width, height: width)
                                                    .shadow(radius: 5)
                                                    .scaleEffect(1.0)
                                                
                                                Image(systemName: "plus")
                                                    .frame(width: width / 2, height: width / 2)
                                            }
                                        }
                                        .padding(.top, 80)
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.fixed(width), spacing: 7), count: 4),
                                            spacing: -10  // Adjust the spacing to bring the rows closer together
                                        ) {
                                            
                                            ForEach(0..<viewModel.characters.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(characters.contains(viewModel.characters[index].name) ? Color.purple.opacity(0.5) : Color.purple.opacity(0.2))
                                                            .frame(width: width, height: width)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(characters.contains(viewModel.characters[index].name) ? 1.1 : 1.0)
                                                        
                                                        
                                                        Text(viewModel.characters[index].name)
                                                            .font(.caption)
                                                            .multilineTextAlignment(.center)
                                                        
                                                    }
                                                }
                                                .contextMenu {
                                                    Button(action: {
                                                        viewModel.deleteChar(char: viewModel.characters[index])
                                                        
                                                        Task {
                                                            do {
                                                                try viewModel.getCharacters()
                                                            } catch {
                                                                print(error.localizedDescription)
                                                            }
                                                        }
                                                        
                                                    }) {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                                // Apply offset for every other row to create hexagonal shape
                                                .offset(x: (index / 4) % 2 == 0 ? 0 : width / 2)
                                                .frame(width: width, height: width)
                                                .onTapGesture {
                                                    
                                                    if !characters.contains(viewModel.characters[index].name) {
                                                        selectedChars.append(viewModel.characters[index])
                                                        withAnimation {
                                                            characters.append(characters == "" ? viewModel.characters[index].name : ", \(viewModel.characters[index].name)")
                                                            
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
                                                    } else {
                                                        
                                                        selectedChars = selectedChars.filter { $0.id != viewModel.characters[index].id }
                                                        
                                                        withAnimation {
                                                            let temp = characters.replacingOccurrences(of: viewModel.characters[index].name, with: "")
                                                            characters = temp
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
                                                }
                                                
                                                
                                                
                                            }
                                            
                                        }
                                        .padding()
                                    }
                                }
                                .padding()
                                .onAppear {
                                    Task {
                                        do {
                                            try viewModel.getCharacters()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    
                                }
                            }
                            
                            //MARK: Selecting Mood
                            else if isSelectingMood {
                                GeometryReader { geometry in
                                    let height = (geometry.size.height - 40) / 8
                                    
                                    ScrollView(.horizontal) {
                                        LazyHGrid(
                                            rows: Array(repeating: GridItem(.fixed(height), spacing: 70), count: 4),
                                            spacing: 60  // Adjust the spacing to bring the columns closer together
                                        ) {
                                            
                                            ForEach(0..<moods.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(moods[index] == mood ? Color.yellow.opacity(0.5) : Color.yellow.opacity(0.2))
                                                            .frame(width: height, height: height)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(isSelectingMood ? (moods[index] == mood ? 1.4 : 1.2) : 0.0)
                                                            .animation(.easeInOut(duration: moods[index] == mood ? 0.6 : 0.3), value: isSelectingMood)
                                                        
                                                        VStack {
                                                            Text(moodEmojis[index])
                                                                .font(.system(size: 32))
                                                            Text(moods[index])
                                                                .font(.caption)
                                                                .opacity(isSelectingMood ? 1.0 : 0.0)
                                                                .scaleEffect(isSelectingMood ? (moods[index] == mood ? 1.2 : 1.0) : 0.0)
                                                                .animation(.easeInOut(duration: moods[index] == mood ? 0.6 : 0.3), value: isSelectingMood)
                                                        }
                                                    }
                                                    
                                                }
                                                // Apply offset for every other column to create hexagonal shape
                                                .offset(y: (index / 4) % 2 == 0 ? 0 : height / 2)
                                                .frame(width: height, height: height)
                                                .onTapGesture {
                                                    withAnimation {
                                                        mood = moods[index]
                                                        selectedEmoji = moodEmojis[index]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        .padding(.leading, 50)
                                        .padding(.bottom, 70)
                                    }
                                    Spacer()
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                            }
                            
                            //MARK: Preview
                            else if preview {
                                VStack {
                                    StoryReviewView(theme: theme, genre: genre, characters: formattedChars, chars: selectedChars, mood: mood, moodEmoji: selectedEmoji)
                                    
                                    // Buttons
                                    HStack {
                                        Button(action: {
                                            withAnimation {
                                                preview = false
                                                isAddingNames = true
                                            }
                                        }) {
                                            Text("Go Back and Edit")
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
                                            Text("Generate")
                                                .bold()
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
                                ZStack {
                                    if isSelectingGenre || isAddingNames || isSelectingMood {
                                        HStack {
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
                                                        .foregroundStyle(isSelectingGenre ? .cyan.opacity(0.3) :  isSelectingMood ? .yellow.opacity(0.3) : .purple.opacity(0.3))
                                                        .frame(width: 75, height: 75)
                                                        .shadow(radius: 10)
                                                    
                                                    Image("arrow1")
                                                        .frame(width: 55, height: 55)
                                                    
                                                }
                                            }
                                            .padding()
                                            Spacer()
                                        }
                                    }
                                    //Selection Title
                                    Text(isSelectingTheme ? "Select Theme" : isSelectingGenre ? "Select Genre" : isAddingNames ? "Select Charaters" : isSelectingMood ? "Select Mood" : "Preview")
                                        .font(.system(size: 24))
                                        .frame(height: 75)
                                        .padding()
                                }
                                
                                Spacer()
                                //MARK: Buttons
                                if !preview {
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
                                            
                                        }
                                        .padding()
                                        .frame(width:  UIScreen.main.bounds.width * 0.7)
                                        .background(Color(hex: "#FF6F61"))
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            
                            
                        }

                    }
                    
                    //MARK: Chunk
                    else {
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
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }) {
                CharacterView()
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
                    startTyping(chunk: text)
                    
                    
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
            if selectedChars.count == 1 {
                let character = selectedChars[0]
                prompt = "Create a \(genre) story where \(character.name), who is \(character.age) years old and feeling \(character.emotion), goes on an exciting adventure in a \(theme) world. And mood of story is \(mood)."
            } else {
                let characterDescriptions = selectedChars.map { character in
                    "\(character.name), who is \(character.age) years old and feeling \(character.emotion)"
                }
                
                let charactersText = characterDescriptions.joined(separator: ", ")
                
                // Use "and" for the last character if there are more than one
                let lastSeparator = selectedChars.count > 1 ? " and " : ""
                
                if nextKey {
                    prompt = "Write a next paragraph of \(continueStory), details: \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together. And mood of story is \(mood). In 100 words"
                    
                } else if finishKey && !isGeneratingTitle {
                    prompt = "finish this story: \(continueStory) details: of a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together. in 100 words"
                } else if isGeneratingTitle {
                    prompt = "Give me a story title for this story \(continueStory) in 3 words only. And mood of story is \(mood). output should be only 3 words nothing extra"
                } else {
                    prompt = "Write a first begining paragraph/pilot of a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together.  And mood of story is \(mood). In 100 words"
                }
            }
            print(prompt)
            return prompt
    }
    
    func generateImagePrompt() async throws {
        let characterDescriptions = selectedChars.map { character in
            "\(character.name), a white \(character.gender), who is \(character.age) years old and feeling \(character.emotion)"
        }
        
        let charactersText = characterDescriptions.joined(separator: ", ")
        
        // Use "and" for the last character if there are more than one
        let lastSeparator = selectedChars.count > 1 ? " and " : ""
        if isGeneratingCover {
            
            
            promptForImage = """
                Create a 3D illustration in a soft, playful style with no text based on the following input:
                Story: \(self.story)
                • Theme: \(theme)
                • Genre: \(genre)
                • Characters: \(charactersText)\(lastSeparator)  // Provide their names, ages, gender, and personality traits
                • Mood: \(mood)  // E.g., joyful, adventurous, mysterious

                Each character should have a toy-like, soft appearance with smooth features and expressive faces. The design should clearly reflect their age, gender, and personality. The background should be simple and minimal, allowing the focus to remain on the characters. Their poses and expressions should align with the overall mood of the story. and there should be no text in image
                """
            print(promptForImage)
            isGeneratingCover = false
            generateImageUsingOpenAI()
        } else {
            let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
            
            promptForImage = """
            Create a 3D illustration in a soft, playful style based on the following paragraph from a children’s story:

            Story: \(self.story)

            Illustrate the following:

                •    Characters: \(charactersText)\(lastSeparator)

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
   // NavigationStack {
        ContentView(shader: .example)
  //  }
}
