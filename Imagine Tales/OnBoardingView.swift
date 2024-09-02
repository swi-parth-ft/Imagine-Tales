//
//  OnBoardingView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/21/24.
//

import SwiftUI

struct OnBoardingView: View {
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @State private var page: Int = 1
    
    /// Whether we're showing the first view or the second view.
    @State private var showingFirstView = true

    /// The opacity of our preview view, so users can check how fading works.
    @State private var opacity = 1.0

    /// The shader we're rendering.
    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    

    @State private var showDetail = false
    @State private var backButtonPressed = false
    
    var body: some View {
        ZStack {
            VStack {
                if page == 1 {
                    Image("Onboarding-1")
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height + 10)
                        .ignoresSafeArea()
                        .opacity(opacity)
                        .drawingGroup()
                        .transition(shader.transition)
                } else if page == 2 {
                    Image("Onboarding-2")
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height + 10)
                        .ignoresSafeArea()
                        .opacity(opacity)
                        .drawingGroup()
                        .transition(shader.transition)
                } else {
                    Image("Onboarding-3")
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height + 10)
                        .ignoresSafeArea()
                        .opacity(opacity)
                        .drawingGroup()
                        .transition(shader.transition)
                }
                
            }
            
            VStack {
                ZStack {
                    
                    if page != 1 {
                        HStack {
                            
                            Button {
                                withAnimation(.easeIn(duration: 1.5)) {
                                    page -= 1
                                }
                                backButtonPressed.toggle()
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.white)
                                        .frame(width: 75, height: 75)
                                        .shadow(radius: 10)
                                    
                                    Image("arrow1")
                                        .frame(width: 55, height: 55)
                                }
                            }
                            Spacer()
                            
                            
                        }.padding(.leading, 100)
                    }
                    
                    //Stepper
                    HStack {
                        Capsule()
                            .foregroundStyle(.orange)
                            .frame(width: 100, height: 7)
                            .shadow(radius: 10)
                        
                        Capsule()
                            .foregroundStyle(page == 1 ? .white : .orange)
                            .frame(width: 100, height: 7)
                            .shadow(radius: 10)
                        
                        Capsule()
                            .foregroundStyle(page == 1 ? .white : (page == 2 ? .white : .orange))
                            .frame(width: 100, height: 7)
                            .shadow(radius: 10)
                    }
                    //Forward Button
                    if page != 3 {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.easeIn(duration: 1.5)) {
                                    page += 1
                                }
                                
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.white)
                                        .frame(width: 75, height: 75)
                                        .shadow(radius: 10)
                                    
                                    Image("forward")
                                        .frame(width: 55, height: 55)
                                }
                            }
                            
                            
                            
                        }.padding(.trailing, 100)
                    }
                    
                    
                }
                .padding(.top, 80)
                
                Spacer()
                Button("Continue") {
                    isOnboarding = false
                }
                .frame(width: UIScreen.main.bounds.width / 2, height: 55)
                .background(Color(hex: "#FF6F61"))
                .cornerRadius(22)
                .foregroundColor(.white)
                .padding(.bottom, 80)
            }
        }
        
    }
}

#Preview {
    OnBoardingView()
}
