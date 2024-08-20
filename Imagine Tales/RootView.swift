//
//  RootView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView = false
    @State var selectedChild: UserChildren = UserChildren(id: "", parentId: "", name: "", age: "", dateCreated: Date.now)
    var body: some View {
        ZStack {
            TabbarView(showSignInView: $showSignInView, selectedChild: $selectedChild)
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }

        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView, selectedChild: $selectedChild)
            }
        }
        
        
    }
        
}

#Preview {
    RootView(selectedChild: UserChildren(id: "", parentId: "", name: "", age: "", dateCreated: Date.now))
}
