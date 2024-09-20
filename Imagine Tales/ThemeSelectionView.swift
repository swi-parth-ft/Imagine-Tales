import SwiftUI

struct ThemeSelectionView: View {
    // Sample data for themes
    let themes = [
        ("Space", "space_icon"),
        ("Wizard's Secrets", "wizard_icon"),
        ("Jungle", "jungle_icon"),
        ("Dinosaur Discoveries", "dinosaur_icon"),
        ("Fairy Tale Kingdoms", "castle_icon"),
        ("Cartoon", "cartoon_icon"),
        ("Adventure", "adventure_icon"),
        ("Desert Dunes", "desert_icon"),
        ("Robots", "robot_icon"),
        ("Space", "space_icon"),
        ("Wizard's Secrets", "wizard_icon"),
        ("Jungle", "jungle_icon"),
        ("Dinosaur Discoveries", "dinosaur_icon"),
        ("Fairy Tale Kingdoms", "castle_icon"),
        ("Cartoon", "cartoon_icon"),
        ("Adventure", "adventure_icon"),
        ("Desert Dunes", "desert_icon"),
        ("Robots", "robot_icon")

    ]
    
    // State for selected theme
    @State private var selectedTheme: String? = nil
    
    // Define the grid layout for a hexagonal-like grid
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            Text("Select Theme")
                .font(.headline)
                .padding()
            
            // Horizontal ScrollView for the hex-like grid
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: columns, spacing: 16) {
                    ForEach(themes, id: \.0) { theme in
                        VStack {
                            Circle()
                                .fill(self.selectedTheme == theme.0 ? Color.blue : Color.clear)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(theme.1) // Replace with your theme icons
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                )
                                .background(
                                    Circle()
                                        .strokeBorder(Color.black, lineWidth: 1)
                                        .frame(width: 100, height: 100)
                                )
                                .onTapGesture {
                                    self.selectedTheme = theme.0
                                }
                            
                            Text(theme.0)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Next Button
            Button(action: {
                // Action for Next Button
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct ThemeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectionView()
    }
}
