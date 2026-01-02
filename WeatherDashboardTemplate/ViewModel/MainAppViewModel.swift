//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit


//all changes happen n the main UI
@MainActor
final class MainAppViewModel: ObservableObject {
    @Published var query = ""//user input from search bar via vm.query
    @Published var currentWeather: Current? // weaher data
    @Published var forecast: [Daily] = [] // 8 day forcast
    @Published var pois: [AnnotationModel] = [] // shows poi on the map
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    private let defaultPlaceName = "London"
    @Published var selectedTab: Int = 0
    /// Simple weather cache timestamp
    private var lastWeatherFetch: Date?

    /// Create and use a WeatherService model (class) to manage fetching and decoding weather data
    private let weatherService = WeatherService()

    /// Create and use a LocationManager model (class) to manage address conversion and tourist places
    private let locationManager = LocationManager()

    /// Use a context to manage database operations
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }
        
        Task { await loadInitial() }
    }
    
    // MARK: - Startup Loader
    private func loadInitial() async {
        print("im doing intial load  ")
        if let saved = visited.first {
            await loadLocation(fromPlace: saved)
        } else {
            try? await loadLocation(fromName: defaultPlaceName)
        }
    }

    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            appError = .missingData(message: "Enter a valid location")
            return
        }
        
        Task {
            try? await loadLocation(fromName: city)
            query = ""
        }
    }
    
    
    
    
    func loadDefaultLocation() async {
        print("loading london")
        try? await loadLocation(fromName : defaultPlaceName)
        
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
    }


    
    // MARK: - Main Loader (Search)
    func loadLocation(fromName name: String) async throws {
        isLoading = true
        print("im in the loader function ")
        // If visited before → just load cached values (NO API)
        if let existing = visited.first(where: {
            $0.name.lowercased() == name.lowercased()
        }) {
            print("found cached place \(name), refreshing weather")
            await loadLocation(fromPlace: existing)
            isLoading = false
            return
        }
        
        // 1. Geocode once
        let result = try await locationManager.geocodeAddress(name)
        
        // 2. Weather API call once
        let response = try await weatherService.fetchWeather(lat: result.lat, lon: result.lon)
        self.currentWeather = response.current
        self.forecast = response.daily
        
        // 3. POIs once
        let poiList = try await locationManager.findPOIs(lat: result.lat, lon: result.lon)
        self.pois = poiList
        
        // 4. Save place (cached forever)
        let place = Place(name: result.name, latitude: result.lat, longitude: result.lon)
        visited.insert(place, at: 0)
        
        activePlaceName = result.name
        focus(on: .init(latitude: result.lat, longitude: result.lon))
        
        isLoading = false
        
        // Sets loading state, then attempts to load data for the given place name.
        //        // 1. Checks if the place is already in `visited` and, if so, loads all data for the existing `Place` object, updates its `lastUsedAt`, and saves the context.
        //        // 2. Otherwise, geocodes the fresh place name using `locationManager`.
        //        // 3. Fetches weather data using `weatherService` as a fail-fast check.
        //        // 4. Finds Points of Interest (POIs) using `locationManager`, converts them to `AnnotationModel`s, and associates them with the new `Place`.
        //        // 5. Inserts the new `Place` into the `visited` array and saves the context.
        //        // 6. Updates UI by setting `pois`, `activePlaceName`, and focusing the map.
        //        // 7. If any step fails, logs the error and reverts to the default location with an alert.
        
    }
    
    func loadLocation(fromPlace place: Place) async {
            isLoading = true
            activePlaceName = place.name

            do { try await loadAll(for: place) }
            catch { appError = .networkError(error) }

            isLoading = false
        }




    private func revertToDefaultWithAlert(message: String) async {
        appError = .missingData(message: message)
        await loadDefaultLocation()
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
    }

    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            )
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
    }


    private func loadAll(for place: Place) async throws {
        let response = try await weatherService.fetchWeather(
            lat: place.latitude,
            lon: place.longitude
        )

        self.currentWeather = response.current
        self.forecast = response.daily
        lastWeatherFetch = Date()

        // POIs
        if pois.isEmpty {
            self.pois = try await locationManager.findPOIs(
                lat: place.latitude,
                lon: place.longitude
            )
        }

        visited.removeAll { $0.id == place.id }
        visited.insert(place, at: 0)

        focus(on: CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        ))
    }
    
    // Sets `activePlaceName` and prints a loading message.
        // Always refreshes weather data from the API.
        // Checks if the `Place` object has existing annotations (POIs).
        // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
        // If annotations exist, uses the cached list for `self.pois`.
        // Calls `focus(on:zoom:)` to update the map view.
        // Ensures the place is at the top of the `visited` list (if not already).
    
    func delete(place: Place) {
        context.delete(place)
        visited.removeAll { $0.id == place.id }
        try? context.save()
        // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
        // Attempts to save the context.
    }
    
   
    
    }

    


