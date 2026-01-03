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
import Charts


struct ForecastView: View {
    //shared app state
    @EnvironmentObject var vm: MainAppViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                //header shows rhe forcast title and active location
                VStack(alignment: .leading, spacing: 4) {
                    Text("8 Day Forecast – \(vm.activePlaceName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Daily Highs and Lows (°C)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // temp bar chart Display bars for daily high and low temperatures
                Chart {
                    ForEach(vm.forecast) { day in
                        let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
                        // high temp bar
                        BarMark(
                            x: .value("Day", date, unit: .day),
                            y: .value("Temperature", day.temp.max)
                        )
                        .foregroundStyle(.orange)
                        .position(by: .value("Type", "High"))
                        // low temp bar
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
                
                
                // detailed summery text forcast detail for every day
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
        
    }
    
    // daily forcast forcast detail for a single day
    private func dailyRow(_ day: Daily) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(
                //date formated with weekday
                DateFormatterUtils.formattedDateWithWeekdayAndDay(
                    from: TimeInterval(day.dt)
                )
            )
            .font(.headline)
            //weather descibed e.g light rain
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
