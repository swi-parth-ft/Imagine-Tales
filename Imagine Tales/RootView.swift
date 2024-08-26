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
    @AppStorage("ipf") private var ipf: Bool = true
    @State private var reload = false
    
    var body: some View {
        ZStack {
            if isiPhone || ipf {
                ParentView(showSigninView: $showSignInView, reload: $reload, isiPhone: $isiPhone)
            } else {
                TabbarView(showSignInView: $showSignInView, reload: $reload)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
            if horizontalSizeClass == .compact {
                isiPhone = true
            }
        }

        .fullScreenCover(isPresented: $showSignInView, onDismiss: { reload.toggle() } ) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView, isiPhone: $isiPhone, isParentFlow: $isParentFlow)
            }
        }
        
        
    }
        
}

#Preview {
    RootView()
}
