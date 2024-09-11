//
//  ScreenTimeChartView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/8/24.
//


import SwiftUI
import Charts

struct ScreenTimeChartView: View {
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedMonth = Date()
    var selectedChildId: String
    @State private var screenTimeData: [Date: TimeInterval] = [:]
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager
    let months = Calendar.current.monthSymbols
    let calendar = Calendar.current
    @State private var currentDate = Date()
    
    var body: some View {
        ZStack {
            VStack {

                Text(monthLabel())
                    .font(.title2)
                    .padding()

                Chart {
                    ForEach(screenTimeData.sorted(by: { $0.key < $1.key }), id: \.key) { day, screenTime in
                        AreaMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Screen Time", screenTime / 3600) // Convert seconds to hours
                        )
                        .interpolationMethod(.catmullRom) // Smooth curves
                        .foregroundStyle(
                            .linearGradient(
                                Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.3), Color.green.opacity(0.1),
                                                  Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        LineMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Screen Time", screenTime / 3600)
                        )
                        .interpolationMethod(.catmullRom) // Smooth the line
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        PointMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Screen Time", screenTime / 3600)
                        )
                        .foregroundStyle(.white)
                        .symbolSize(8)
                    }
                }
                .frame(height: 300)
                .background(Color(.clear))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) // Customize X axis
                }
                .chartYAxis {
                    AxisMarks() // Customize Y axis if needed
                }
                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            if value.translation.width < 0 {
                                                // Swiped left, go to next month
                                                changeMonth(by: 1)
                                            } else if value.translation.width > 0 {
                                                // Swiped right, go to previous month
                                                changeMonth(by: -1)
                                            }
                                        }
                                )
                .padding()
                
                Text("Screen Time")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
            }
            .onAppear {
                fetchScreenTime()
            }
        }
    }
    
    // Helper function to get the label for the current month and year
        func monthLabel() -> String {
            let month = calendar.component(.month, from: currentDate)
            let year = calendar.component(.year, from: currentDate)
            return "\(months[month - 1]) \(year)"
        }

        // Function to change the month when swiping
        func changeMonth(by value: Int) {
            if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
                if newDate <= Date() {
                    withAnimation {
                        currentDate = newDate
                        fetchScreenTime() // Update the chart for the new month
                    }
                }
            }
        }
    
    // Fetch data based on selected child and month
    func fetchScreenTime() {
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            
            screenTimeViewModel.getScreenTimeForMonth(childId: selectedChildId, year: components.year!, month: components.month!) { dailyScreenTime in
                DispatchQueue.main.async {
                    self.screenTimeData = dailyScreenTime
                }
            }
        }
}

#Preview {
    let mockScreenTimeManager = ScreenTimeManager()
    ScreenTimeChartView(selectedChildId: "3n5X2ipZdgBb0x8BAHOn")
        .environmentObject(mockScreenTimeManager)
}
