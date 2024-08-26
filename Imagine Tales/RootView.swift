//
//  RootView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView = true
    @State private var isiPhone = false
    @State private var isParentFlow = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            if isiPhone || isParentFlow {
                ParentView(showSigninView: $showSignInView)
            } else {
                TabbarView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
            if horizontalSizeClass == .compact {
                isiPhone = true
            }
        }

        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView, isiPhone: $isiPhone, isParentFlow: $isParentFlow)
            }
        }
        
        
    }
        
}

#Preview {
    RootView()
}
