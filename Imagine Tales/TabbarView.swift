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
    @Binding var reload: Bool
    
    @State private var selectedTab = 2
    @State private var isSearching = false
    @State private var isShowingFriendReq = false
    @State private var showingProfile = false
    
    @AppStorage("dpurl") private var dpUrl = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                BackGroundMesh().ignoresSafeArea()
                    
                ZStack {
                    switch selectedTab {
                    case 0:
                        HomeView(reload: $reload)
                            .padding()
                    case 1:
                        ExploreView()
                            .padding()
                            .ignoresSafeArea(edges: .top)
                    case 2:
                        ContentView()
                            .padding()
                    case 3:
                        SavedStoryView(reload: $reload)
                            .padding()
                    case 4:
                        ProfileView(showSignInView: $showSignInView, reload: $reload, showingProfile: $showingProfile)
                            .padding()
                    default:
                        HomeView(reload: $reload)
                            .padding()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    ZStack{
                        HStack{
                            ForEach((TabItems.allCases), id: \.self){ item in
                                Button {
                                    if selectedTab != item.rawValue {
                                        selectedTab = item.rawValue
                                        reload.toggle()
                                    }
                                    showingProfile = selectedTab == 4
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
                
            }
            .onAppear {
                hideSystemTabBar()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 45, height: 45)
                    AsyncCircularImageView(urlString: dpUrl, size: 40)
                        .clipShape(Circle())
                }
             
            }
            
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("search", systemImage: "magnifyingglass") {
                    isSearching = true
                }
                
                
                Button("Notifications", systemImage: "bell") {
                    isShowingFriendReq = true
                }
                .popover(isPresented: $isShowingFriendReq) {
                    FriendRequestView()
                        .frame(width: 600, height: 700)
                }
            }
        }
        .tint(.black)
        .sheet(isPresented: $isSearching, onDismiss: {
        
        }) {
            SearchView()
              
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





struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
