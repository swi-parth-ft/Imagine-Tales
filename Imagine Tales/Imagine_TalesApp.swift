//
//  Imagine_TalesApp.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/6/24.
//

/**
 The main app file for Imagine Tales.
 
 - Handles the initialization of Firebase, manages app state, and sets up onboarding and root views.
 - Utilizes `@UIApplicationDelegateAdaptor` to configure Firebase during app launch.
 - Integrates an app-wide state management system using `@EnvironmentObject` to track sign-in views, manage screen time, and handle device orientation.
 - Displays either the `OnBoardingView` or `RootView` based on whether the user is still in the onboarding process.
*/

import SwiftUI
import FirebaseCore  // For initializing Firebase
import FirebaseAuth  // For handling user authentication
import GoogleMobileAds

// MARK: - AppState Class

/// A shared, observable object to manage app-level state, particularly for tracking if the user is in the sign-in view.
class AppState: ObservableObject {
    static let shared = AppState()  // Singleton instance of the app state
    @Published var isInSignInView: Bool = false  // Tracks if the user is currently in the sign-in view
}

// MARK: - AppDelegate Class

/// AppDelegate class responsible for configuring Firebase when the app launches and handling app termination events.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Called when the app finishes launching. Initializes Firebase.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()  // Initializes Firebase SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
    
    /// Called when the app is about to terminate. Logs out the user if they are in the sign-in view.
    func applicationWillTerminate(_ application: UIApplication) {
        logoutUserIfInSignInView()  // Logs out user if they are on the sign-in screen
    }

    /// Logs out the current user if they are in the sign-in view to ensure session integrity.
    private func logoutUserIfInSignInView() {
        if AppState.shared.isInSignInView {
            do {
                try Auth.auth().signOut()  // Firebase sign out method
                print("User logged out successfully.")  // Confirmation of logout
            } catch {
                print("Error signing out: \(error.localizedDescription)")  // Error handling in case sign out fails
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Forward the notification to Firebase
            if Auth.auth().canHandleNotification(userInfo) {
                completionHandler(.noData)
                return
            }
            
            // Handle your app's own notification handling logic here if needed
            completionHandler(.newData)
        }
     
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Main App Structure

@main
struct Imagine_TalesApp: App {
    
    /// Connects the `AppDelegate` to the SwiftUI lifecycle to handle Firebase initialization and other app-wide services.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// Tracks whether the user has completed onboarding, using `@AppStorage` for persistence.
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    /// Manages screen time-related functionalities for the app.
    @StateObject var screenTimeManager = ScreenTimeManager()
    
    /// Manages device orientation, injected as a global environment object.
    @StateObject private var orientationManager = OrientationManager()
    
    // MARK: - Body View
    
    /// Main scene for the app, deciding whether to show the onboarding flow or the root app experience.
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnBoardingView()  // Shows the onboarding view if the user hasn't completed onboarding
            } else {
                RootView()  // Main view of the app if onboarding is completed
                    .environmentObject(screenTimeManager)  // Passes screen time manager as an environment object
                    .environmentObject(AppState.shared)  // Passes app-wide state as an environment object
                    .environmentObject(orientationManager)  // Passes device orientation manager as an environment object
            }
        }
    }
}
