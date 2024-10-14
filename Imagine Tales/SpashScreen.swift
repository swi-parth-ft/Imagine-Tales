//
//  SpashScreen.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/14/24.
//

import SwiftUI

struct SpashScreen: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                ScrollView {
                    VStack {
                        ZStack {
                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                .opacity(0.5)
                                .cornerRadius(22)
                            
                            VStack {
                                Image("Parents")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                Text("Welcome Parents!")
                                    .font(.custom("ComicNeue-Bold", size: 22))
                                Text("Manage your child's activities and content")
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Continue as Parent")
                                        .padding()
                                        .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                        .foregroundStyle(.white)
                                        .cornerRadius(16)
                                }
                                
                            }
                            .padding()
                        }
                        .padding()
                        .frame(height: UIScreen.main.bounds.height * 0.55)
                        
                        ZStack {
                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                .opacity(0.5)
                                .cornerRadius(22)
                            VStack {
                                HStack {
                                    Image("Children")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150)
                                    Spacer()
                                    
                                    Text("Children's Playground is available on iPad")
                                        .font(.custom("ComicNeue-Bold", size: 22))
                                        .padding()
                                        .multilineTextAlignment(.center)
                                        .background(.yellow)
                                        .foregroundStyle(.white)
                                        .cornerRadius(16)
                                }
                                Text("Switch to iPad for your child to play, imagine, create and share stories with friends! ")
                                
                            }
                            .padding()
                        }
                        .padding([.horizontal, .bottom])
                        
                        
                    }
                }
            }
            
        }
    }
}

#Preview {
    SpashScreen()
}
