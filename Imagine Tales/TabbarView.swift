//
//  TabbarView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FloatingTabBar

enum TabItems: Int, CaseIterable {
    case home = 0
    case browse
    case generate
    case collection
    case profile
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .browse:
            return "Browse"
        case .generate:
            return "Generate"
        case .collection:
            return "Collection"
        case .profile:
            return "Profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .browse:
            return "safari"
        case .generate:
            return "plus.app"
        case .collection:
            return "books.vertical"
        case .profile:
            return "person"
        }
    }
}

struct TabbarView: View {
    
    
    @Binding var showSignInView: Bool
    @State private var selectedTab = 2
    @Binding var reload: Bool
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
        ZStack(alignment: .bottom) {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: bookBackgroundColors
            ).ignoresSafeArea()
            TabView(selection: $selectedTab) {
                HomeView(reload: $reload)
                    .tag(0)
                    .padding()
                
                FriendsView()
                    .tag(1)
                    .padding()
                
                ContentView()
                    .tag(2)
                    .padding()
                
                SavedStoryView(reload: $reload)
                    .tag(3)
                    .padding()
                
                ProfileView(showSignInView: $showSignInView, reload: $reload)
                    .tag(4)
                    .padding()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            ZStack{
                HStack{
                    ForEach((TabItems.allCases), id: \.self){ item in
                        Button{
                            selectedTab = item.rawValue
                            reload.toggle()
                        } label: {
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
                .padding(6)
            }
            .frame(width: UIScreen.main.bounds.width * 0.95, height: 70)
            .background(Color(hex: "#FFFFF1"))
            .cornerRadius(20)
            .padding(.horizontal, 26)
            .shadow(radius: 10)
        }
        .onAppear {
                hideSystemTabBar()
            }
        }
        
        // Hide system tab bar
        private func hideSystemTabBar() {
            UITabBar.appearance().isHidden = true
            // For iPad compatibility, force a redraw
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UITabBar.appearance().isHidden = true
            }
        }
        
    
}

#Preview {
    TabbarView(showSignInView: .constant(false), reload: .constant(false))
}



extension TabbarView{
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            Image(systemName: isActive ? imageName + ".fill" : imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .black)
                .frame(width: 20, height: 20)
            if isActive{
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .black)
            }
            Spacer()
        }
        .frame(width: isActive ? 140 : 120, height: 50)
        .background(isActive ? Color(hex: "#8AC640") : .clear)
        .cornerRadius(12)
        .padding(.horizontal, 5)
    }
}
