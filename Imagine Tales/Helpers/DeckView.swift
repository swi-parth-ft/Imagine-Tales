import SwiftUI
import CardStack

struct Imgs: Identifiable {
    var id: Int
    var name: String
    
}
struct DeckView: View {
    let items = [Imgs(id: 1, name: "dp1"), Imgs(id: 2, name: "dp2"), Imgs(id: 3, name: "dp3")]
    @StateObject private var viewModel = ExploreViewModel()
    @State private var retryCount = 0 // Count for retry attempts when loading images
    @State private var maxRetryAttempts = 3 // Maximum number of retry attempts
    @State private var retryDelay = 2.0 // Delay between retries
    @State private var selectedStory: Story?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            CardStack(viewModel.topStories) { story in
                HStack {
                    Spacer()
                    ZStack {
                        AsyncImage(url: URL(string: story.storyText[0].image)) { phase in
                            switch phase {
                            case .empty:
                                // Placeholder for loading
                                MagicView()
                                    .frame(width: 500, height: 500)
                                
                            case .success(let image):
                                // Successfully loaded image
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 500, height: 500)
                                    .clipped()
                                    .cornerRadius(30)
                                    .shadow(radius: 5)
                                    
                                
                            case .failure(_):
                                // Placeholder for failed load
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 500, height: 500)
                                    .cornerRadius(10)
                                    .padding()
                                    .onAppear {
                                        // Retry loading if the count is below max attempts
                                        if retryCount < maxRetryAttempts {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                                retryCount += 1
                                            }
                                        }
                                    }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        VStack {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 23)
                                        .fill(Color.white.opacity(0.8))
                                        
                                        .cornerRadius(16)
                                VStack(spacing: 0) {
                                    
                                    Text(story.title)
                                        .font(.system(size: 18))
                                    Text("By \(story.childUsername)")
                                        .font(.system(size: 16))
                                        .padding(.top, -20)
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(.red)
                                        Text("\(story.likes) Likes")
                                            .padding(.trailing)
                                        
                                        Text(story.theme ?? "")
                                            .padding(7)
                                            .background(colorScheme == .dark ? Color(hex: "#4B8A1C") : .green)
                                            .foregroundStyle(.white)
                                            .cornerRadius(22)
                                            
                                    }
                                    .font(.system(size: 16))
                                    .padding(.top)
                                    Button {
                                        selectedStory = story
                                    } label: {
                                        HStack {
                                            Text("Read Now")
                                            Image(systemName: "book.pages")
                                        }
                                        .frame(width: 300)
                                    }
                                    .padding()
                                    .font(.system(size: 16))
                                    .background(Color(hex: "#FF6F61"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(16)
                                    .padding(.top)
                                }
                                .foregroundStyle(.black)
                            }
                            .frame(width: 450, height: 200)
                            .padding()
                            
                        }
                        .frame(width: 500, height: 500)
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .fullScreenCover(item: $selectedStory) { story in
            StoryFromProfileView(story: story)
    }
        .onAppear {
            viewModel.getMostLikedStories()
        }
    }
}

#Preview {
    DeckView()
}
