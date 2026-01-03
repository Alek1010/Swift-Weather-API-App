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
    //testing purposes to see how many times the api is called
    var counting = 0
    // takes long and lat returns a weather response object
    //func is asyncronous performs network request
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        counting += 1
        print("Calling fetchWeather \(counting)")
        
        // build the URL if it failed exit
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall") else            {
            throw WeatherMapError.invalidURL("failed to build component")
        }
        //query parmeters to URL
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric") // Celsius
        ]
        // make sure final URL was succesfully created
        guard let url = components.url else {
            throw WeatherMapError.invalidURL("Failed to create final URL.")
        }
        
        // 2. Perform network request
        let data: Data
        let response:  URLResponse
        do {
            // try await pauses execution here till the network call is complete
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            //network level failure
            throw WeatherMapError.networkError(error)
        }
        
        // 3. Validate response
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw WeatherMapError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        // 4. Decode raw json into raw swift structs
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            //succesfully decoded data is returned to caller
            return weatherResponse
        } catch {
            //json structure did not match the expected model
            throw WeatherMapError.decodingError(error)
        }
        
        
    }
    
}
