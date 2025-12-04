//
//  WeatherIconMapper.swift
//  WeatherDashboardTemplate
//
//  Created by Aleksandar Mihaylov on 04/12/2025.
//

import Foundation

enum WeatherIconMapper {
    
    /// Convert OpenWeather condition strings into SF Symbols.
    static func iconName(for condition: String) -> String {
        let value = condition.lowercased()
        
        switch value {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "few clouds", "scattered clouds", "broken clouds":
            return "cloud.sun.fill"
        case "rain":
            return "cloud.rain.fill"
        case "light rain", "moderate rain":
            return "cloud.drizzle.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

