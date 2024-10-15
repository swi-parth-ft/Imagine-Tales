//
//  PremiumPlans.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/15/24.
//

import SwiftUI



struct PremiumPlans: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPremium: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        ZStack {
                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                .cornerRadius(22)
                                .shadow(radius: 10)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Current Plan")
                                        .padding()
                                        .background(
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .cornerRadius(22)
                                                .shadow(radius: 5)
                                        )
                                    Spacer()
                                    Text("7 Days Free Trial")
                                        .foregroundStyle(Color(hex: "#FF6F61"))
                                    
                                }.padding()
                                Spacer()
                                Text("- 5 Stories creation").padding()
                                Text("- Create up to 2 unique character to star").padding()
                                Text("- Ads included").padding()
                                
                            }
                            .font(.system(size: 22))
                            .padding()
                        }
                        .padding()
                        
                        HStack {
                            ZStack {
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .cornerRadius(22)
                                    .shadow(radius: 10)
                                VStack {
                                    Text("Monthly Plan")
                                        .padding()
                                        .background(
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .cornerRadius(22)
                                                .shadow(radius: 5)
                                            
                                        )
                                    
                                    Text("$14.99")
                                        .font(.largeTitle)
                                        .bold()
                                    
                                    Image("premium")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                    
                                    Button {
                                        isPremium = true
                                    } label: {
                                        Text("Purchase")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                            .foregroundStyle(.white)
                                            .cornerRadius(22)
                                    }
                                }
                                .padding()
                            }
                            .padding()
                            ZStack {
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .cornerRadius(22)
                                    .shadow(radius: 10)
                                VStack {
                                    Text("Yearly Plan")
                                        .padding()
                                        .background(
                                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                .cornerRadius(22)
                                                .shadow(radius: 5)
                                            
                                        )
                                    HStack {
                                        Text("$179.88")
                                            .font(.title3)
                                            .foregroundStyle(.gray)
                                            .bold()
                                            .overlay(
                                                Rectangle()
                                                    .frame(height: 2) // Stroke height
                                                    .foregroundColor(.black),// Stroke color
                                                
                                                alignment: .center
                                            )
                                        Text("$159.99")
                                            .font(.largeTitle)
                                            .bold()
                                    }
                                    
                                    
                                    Image("permiumYearly")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                    Button {
                                        isPremium = true
                                    } label: {
                                        Text("Purchase")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                            .foregroundStyle(.white)
                                            .cornerRadius(22)
                                            
                                    }
                                }
                                .padding()
                            }
                            .padding()
                        }
                        .font(.system(size: 22))
                        
                        ZStack(alignment: .leading) {
                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                .cornerRadius(22)
                                .shadow(radius: 10)
                            VStack(alignment: .leading) {
                                Text("Why Go Premium?")
                                    .font(.title)
                                    .bold()
                                Text("- Unlimited Story Access").padding()
                                Text("- Create unlimited unique character to star").padding()
                                Text("- Ad-Free Reading").padding()
                                Text("- Early Access to new Themes").padding()
                            }
                            .font(.system(size: 22))
                            .padding()
                            
                        }
                        .padding()
                        
                        
                    }
                }
                
            }
            .navigationTitle("Premium Plans")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Not now")
                    }
                }
            }
        }
    }
}

#Preview {
    PremiumPlans(isPremium: .constant(false))
}
