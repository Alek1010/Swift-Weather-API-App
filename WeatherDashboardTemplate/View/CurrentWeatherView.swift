//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    // Shared app state containing weather data and selected place
    @EnvironmentObject var vm: MainAppViewModel
    
    
    //Advice logic
    // Determines contextual advice based on the current weather.
    // Falls back to `.unknown` if weather data has not loaded yet.
    var adviceCategory: WeatherAdviceCategory {
        guard let cw = vm.currentWeather else { return .unknown }
        return WeatherAdviceCategory.from(
            temp: cw.temp,
            description: cw.weather.first?.description ?? ""
        )
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
        
            // Displays the active place name (e.g. London, Paris)
            Text(vm.activePlaceName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            
            
            // Loading state shown while weather data is being fetched
            if vm.isLoading {
                ProgressView("Loading Weather...")
            }
            // Shown once weather data is available
            else if let weather = vm.currentWeather {
                
                VStack(spacing: 16) {
                    
                    // Weather icon mapped from API condition
                    Image(systemName: WeatherIconMapper.iconName(for: weather.weather.first?.main ?? ""))
                        .font(.system(size: 80))
                    // current temp
                    Text("\(Int(weather.temp))°C")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                    // wether desctiption
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    //weather metrics displays additional weather details
                    HStack(spacing: 40) {
                        VStack {
                            Image(systemName: "thermometer")
                            Text("Feels Like")
                            Text("\(Int(weather.feelsLike))°C")
                        }
                        VStack {
                            Image(systemName: "drop.fill")
                            Text("Humidity")
                            Text("\(weather.humidity)%")
                        }
                        VStack {
                            Image(systemName: "wind")
                            Text("Wind")
                            Text("\(weather.windSpeed, specifier: "%.1f") m/s")
                        }
                    }
                    .font(.subheadline)
                    
                    
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(20)
                
                
                //weather advice secton gives advice based on temp and condtion
                HStack(spacing: 12) {
                    Image(systemName: adviceCategory.icon)
                        .font(.system(size: 30))
                        .foregroundColor(adviceCategory.color)
                    
                    Text(adviceCategory.adviceText)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(adviceCategory.color.opacity(0.15))
                .cornerRadius(16)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                
            }
            
            Spacer()
        }
        .padding()
        
        
    }
    
}


#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}
