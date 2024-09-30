//
//  TabbarView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FloatingTabBar

// Enum to define different tab items with their titles and icon names
enum TabItems: Int, CaseIterable {
    case home, browse, generate, collection, profile
    
    // Return the title for each tab
    var title: String {
        switch self {
        case .home: return "Home"
        case .browse: return "Browse"
        case .generate: return "Generate"
        case .collection: return "Collection"
        case .profile: return "Profile"
        }
    }
    
    // Return the icon name for each tab
    var iconName: String {
        switch self {
        case .home: return "house"
        case .browse: return "safari"
        case .generate: return "plus.app"
        case .collection: return "books.vertical"
        case .profile: return "person"
        }
    }
}

// The main view that handles the tab navigation
struct TabbarView: View {
    @Binding var showSignInView: Bool  // Whether to show the sign-in view
    @Binding var reload: Bool  // Whether to reload views
    
    @State private var selectedTab = 2  // Index of the currently selected tab (default: ContentView)
    @State private var isShowingFriendReq = false  // Whether the friend request view is shown
    @State private var isSearching = false  // Whether the search view is shown
    @State private var showingProfile = false  // Whether the profile is shown
    @AppStorage("dpurl") private var dpUrl = ""  // URL for the profile picture (from AppStorage)
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = FriendsViewModel()
    @AppStorage("childId") var childId: String = "Default Value"
    var body: some View {
        // Navigation container for the app
        NavigationStack {
            ZStack(alignment: .bottom) {
                BackGroundMesh().ignoresSafeArea()  // Full-screen background
                
                // Switch between views based on the selected tab
                switch selectedTab {
                case 0: HomeView(reload: $reload).padding()
                case 1: ExploreView().padding().ignoresSafeArea(edges: .top)
                case 2: ContentView().padding()
                case 3: SavedStoryView(reload: $reload).padding()
                case 4: ProfileView(showSignInView: $showSignInView, reload: $reload, showingProfile: $showingProfile).padding()
                default: HomeView(reload: $reload).padding()
                }
                
                // Custom floating tab bar at the bottom
                HStack {
                    ForEach(TabItems.allCases, id: \.self) { item in
                        Button {
                            // Update selected tab and reload if different from the current one
                            if selectedTab != item.rawValue {
                                selectedTab = item.rawValue
                                reload.toggle()
                            }
                            showingProfile = selectedTab == 4  // Show profile when the profile tab is selected
                        } label: {
                            // Custom tab item with icon and title
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: selectedTab == item.rawValue)
                        }
                    }
                }
                .padding(6)
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 70)  // Set tab bar size
                .background(colorScheme == .light ? Color(hex: "#FFFFF1") : Color(hex: "#3A3A3A"))  // Background color for tab bar
                .cornerRadius(20)  // Rounded corners
                .padding(.horizontal, 26)
                .shadow(radius: 10)  // Shadow for a floating effect
            }
            .onAppear {
                viewModel.fetchFriendRequests(childId: childId)
                viewModel.fetchNotifications(for: childId)
            }
        }
        .toolbar {
            // Toolbar item for the profile picture on the left side
            ToolbarItemGroup(placement: .navigationBarLeading) {
                ZStack {
                    Circle().fill(colorScheme == .dark ? Color(hex: "#3A3A3A") : Color.white).frame(width: 45, height: 45)
                    AsyncCircularImageView(urlString: dpUrl, size: 40).clipShape(Circle())  // Profile picture
                }
                .onTapGesture {
                    selectedTab = 4
                }
            }
            
            // Toolbar items for search and notifications on the right side
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Button for search functionality
                Button("search", systemImage: "magnifyingglass") {
                    isSearching = true
                }
                .popover(isPresented: $isSearching) {
                    SearchView().frame(width: 800, height: 900)  // Search popover view
                }
                
                // Button for notifications (friend requests)
                Button("Notifications", systemImage: viewModel.friendRequests.isEmpty && viewModel.notifications.isEmpty ? "bell" : "bell.badge") {
                    isShowingFriendReq = true
                }
                .symbolRenderingMode(.palette)
                .foregroundStyle(viewModel.friendRequests.isEmpty && viewModel.notifications.isEmpty ? colorScheme == .dark ? .white : .black : .red, colorScheme == .dark ? .white : .black)
                .font(.system(size: 20))
                .popover(isPresented: $isShowingFriendReq) {
                    FriendRequestView().frame(width: 600, height: 700)  // Friend request popover view
                }
            }
        }
        .tint(.primary)  // Set tint color for toolbar items
    }
}

#Preview {
    // Preview the TabbarView with constant binding values
    TabbarView(showSignInView: .constant(false), reload: .constant(false))
}
