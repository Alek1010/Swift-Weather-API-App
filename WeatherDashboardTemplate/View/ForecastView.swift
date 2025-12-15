//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData


import SwiftUI
import Charts   // Include if you plan to show a chart later



// MARK: - Temperature Data Model
/// A single temperature reading for the chart or list.
private struct TempData: Identifiable {
    let id = UUID()
    let time: Date          // e.g., forecast date
    let type: String        // e.g., "High" or "Low"
    let value: Double       // numeric value
}

// MARK: - Forecast View
/// Stubbed Forecast View that includes an image placeholder to show
/// what the final view will look like. Replace the image once real data and charts are added.
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("8 Day Forecast – \(vm.activePlaceName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Daily Highs and Lows (°C)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // MARK: - Bar Chart
                Chart {
                    ForEach(vm.forecast) { day in
                        let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
                        
                        BarMark(
                            x: .value("Day", date, unit: .day),
                            y: .value("Temperature", day.temp.max)
                        )
                        .foregroundStyle(.orange)
                        .position(by: .value("Type", "High"))
                        
                        BarMark(
                            x: .value("Day", date, unit: .day),
                            y: .value("Temperature", day.temp.min)
                        )
                        .foregroundStyle(.blue)
                        .position(by: .value("Type", "Low"))
                    }
                }
                .frame(height: 260)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxisLabel("°C")
                .padding(.horizontal)
                
                
                // MARK: - Detailed Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detailed Daily Summary")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(vm.forecast ) { day in
                        dailyRow(day)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Forecast")
        
        //        VStack {
        //            // MARK: - Header Text
        //            Text("Image shows the information to be presented in this view")
        //                .font(.headline)
        //                .multilineTextAlignment(.center)
        //                .padding(.top)
        //
        //            Spacer()
        //
        //            // MARK: - Placeholder Image
        //            // Replace "forecast" with the name of your image asset.
        //            // You can add your actual design or a wireframe image in Assets.xcassets.
        //            Image("forecast")
        //                .resizable()
        //                .scaledToFit()
        //                .frame(maxWidth: .infinity)
        //                .cornerRadius(12)
        //                .shadow(radius: 5)
        //                .padding()
        //
        //            Spacer()
        //        }
        //        .frame(height: 600)
        //        .background(
        //            LinearGradient(
        //                gradient: Gradient(colors: [.indigo.opacity(0.1), .blue.opacity(0.05)]),
        //                startPoint: .topLeading,
        //                endPoint: .bottomTrailing
        //            )
        //        )
        //        .clipShape(RoundedRectangle(cornerRadius: 20))
        //        .padding()
        //        .navigationTitle("Forecast")
    }
    
    // MARK: - Daily Row
    private func dailyRow(_ day: Daily) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(
                DateFormatterUtils.formattedDateWithWeekdayAndDay(
                    from: TimeInterval(day.dt)
                )
            )
            .font(.headline)
            
            Text(day.weather.first?.description.capitalized ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Low: \(Int(day.temp.min))°C   High: \(Int(day.temp.max))°C")
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
}
    


#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
