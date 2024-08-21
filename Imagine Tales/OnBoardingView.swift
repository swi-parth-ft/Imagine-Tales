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
    
    var body: some View {
        ZStack {
            Image(page == 1 ? "Onboarding-1" : (page == 2 ? "Onboarding-2" : "Onboarding-3"))
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 10)
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    
                    if page != 1 {
                        HStack {
                            
                            Button {
                                
                                page -= 1
                                
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
                                
                                page += 1
                                
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
