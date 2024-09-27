//
//  Imagine_TalesApp.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/6/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
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
            }
        }
    }
}
