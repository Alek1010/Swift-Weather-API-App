//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    
    //Advice Category
    var adviceCategory: WeatherAdviceCategory {
        guard let cw = vm.currentWeather else { return .unknown }
        return WeatherAdviceCategory.from(
            temp: cw.temp,
            description: cw.weather.first?.description ?? ""
        )
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text(vm.activePlaceName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if vm.isLoading {
                ProgressView("Loading Weather...")
            }
            
            else if let weather = vm.currentWeather {
                
                VStack(spacing: 16) {
                    
                    // SF Symbol icon (you can refine later)
                    Image(systemName: WeatherIconMapper.iconName(for: weather.weather.first?.main ?? ""))
                        .font(.system(size: 80))
                    
                    Text("\(Int(weather.temp))°C")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
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
