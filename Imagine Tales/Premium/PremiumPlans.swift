//
//  PremiumPlans.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/15/24.
//

import SwiftUI
import RevenueCat
class PremiumPlansViewModel: ObservableObject {
    @Published var monthlyPackage: Package?
    @Published var annualPackage: Package?
    @Published var errorMessage: String?
    
    // Fetch offerings
    func fetchOfferings() {
        Purchases.shared.getOfferings { (offerings, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else if let currentOffering = offerings?.current {
                self.monthlyPackage = currentOffering.monthly
                self.annualPackage = currentOffering.annual
            }
        }
    }
    
    // Handle purchasing the selected package
        func purchasePackage(_ package: Package) {
            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let customerInfo = customerInfo, customerInfo.entitlements["premium"]?.isActive == true {
                    // Successful purchase logic
                }
            }
        }
    
}

struct PremiumFeatureRow: View {
    var icon: String
    var title: String
    var description: String
    @StateObject private var viewModel = PremiumPlansViewModel()
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct PremiumPlans: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @AppStorage("isInitiallyShowingPlansScreen") var isInitiallyShowingPlansScreen: Bool = true
    
    @AppStorage("remainingDays") var remainingDays: Int = 2
    @AppStorage("remainingStories") var remainingStories: Int = 3
    @State private var isiPhone = false
    
    @StateObject private var viewModel = PremiumPlansViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                ScrollView {
                    VStack {
                        
                        if isInitiallyShowingPlansScreen {
                            ZStack {
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .cornerRadius(22)
                                    .shadow(radius: 10)
                                VStack {
                                    
                                    Text("✨ Free 7-Day Trial ✨")
                                        .font(isiPhone ? .title2 : .title)
                                        .bold()
                                    Text("Create up to 5 stories with 2 characters and explore the magic of imagination!")
                                        .multilineTextAlignment(.center)
                                    Text("Enjoy all features with no commitment.")
                                    
                                    Button {
                                        dismiss()
                                    } label: {
                                        Text("Start Free Trial")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                            .foregroundStyle(.white)
                                            .cornerRadius(22)
                                    }
                                    
                                }
                                .font(.system(size: isiPhone ? 18 : 22))
                                .padding()
                            }
                            .padding()
                        } else {
                            ZStack {
                                VisualEffectBlur(blurStyle: .systemThinMaterial)
                                    .cornerRadius(22)
                                    .shadow(radius: 10)
                                VStack {
                                    if isiPhone {
                                        VStack {
                                            Text("Current Plan")
                                                .padding()
                                                .background(
                                                    VisualEffectBlur(blurStyle: .systemThinMaterial)
                                                        .cornerRadius(22)
                                                        .shadow(radius: 5)
                                                )
                                            Text("7 Days Free Trial")
                                                .font(.title)
                                                .foregroundStyle(Color(hex: "#FF6F61"))
                                                .bold()
                                            
                                        }.padding()
                                    } else {
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
                                                .font(.title)
                                                .foregroundStyle(Color(hex: "#FF6F61"))
                                                .bold()
                                            
                                        }.padding()
                                    }
                                    
                                    // Trial status message
                                    Text("You have \(remainingStories) stories and \(remainingDays) days left of your trial!")
                                        .font(isiPhone ? .title2 : .title)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    // Creative line
                                    Text("Unlock endless creativity and never stop exploring new worlds! 🚀")
                                        .font(isiPhone ? .title2 : .title)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    // Prompt to check premium options
                                    Text("Check out the premium options below!")
                                        .font(isiPhone ? .title2 : .title)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                }
                                .font(.system(size: isiPhone ? 18 : 22))
                                .padding()
                            }
                            .padding()
                        }
                        
                        if isiPhone {
                            VStack {
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
                                        
                                        Text(viewModel.monthlyPackage?.localizedPriceString ?? "$1.99")
                                            .font(.title)
                                            .bold()
                                        
                                        Image("premium")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 150)
                                        
                                        Button {
                                            
                                            if let monthly = viewModel.monthlyPackage {
                                                viewModel.purchasePackage(monthly)
                                            }
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
                                .padding(.horizontal)
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
                                            Text(viewModel.annualPackage?.localizedPriceString ?? "$1.99")
                                                .font(.largeTitle)
                                                .bold()
                                        }
                                        
                                        
                                        Image("permiumYearly")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 150)
                                        Button {
                                            
                                            if let annual = viewModel.annualPackage {
                                                viewModel.purchasePackage(annual)
                                            }
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
                        } else {
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
                                        
                                        Text(viewModel.monthlyPackage?.localizedPriceString ?? "$1.99")
                                            .font(.largeTitle)
                                            .bold()
                                        
                                        Image("premium")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                        
                                        Button {
                                            
                                            if let monthly = viewModel.monthlyPackage {
                                                viewModel.purchasePackage(monthly)
                                            }
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
                                .padding(.horizontal)
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
                                            Text(viewModel.annualPackage?.localizedPriceString ?? "$1.99")
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
                                            
                                            if let annual = viewModel.annualPackage {
                                                viewModel.purchasePackage(annual)
                                            }
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
                                .padding(.horizontal)
                            }
                            .font(.system(size: 22))
                            .padding(.bottom)
                        }
                        ZStack(alignment: .leading) {
                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                                .cornerRadius(22)
                                .shadow(radius: 10)
                            VStack(alignment: .leading) {
                              
                                
                                Text("Why Go Premium?")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 10)
                                
                                PremiumFeatureRow(icon: "infinity", title: "Unlimited Stories", description: "Keep the creativity flowing without limits!")
                                
                                PremiumFeatureRow(icon: "star", title: "Exclusive Themes & Genres", description: "Access premium content that sparks new adventures.")
                                
                                PremiumFeatureRow(icon: "pawprint.fill", title: "Custom Characters & Pets", description: "Add more depth to your stories, including adorable pets!")
                                
                                PremiumFeatureRow(icon: "nosign", title: "Ad-Free Experience", description: "Enjoy storytelling without interruptions.")
                                
                                PremiumFeatureRow(icon: "person.crop.circle.fill.badge.checkmark", title: "Priority Support", description: "Get assistance whenever you need it.")
                                
                            }
                            .tint(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 22))
                            .padding()
                            
                        }
                        .padding(.horizontal)
                        
                        
                    }
                }
                .onAppear {
                    viewModel.fetchOfferings()
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
    PremiumPlans()
}
