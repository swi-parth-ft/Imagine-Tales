//
//  ScreenTimeManager.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/8/24.
//


import SwiftUI
import Firebase
import Combine

class ScreenTimeManager: ObservableObject {
   
    @Published var startTime: Date?
    @AppStorage("childId") var currentChildId: String = "Default Value"
    
    private var firestore = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen for app lifecycle notifications
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                self.stopScreenTime()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
               
                self.startScreenTime(for: self.currentChildId)
                
            }
            .store(in: &cancellables)
    }

    // Start the timer when a child logs in
    func startScreenTime(for childId: String) {
        self.currentChildId = childId
        self.startTime = Date()
    }
    
    // Stop the timer, save the screen time session to Firestore
    func stopScreenTime() {
       
        
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime ?? Date())
        
        saveScreenTime(startTime: startTime ?? Date(), endTime: endTime, duration: duration)
        
        // Reset the timer
        self.startTime = nil
    }
    
    // Save session data to Firestore
    private func saveScreenTime(startTime: Date, endTime: Date, duration: TimeInterval) {
        let sessionData: [String: Any] = [
            "startTime": startTime,
            "endTime": endTime,
            "duration": duration
        ]
        
        firestore.collection("screentime")
            .document(currentChildId)
            .collection("sessions")
            .addDocument(data: sessionData) { error in
                if let error = error {
                    print("Error saving screen time: \(error)")
                } else {
                    print("Screen time session successfully saved!")
                }
            }
    }
}
