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
    
    func uploadStoryToFirestore(stroTextItem: [StoryTextItem], childId: String, title: String, genre: String) async throws {
        
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
            "childUsername" : child?.username,
            "likes" : 0,
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
    @State private var theme = "Forest"
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
    let themes = ["Forest", "Car", "Plane", "Dark", "Colorful", "Cartoon", "Space", "Underwater", "Desert", "Cityscape", "Fantasy", "Sci-Fi", "Nature", "Retro", "Abstract", "Minimalist", "Industrial", "Vintage", "Cyberpunk", "Steampunk"]
    
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
                                               
                                                    GradientRectView()
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
                                                                try await storyViewModel.uploadStoryToFirestore(stroTextItem: storyTextItem, childId: childId, title: title, genre: genre)
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
                        
                        
                        VStack {
                            //MARK: prompt view
                            ZStack {
                                if #available(iOS 18, *) {
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(
                                            
                                            MeshGradient(
                                                width: 4,
                                                height: 3,
                                                points: [
                                                    [0, 0], [0.33, 0], [0.66, 0], [1, 0],
                                                    [0, 0.5], [0.33, 0.5], [0.66, 0.5], [1, 0.5],
                                                    [0, 1], [0.33, 1], [0.66, 1], [1, 1]
                                                ],
                                                colors: [
                                                    .blue.opacity(0.6), .purple.opacity(0.4), .cyan.opacity(0.3), .indigo.opacity(0.2),
                                                    isAddingNames ? .pink.opacity(0.3) : .teal.opacity(0.2), isAddingNames ? .purple.opacity(0.2) : .blue.opacity(0.1), isAddingNames ? .indigo.opacity(0.2) : .cyan.opacity(0.1), isSelectingGenre || isAddingNames ? .teal.opacity(0.2) : .purple.opacity(0.1),
                                                    isAddingNames ? .pink.opacity(0.5) : .blue.opacity(0.3), .purple.opacity(0.2), isSelectingGenre || isAddingNames ? .cyan.opacity(0.3) : .indigo.opacity(0.2), isSelectingGenre || isAddingNames ? .teal.opacity(0.4) : .blue.opacity(0.3)
                                                ]
                                            )
                                            
                                        )
                                        .shadow(radius: 10)
                                       
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Wish")
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
                                                .foregroundStyle(.cyan)
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
                            
                            //MARK: Title Section
                            ZStack {
                                if isSelectingGenre || isAddingNames {
                                    HStack {
                                        Button {
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
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .foregroundStyle(isSelectingGenre ? .cyan.opacity(0.3) :  .purple.opacity(0.3))
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
                                Text(isSelectingTheme ? "Select Theme" : isAddingNames ? "Select Characters" : "Select Genre")
                                    .font(.system(size: 24))
                                    .frame(height: 75)
                                    .padding()
                            }
                            
                            
                            //MARK: Selecting Theme
                            if isSelectingTheme {
                                GeometryReader { geometry in
                                    // Calculate dynamic width based on available width and desired number of items per row
                                    let width = (geometry.size.width - 40) / 8 // Subtract padding and divide by the number of items
                                    
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
                                                            .scaleEffect(isSelectingTheme ? (themes[index] == theme ? 1.1 : 1.0) : 0.0)
                                                                                                .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)
                                                        
                                                        Text(themes[index])
                                                            .font(.caption)
                                                            .multilineTextAlignment(.center)
                                                            .opacity(isSelectingTheme ? 1.0 : 0.0)
                                                                                                        .animation(.easeInOut(duration: themes[index] == theme ? 0.6 : 0.3), value: isSelectingTheme)
                                                        
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
                                .frame(height: 500)
                                .padding()
                                .transition(.opacity.combined(with: .scale(scale: 0.0, anchor: .center)))
                               // .animation(.easeInOut(duration: 1.0))
                            }
                            
                            //MARK: Selecting Genre
                            else if isSelectingGenre {
                                GeometryReader { geometry in
                                    // Calculate dynamic width based on available width and desired number of items per row
                                    let width = (geometry.size.width - 40) / 8 // Subtract padding and divide by the number of items
                                    
                                    ScrollView {
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.fixed(width), spacing: 7), count: 4),
                                            spacing: -10  // Adjust the spacing to bring the rows closer together
                                        ) {
                                            
                                            ForEach(0..<genres.count, id: \.self) { index in
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(genres[index] == genre ? Color.cyan.opacity(0.5) : Color.cyan.opacity(0.2))
                                                            .frame(width: width, height: width)
                                                            .shadow(radius: 5)
                                                            .scaleEffect(genres[index] == genre ? 1.1 : 1.0)
                                                            .scaleEffect(isSelectingGenre ? 1.0 : 0.0)  // Grow when appearing
                                                                                                        .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre)
                                                        
                                                        Text(genres[index])
                                                            .font(.caption)
                                                            .multilineTextAlignment(.center)
                                                            .scaleEffect(isSelectingGenre ? 1.0 : 0.0)  // Grow when appearing
                                                                                                        .animation(.easeInOut(duration: genres[index] == genre ? 0.6 : 0.3), value: isSelectingGenre)
                                                        
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
                                .frame(height: 500)
                                .padding()
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
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.fixed(width), spacing: 7), count: 5),
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
                                .frame(height: 500)
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
                            
                            //MARK: Buttons
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
                                    
                                }
                                .padding()
                                .frame(width:  UIScreen.main.bounds.width * 0.7)
                                .background(Color(hex: "#FF6F61"))
                                .foregroundStyle(.white)
                                .cornerRadius(12)
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
                .padding(.bottom, 70)
            }
            .navigationTitle(isGeneratingTitle ? "\(title)" : "Imagine a Story")
            .toolbar {
                
                
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
        
        
        let prompt = """
Create an kids story book image that depicts a story with the following prompt: \(promptForImage)
"""
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
                prompt = "Create a \(genre) story where \(character.name), who is \(character.age) years old and feeling \(character.emotion), goes on an exciting adventure in a \(theme) world."
            } else {
                let characterDescriptions = selectedChars.map { character in
                    "\(character.name), who is \(character.age) years old and feeling \(character.emotion)"
                }
                
                let charactersText = characterDescriptions.joined(separator: ", ")
                
                // Use "and" for the last character if there are more than one
                let lastSeparator = selectedChars.count > 1 ? " and " : ""
                
                if nextKey {
                    prompt = "Write a next paragraph of \(continueStory), details: \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together."
                    
                } else if finishKey && !isGeneratingTitle {
                    prompt = "finish this story: \(continueStory) details: of a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together."
                } else if isGeneratingTitle {
                    prompt = "Give me a story title for this story \(continueStory) in 3 words only. output should be only 3 words nothing extra"
                } else {
                    prompt = "Write a first begining paragraph/pilot of a \(genre) story where \(charactersText)\(lastSeparator)go on a \(theme) adventure together."
                }
            }
            print(prompt)
            return prompt
    }
    
    func generateImagePrompt() async throws {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        let prompt = "Generate me a prompt to create a story book Image using this story \(self.story). within 100 words"
        
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
   // NavigationStack {
        ContentView(shader: .example)
  //  }
}
