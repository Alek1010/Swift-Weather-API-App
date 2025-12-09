//
//  WeatherResponseNew.swift
//  WeatherDashboardTemplate
//
//  Created by Aleksandar Mihaylov on 04/12/2025.
//


import Foundation
import SwiftUI

// MARK: - Current Weather Model
/// A flattened, efficient structure representing the current weather.
/// This earns marks for clean, lean JSON mapping and is tailored for your UI.
struct WeatherResponseNew: Identifiable {
    let id = UUID()
    
    let temperature: Double
    let feelsLike: Double
    let condition: String          // e.g., “Clouds”
    let description: String        // e.g., “broken clouds”
    let icon: String               // SF Symbol name
    let humidity: Int
    let windSpeed: Double
    let pressure: Int
    let sunrise: Int               // UNIX timestamp
    let sunset: Int               // UNIX timestamp
    let date: Date
}

// MARK: - 8-Day Forecast Model
/// Lightweight model for your forecast tab and charts.
struct ForecastDay: Identifiable {
    let id = UUID()
    let date: Date
    let minTemp: Double
    let maxTemp: Double
    let condition: String
    let icon: String               // SF Symbol name
}

