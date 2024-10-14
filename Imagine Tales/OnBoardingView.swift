//
//  OnBoardingView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/21/24.
//

import SwiftUI

struct OnBoardingView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true  // Tracks whether the user is still in the onboarding process
    @State private var page: Int = 1  // Tracks the current onboarding page
    @State private var opacity = 1.0  // Controls the opacity for transitions

    var shader = TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)  // Transition effect between onboarding screens
    @State private var backButtonPressed = false  // Tracks when the back button is pressed
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isiPhone = false
    @State private var isShowingSpashScreen = false
    
    var body: some View {
        ZStack {
            // Display the appropriate onboarding image based on the current page
            VStack {
                switch page {
                case 1:
                    onboardingImage("Onboarding-1")
                case 2:
                    onboardingImage("Onboarding-2")
                default:
                    onboardingImage("Onboarding-3")
                }
            }
            
            // Controls for navigation and page indicators
            VStack {
                ZStack {
                    // Back button for pages 2 and 3
                    if page != 1 {
                        HStack {
                            backButton
                            Spacer()
                        }
                        .padding(.leading)
                    }

                    // Stepper indicating progress through the onboarding pages
                    stepper

                    // Forward button for pages 1 and 2
                    if page != 3 {
                        HStack {
                            Spacer()
                            forwardButton
                        }
                        .padding(.trailing)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, 80)
                
                VStack {
                    if page == 1 {
                        Text("Blast off into a galaxy of adventure with friends as you explore the universe!")
                            .font(.custom("ComicNeue-Bold", size: isiPhone ? 22 : 30))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(VisualEffectBlur(blurStyle: .systemThinMaterial))
                            .cornerRadius(22)
                        
                        Spacer()
                            
                    } else if page == 2 {
                        Spacer()
                        Text("Float into a world of fun and creativity, where Imagination knows no bounds!")
                            .font(.custom("ComicNeue-Bold", size: isiPhone ? 22 : 30))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(VisualEffectBlur(blurStyle: .systemThinMaterial))
                            .cornerRadius(22)
                            .padding(.bottom, 80)
                    } else {
                        
                        Text("Journey backs in time to uncover thrilling tales of dinosaurs and their epic advantures!")
                            .font(.custom("ComicNeue-Bold", size: isiPhone ? 22 : 30))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(VisualEffectBlur(blurStyle: .systemThinMaterial))
                            .cornerRadius(22)
                        Spacer()
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.7)
                
                
                
                if page == 3 {
                    Spacer()
                    // "Continue" button to exit onboarding
                    continueButton
                        .padding(.bottom, 80)
                }
            }
            
            
        }
        .onAppear {
            if horizontalSizeClass == .compact {
                isiPhone = true
            }
        }
        .sheet(isPresented: $isShowingSpashScreen, onDismiss: {
            isOnboarding = false
        }) {
            SpashScreen()
        }
    }

    // Reusable function for onboarding images
    private func onboardingImage(_ imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(height: UIScreen.main.bounds.height + 10)
            .ignoresSafeArea()
            .opacity(opacity)
            .drawingGroup()
            .transition(shader.transition)
    }

    // Back button to navigate to the previous page
    private var backButton: some View {
        Button {
            withAnimation(.easeIn(duration: 1.5)) { page -= 1 }
            backButtonPressed.toggle()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: isiPhone ? 50 : 75, height: isiPhone ? 50 : 75)
                    .shadow(radius: 10)
                Image(systemName: "arrowtriangle.backward.fill")
                    .font(.system(size: isiPhone ? 20 : 40))
                    .foregroundStyle(.black)
            }
        }
    }

    // Forward button to navigate to the next page
    private var forwardButton: some View {
        Button {
            withAnimation(.easeIn(duration: 1.5)) { page += 1 }
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: isiPhone ? 50 : 75, height: isiPhone ? 50 : 75)
                    .shadow(radius: 10)
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.system(size: isiPhone ? 20 : 40))
                    .foregroundStyle(.black)
            }
        }
    }

    // Stepper to show onboarding progress
    private var stepper: some View {
        HStack {
            Capsule().foregroundStyle(.orange).frame(width: isiPhone ? 70 : 100, height: 7).shadow(radius: 10)
            Capsule().foregroundStyle(page == 1 ? .white : .orange).frame(width: isiPhone ? 70 : 100, height: 7).shadow(radius: 10)
            Capsule().foregroundStyle(page == 1 ? .white : (page == 2 ? .white : .orange)).frame(width: isiPhone ? 70 : 100, height: 7).shadow(radius: 10)
        }
    }

    // Continue button to exit the onboarding flow - entire button clickable
    private var continueButton: some View {
        Button(action: {
            if isiPhone {
                isShowingSpashScreen.toggle()
            } else {
                isOnboarding = false  // Dismiss onboarding when button is pressed
            }
        }) {
            Text("Continue")
                .frame(width: UIScreen.main.bounds.width / 2, height: 55)
                .background(Color(hex: "#FF6F61"))  // Button background color
                .cornerRadius(22)
                .foregroundColor(.white)  // Button text color
        }
    }
}

#Preview {
    OnBoardingView()
}
