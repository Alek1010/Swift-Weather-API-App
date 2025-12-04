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

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall") else {
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
}
