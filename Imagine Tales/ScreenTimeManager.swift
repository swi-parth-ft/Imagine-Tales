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
    
    func getScreenTimeForMonth(childId: String, year: Int, month: Int, completion: @escaping ([Date: TimeInterval]) -> Void) {
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let startDate = calendar.date(from: components)!
        
        components.month = month + 1
        components.day = 0
        let endDate = calendar.date(from: components)!
        
        db.collection("screentime")
            .document(childId)
            .collection("sessions")
            .whereField("startTime", isGreaterThanOrEqualTo: startDate)
            .whereField("startTime", isLessThanOrEqualTo: endDate)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting screen time: \(error)")
                    completion([:])
                    return
                }
                
                var dailyScreenTime: [Date: TimeInterval] = [:]
                
                // Process the documents and group them by day
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let startTime = (data["startTime"] as? Timestamp)?.dateValue(),
                       let duration = data["duration"] as? TimeInterval {
                        let day = calendar.startOfDay(for: startTime)
                        dailyScreenTime[day, default: 0] += duration
                        print(dailyScreenTime)
                    }
                }
                completion(dailyScreenTime)
            }
    }
}
