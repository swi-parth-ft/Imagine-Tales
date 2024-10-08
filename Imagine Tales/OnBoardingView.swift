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
                        }.padding(.leading, 100)
                    }

                    // Stepper indicating progress through the onboarding pages
                    stepper

                    // Forward button for pages 1 and 2
                    if page != 3 {
                        HStack {
                            Spacer()
                            forwardButton
                        }.padding(.trailing, 100)
                    }
                }
                .padding(.top, 80)

                Spacer()
                
                
                // "Continue" button to exit onboarding
                continueButton
                    .padding(.bottom, 80)
            }
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
                    .frame(width: 75, height: 75)
                    .shadow(radius: 10)
                Image("arrow1")
                    .frame(width: 55, height: 55)
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
                    .frame(width: 75, height: 75)
                    .shadow(radius: 10)
                Image("forward")
                    .frame(width: 55, height: 55)
            }
        }
    }

    // Stepper to show onboarding progress
    private var stepper: some View {
        HStack {
            Capsule().foregroundStyle(.orange).frame(width: 100, height: 7).shadow(radius: 10)
            Capsule().foregroundStyle(page == 1 ? .white : .orange).frame(width: 100, height: 7).shadow(radius: 10)
            Capsule().foregroundStyle(page == 1 ? .white : (page == 2 ? .white : .orange)).frame(width: 100, height: 7).shadow(radius: 10)
        }
    }

    // Continue button to exit the onboarding flow - entire button clickable
    private var continueButton: some View {
        Button(action: {
            isOnboarding = false  // Dismiss onboarding when button is pressed
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
