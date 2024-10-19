//
//  PremiumPop.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/15/24.
//

import SwiftUI

struct PremiumPop: View {
    @Environment(\.colorScheme) var colorScheme
    let name: String
    @State private var isShowingPremiumScreen = false
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    Text("Your Free Trial Has Ended!")
                        .font(.title)
                    Image("money")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                    Text("🌟 Ready for more adventures?")
                        .font(.title2)
                    Text("🔓 Unlock unlimited storytelling and 🌍 dive into new worlds with our Premium Plan!​")
                        .multilineTextAlignment(.center)
                    
                    
                    
                    Button {
                        isShowingPremiumScreen.toggle()
                    } label: {
                        Text("Unlock Now")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                            .foregroundStyle(.white)
                            .cornerRadius(22)
                    }
                    .padding(.top)
                }
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .fullScreenCover(isPresented: $isShowingPremiumScreen) {
                    PremiumPlans()
                }
            }
        }
    }
}

#Preview {
    PremiumPop(name: "parth")
}
