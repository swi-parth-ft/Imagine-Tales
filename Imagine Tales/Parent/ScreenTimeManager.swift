//
//  ScreenTimeManager.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/8/24.
//

import SwiftUI
import Firebase
import Combine

// Class to manage screen time tracking for a child
class ScreenTimeManager: ObservableObject {
   
    // Published property to track the start time of screen time sessions
    @Published var startTime: Date?
    
    // App storage property to keep track of the current child's ID
    @AppStorage("childId") var currentChildId: String = "Default Value"
    
    private var firestore = Firestore.firestore() // Firestore instance for database operations
    private var cancellables = Set<AnyCancellable>() // Set to hold cancellable subscriptions
    
    init() {
        // Listen for app lifecycle notifications
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                self.stopScreenTime() // Stop tracking when app goes to the background
            }
            .store(in: &cancellables) // Store the cancellable to prevent memory leaks
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                self.startScreenTime(for: self.currentChildId) // Restart tracking when app enters foreground
            }
            .store(in: &cancellables) // Store the cancellable to prevent memory leaks
    }

    // Start the timer when a child logs in
    func startScreenTime(for childId: String) {
        self.currentChildId = childId // Set the current child's ID
        self.startTime = Date() // Record the start time
    }
    
    // Stop the timer and save the screen time session to Firestore
    func stopScreenTime() {
        let endTime = Date() // Get the end time
        let duration = endTime.timeIntervalSince(startTime ?? Date()) // Calculate duration
        
        // Save session data to Firestore
        saveScreenTime(startTime: startTime ?? Date(), endTime: endTime, duration: duration)
        
        // Reset the timer for the next session
        self.startTime = nil
    }
    
    // Save session data to Firestore
    private func saveScreenTime(startTime: Date, endTime: Date, duration: TimeInterval) {
        // Create a dictionary to hold session data
        let sessionData: [String: Any] = [
            "startTime": startTime,
            "endTime": endTime,
            "duration": duration
        ]
        
        // Add the session data to the Firestore database
        firestore.collection("screentime")
            .document(currentChildId)
            .collection("sessions")
            .addDocument(data: sessionData) { error in
                if let error = error {
                    print("Error saving screen time: \(error)") // Log error if saving fails
                } else {
                    print("Screen time session successfully saved!") // Log success message
                }
            }
    }
    
    // Fetch screen time data for a specific month and year
    func getScreenTimeForMonth(childId: String, year: Int, month: Int, completion: @escaping ([Date: TimeInterval]) -> Void) {
        let db = Firestore.firestore() // Get a Firestore instance
        
        let calendar = Calendar.current // Get the current calendar
        var components = DateComponents()
        
        // Set the start date for the requested month
        components.year = year
        components.month = month
        components.day = 1
        let startDate = calendar.date(from: components)!
        
        // Set the end date for the requested month
        components.month = month + 1
        components.day = 0
        let endDate = calendar.date(from: components)!
        
        // Query Firestore for screen time sessions in the specified date range
        db.collection("screentime")
            .document(childId)
            .collection("sessions")
            .whereField("startTime", isGreaterThanOrEqualTo: startDate)
            .whereField("startTime", isLessThanOrEqualTo: endDate)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting screen time: \(error)") // Log error if fetching fails
                    completion([:]) // Return an empty dictionary on error
                    return
                }
                
                var dailyScreenTime: [Date: TimeInterval] = [:] // Dictionary to hold daily screen time data
                
                // Process the documents and group them by day
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let startTime = (data["startTime"] as? Timestamp)?.dateValue(),
                       let duration = data["duration"] as? TimeInterval {
                        let day = calendar.startOfDay(for: startTime) // Get the start of the day for the session
                        dailyScreenTime[day, default: 0] += duration // Add duration to the corresponding day
                        print(dailyScreenTime) // Debugging: print daily screen time
                    }
                }
                completion(dailyScreenTime) // Return the aggregated screen time data
            }
    }
}
