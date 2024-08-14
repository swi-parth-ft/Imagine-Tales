//
//  TabbarView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FloatingTabBar

struct TabbarView: View {
   
    @State var items: [BottomBarItem] = [
        BottomBarItem(icon: "circle.grid.hex", color: Color.iconColor),
        BottomBarItem(icon: "bookmark", color: Color.iconColor),
        BottomBarItem(icon: "plus", color: Color.iconColor),
        BottomBarItem(icon: "heart", color: Color.iconColor),
        BottomBarItem(icon: "person", color: Color.iconColor)
    ]
    
    @State public var selectedIndex: Int = 0
    
    let viewList = [ContentView(),
                    ContentView(),
                    ContentView(),
                    ContentView(),
                    ContentView()]
    
    var body: some View {
        
        ZStack {
            
            NavigationView {
            viewList[selectedIndex]
            }
            
            VStack {
                Spacer()
                ZStack {
                    BottomBar(selectedIndex: $selectedIndex, items: $items)
                        .cornerRadius(20)
                        .shadow(color: Color.darkTextColorMain.opacity(0.1), radius: 10,
                                x: 10,
                                y: 5)
                }.padding(EdgeInsets(top: 0,
                                     leading: 40,
                                     bottom: -10,
                                     trailing: 40))
                
            }
        }
//        TabView {
//            NavigationStack {
//                ContentView()
//            }
//            .tabItem {
//                Image(systemName: "circle.grid.hex")
//                Text("Imagine")
//            }
//            
//            NavigationStack {
//                ContentView()
//            }
//            .tabItem {
//                Image(systemName: "magnifyingglass")
//                Text("Imagine")
//            }
//            
//            NavigationStack {
//                ContentView()
//            }
//            .tabItem {
//                Image(systemName: "plus")
//                Text("Imagine")
//            }
//            
//            NavigationStack {
//                ContentView()
//            }
//            .tabItem {
//                Image(systemName: "heart")
//                Text("Imagine")
//            }
//            
//            NavigationStack {
//                ContentView()
//            }
//            .tabItem {
//                Image(systemName: "person")
//                Text("Imagine")
//            }
//        }
//        .background(.white)
        
       
    }
}

#Preview {
    TabbarView()
}
