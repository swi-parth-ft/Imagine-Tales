//
//  Imagine_TalesApp.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/6/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isInSignInView: Bool = false
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Handle app termination
        logoutUserIfInSignInView()
    }

    private func logoutUserIfInSignInView() {
            if AppState.shared.isInSignInView {
                do {
                    try Auth.auth().signOut()
                    print("User logged out successfully.")
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }
        }
    
    
}

@main
struct Imagine_TalesApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @StateObject var screenTimeManager = ScreenTimeManager()
    
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnBoardingView()
            } else {
                RootView()
                    .environmentObject(screenTimeManager)
                    .environmentObject(AppState.shared)
            }
        }
    }
}


