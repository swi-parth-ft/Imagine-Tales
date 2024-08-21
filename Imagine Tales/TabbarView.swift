//
//  TabbarView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FloatingTabBar

struct TabbarView: View {
   

    @Binding var showSignInView: Bool
    
    
    var body: some View {
        
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Image(systemName: "Person.fill")
                    Text("Profile")
                }
        }
        
       
    }
}

#Preview {
    TabbarView(showSignInView: .constant(false))
}
