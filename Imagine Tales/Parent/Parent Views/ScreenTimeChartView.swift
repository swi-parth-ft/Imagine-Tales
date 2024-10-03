//
//  ScreenTimeChartView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/8/24.
//

import SwiftUI
import Charts

// A view to display a chart of screen time for a selected child
struct ScreenTimeChartView: View {
    // State variable to track the selected month index (0 for January, 11 for December)
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    
    // State variable to track the selected month as a Date object
    @State private var selectedMonth = Date()
    
    // The ID of the selected child
    var selectedChildId: String
    
    // State variable to hold the screen time data for the selected month
    @State private var screenTimeData: [Date: TimeInterval] = [:]
    
    // Environment object to manage screen time data
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager
    
    // Array of month names
    let months = Calendar.current.monthSymbols
    
    // Current calendar instance
    let calendar = Calendar.current
    
    // State variable for the current date
    @State private var currentDate = Date()
    
    var body: some View {
        ZStack {
            VStack {
                // Display the month label if there's screen time data
                
                if !screenTimeData.isEmpty {
                    Text(monthLabel())
                        .font(.title2)
                        .padding(.bottom)
                }
                
                // Show a placeholder view if there's no screen time data
                if screenTimeData.isEmpty {
                    ContentUnavailableView {
                        Label("No Activity Yet", systemImage: "scribble.variable")
                    } description: {
                        Text("It looks like there's no screen time yet.")
                    } actions: {}
                    .listRowBackground(Color.clear)
                }
                
                // Create a chart to display screen time data
                Chart {
                    // Iterate through the screen time data sorted by date
                    ForEach(screenTimeData.sorted(by: { $0.key < $1.key }), id: \.key) { day, screenTime in
                        // Area mark for displaying the area under the curve
                        AreaMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Screen Time", screenTime / 3600) // Convert seconds to hours
                        )
                        .interpolationMethod(.catmullRom) // Use Catmull-Rom interpolation for smooth curves
                        .foregroundStyle(
                            .linearGradient(
                                Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.3), Color.green.opacity(0.1), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line mark for displaying the line on the chart
                        LineMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Screen Time", screenTime / 3600)
                        )
                        .interpolationMethod(.catmullRom) // Smooth the line
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        // Point mark for displaying data points
                        PointMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Screen Time", screenTime / 3600)
                        )
                        .foregroundStyle(.white)
                        .symbolSize(8)
                    }
                }
                .frame(height: 300) // Set the height of the chart
                .background(Color(.clear)) // Clear background for the chart
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) // Customize X axis to show days
                }
                .chartYAxis {
                    AxisMarks() // Optionally customize Y axis if needed
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            // Change month based on swipe direction
                            if value.translation.width < 0 {
                                // Swiped left, go to the next month
                                withAnimation {
                                    changeMonth(by: 1)
                                }
                            } else if value.translation.width > 0 {
                                // Swiped right, go to the previous month
                                withAnimation {
                                    changeMonth(by: -1)
                                }
                            }
                        }
                )
                
                // Display label for screen time if data exists
                if !screenTimeData.isEmpty {
                    Text("Screen Time")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }
            .onAppear {
                // Fetch screen time data when the view appears
                fetchScreenTime()
            }
        }
    }
    
    // Helper function to get the label for the current month and year
    func monthLabel() -> String {
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        return "\(months[month - 1]) \(year)" // Return formatted month and year
    }

    // Function to change the month when swiping
    func changeMonth(by value: Int) {
        // Calculate new date by adding the specified number of months
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            // Only update if the new date is not in the future
            if newDate <= Date() {
                withAnimation {
                    currentDate = newDate // Update current date
                    fetchScreenTime() // Fetch new screen time data for the updated month
                }
            }
        }
    }
    
    // Fetch data based on the selected child and month
    func fetchScreenTime() {
        // Get the year and month components from the current date
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        // Fetch screen time data for the specified child ID and month
        screenTimeViewModel.getScreenTimeForMonth(childId: selectedChildId, year: components.year!, month: components.month!) { dailyScreenTime in
            DispatchQueue.main.async {
                // Debugging: log the fetched screen time data
                print("Fetched screen time data: \(dailyScreenTime)")
                
                // Update the screenTimeData with the fetched data
                self.screenTimeData = dailyScreenTime
                
                // Additional debug print to verify the data
                print("Updated screenTimeData: \(self.screenTimeData)")
            }
        }
    }
}

#Preview {
    // Mock preview data for testing
    let mockScreenTimeManager = ScreenTimeManager()
    ScreenTimeChartView(selectedChildId: "wZpOdPBPwhm8QCQ9jYYf")
        .environmentObject(mockScreenTimeManager) // Provide the mock environment object
}
