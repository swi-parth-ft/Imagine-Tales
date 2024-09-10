//
//  ScreenTimeChartView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/8/24.
//


import SwiftUI
import Charts

struct ScreenTimeChartView: View {
    @State private var selectedMonth = Date()
    var selectedChildId: String
    @State private var screenTimeData: [Date: TimeInterval] = [:]
    @EnvironmentObject var screenTimeViewModel: ScreenTimeManager
    var body: some View {
        VStack {
      
            
            // Month Picker
            DatePicker("Select Month", selection: $selectedMonth, displayedComponents: [.date])
                .onChange(of: selectedMonth) { newValue in
                    fetchScreenTime()
                }
                .padding()
            
            // Chart
//            Chart {
//                ForEach(screenTimeData.sorted(by: { $0.key < $1.key }), id: \.key) { day, screenTime in
//                    BarMark(
//                        x: .value("Day", day, unit: .day),
//                        y: .value("Screen Time", screenTime / 3600) // Convert seconds to hours
//                    )
//                }
//            }
//            .frame(height: 300)
            
            Chart {
                ForEach(screenTimeData.sorted(by: { $0.key < $1.key }), id: \.key) { day, screenTime in
                    AreaMark(
                        x: .value("Day", day, unit: .day),
                        y: .value("Screen Time", screenTime / 3600) // Convert seconds to hours
                    )
                    .interpolationMethod(.catmullRom) // Smooth curves
                    .foregroundStyle(
                        .linearGradient(
                            Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.3)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 300)
            .background(Color(.systemBackground))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) // Customize X axis
            }
            .chartYAxis {
                AxisMarks() // Customize Y axis if needed
            }
            .padding()
            
            
        }
        .onAppear {
            fetchScreenTime()
        }
    }
    
    // Fetch data based on selected child and month
    func fetchScreenTime() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        
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
