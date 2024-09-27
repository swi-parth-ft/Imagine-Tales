//
//  Utilities.swift
//  Firebase Bootcamp
//
//  Created by Parth Antala on 8/12/24.
//

import Foundation
import UIKit

final class Utilities {
    
    // Singleton instance
    static let shared = Utilities()
    
    // Private initializer to enforce singleton usage
    private init() {}
    
    /// Retrieves the topmost view controller in the current window's view hierarchy.
    /// - Parameter controller: The starting view controller (optional).
    /// - Returns: The top view controller if found, otherwise nil.
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        // Use the provided controller or the root view controller if none is provided
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        // Check if the controller is a UINavigationController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        // Check if the controller is a UITabBarController
        if let tabController = controller as? UITabBarController {
            // If a selected view controller exists, get its top view controller
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        // Check for a presented view controller
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        // Return the current controller if no other controllers are found
        return controller
    }
}
