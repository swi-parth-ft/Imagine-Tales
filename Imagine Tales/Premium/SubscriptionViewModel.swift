//
//  SubscriptionViewModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/22/24.
//


import Foundation
import RevenueCat
import Combine
import SwiftUICore

class SubscriptionViewModel: ObservableObject {
    @Published var hasActiveSubscription: Bool = false
    @Published var errorMessage: String?
    @Published var isTrialModel = false
    
    // Function to log in the user and fetch customer info
    func loginUser(with parentId: String)  {
        Purchases.configure(withAPIKey: "", appUserID: parentId)
        
        Purchases.shared.logIn(parentId) { (customerInfo, created, error) in
            if let error = error {
                self.errorMessage = "Error logging in: \(error.localizedDescription)"
                return
            }

            if created {
                print("New RevenueCat user created. \(parentId)")
            } else {
                print("Existing RevenueCat user logged in. \(parentId)")
            }

            
            self.fetchCustomerInfo()
        }
        
    }
    
    // Function to fetch customer info from RevenueCat
    private func fetchCustomerInfo() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                self.errorMessage = "Error fetching customer info: \(error.localizedDescription)"
                return
            }

            guard let customerInfo = customerInfo else { return }
            print("Customer Info: \(customerInfo.entitlements.active)")
            self.checkSubscriptionStatus(customerInfo: customerInfo)
         //   self.restorePurchases()
        }
    }
    
    // Function to check subscription status
    private func checkSubscriptionStatus(customerInfo: CustomerInfo) {
        if let entitlements = customerInfo.entitlements.active.first(where: { $0.key == "premium" }) {
            print("User has an active subscription: \(entitlements.value)")
            self.hasActiveSubscription = true
        
        } else {
            print("User does not have an active subscription.")
            self.hasActiveSubscription = false
            self.isTrialModel = false
        }
    }
    
    func restorePurchases() {
        
        Purchases.shared.restorePurchases { (info, error) in
            if let error = error {
                // Handle the error (e.g., show an alert)
                print("Error restoring purchases: \(error.localizedDescription)")
                return
            }
            
            // Purchases restored successfully
            if let info = info {
                // You can check the restored info here
                print("Restored purchases: \(info.entitlements.all)")
                
                // Update your app's state according to the restored purchases
                for entitlement in info.entitlements.active {
                    print("Restored entitlement: \(entitlement.key)")
                    // Here you can update your app to reflect the restored purchase
                    self.hasActiveSubscription = true
                }
            }
        }
    }

}
