//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
@MainActor
final class WeatherService {
    private let apiKey = "fa86034853815776dce00554e4b30aa2"
    //private let dailyLimit = 50 // Set your daily API call limit
    var counting = 0
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        counting += 1
        print("Calling fetchWeather \(counting)")
        
        
        //Check daily API limit
        //try checkDailyLimit()
        
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall") else            {
            throw WeatherMapError.invalidURL("failed to build component")
        }
        
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric") // Optional: for Celsius
        ]
        
        guard let url = components.url else {
            throw WeatherMapError.invalidURL("Failed to create final URL.")
        }
        
        // 2. Perform network request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw WeatherMapError.networkError(error)
        }
        
        // 3. Validate response
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw WeatherMapError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        // 4. Decode JSON into WeatherResponse
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            //incrementAPICount()
            
            return weatherResponse
        } catch {
            throw WeatherMapError.decodingError(error)
        }
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        // Performs an asynchronous network request using URLSession.
        // Validates the HTTP response status code.
        // Decodes the received JSON data into a `WeatherResponse` object, using a specific date decoding strategy.
        // Handles and throws specific `WeatherMapError` types for invalid URL, network failure, invalid response, and decoding errors.
        
        // DUMMY RETURN TO SATISFY COMPILER - you will have your own when the coding is done
        
    }
    
//    private func checkDailyLimit() throws {
//        print("im checking the daily limit")
//        let today = Calendar.current.startOfDay(for: Date())
//        let lastReset = UserDefaults.standard.object(forKey: "api_call_reset") as? Date ?? .distantPast
//        
//        if today > lastReset {
//            print("today is higher than last rest")
//            print(dailyLimit)
//            // New day → reset counter
//            UserDefaults.standard.set(0, forKey: "api_call_count")
//            UserDefaults.standard.set(today, forKey: "api_call_reset")
//        }
//        
//        let current = getAPICallCount()
//        if current >= dailyLimit {
//            throw WeatherMapError.limitExceeded("Daily API limit reached (\(dailyLimit) calls)")
//        }
//        print(current,dailyLimit)
//    }
//    
//    private func incrementAPICount() {
//        let current = getAPICallCount()
//        UserDefaults.standard.set(current + 1, forKey: "api_call_count")
//    }
//    
//    private func getAPICallCount() -> Int {
//        return UserDefaults.standard.integer(forKey: "api_call_count")
//    }
    
}
