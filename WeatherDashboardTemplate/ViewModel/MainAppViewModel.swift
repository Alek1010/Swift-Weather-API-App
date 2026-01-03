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
    @Published var mapRegion = MKCoordinateRegion()// visible area of map centre +zoom
    @Published var visited: [Place] = []// saved locations
    @Published var isLoading = false // controls loading spinner
    @Published var appError: WeatherMapError? // holds errors that give alert
    @Published var activePlaceName: String = "" // current active location
    private let defaultPlaceName = "London" // first launch
    @Published var selectedTab: Int = 0 // tab selection
    
    
    // handle network calls to openweather API
    private let weatherService = WeatherService()
    
    // handle geocoding anf POI lookup
    private let locationManager = LocationManager()
    
    // Used for fetching, saving and deleting place objects
    private let context: ModelContext
    
    //initisaliser runs onces app starts
    init(context: ModelContext) {
        self.context = context
        //fetch saced places
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }
        // start inital loading asynchronously
        Task { await loadInitial() }
    }
    
    // inital app load load default place
    private func loadInitial() async {
        print("im doing intial load  ")
        if let saved = visited.first {
            await loadLocation(fromPlace: saved)
        } else {
            try? await loadLocation(fromName: defaultPlaceName)
        }
    }
    
    // search handling when user uses search bar triggers async location loading
    func submitQuery() {
        // remove accidental spaces
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        // guard used if input is invalid
        guard !city.isEmpty else {
            appError = .missingData(message: "Enter a valid location")
            return
        }
        //run async loading
        Task {
            try? await loadLocation(fromName: city)
            query = ""
        }
    }
    
    
    
    // load the default location london
    func loadDefaultLocation() async {
        print("loading london")
        try? await loadLocation(fromName : defaultPlaceName)
        
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
    }
    
    
    
    //Main search loader loades location by name
    func loadLocation(fromName name: String) async throws {
        isLoading = true
        print("im in the loader function ")
        //check if location is already in saved places
        if let existing = visited.first(where: {
            $0.name.lowercased() == name.lowercased()
        }) {
            print("found cached place \(name), refreshing weather")
            //reused stored coordinates
            await loadLocation(fromPlace: existing)
            isLoading = false
            return
        }
        
        //convert city name to coordinates
        let result = try await locationManager.geocodeAddress(name)
        
        // fetch westher from api
        let response = try await weatherService.fetchWeather(lat: result.lat, lon: result.lon)
        self.currentWeather = response.current
        self.forecast = response.daily
        
        // fetch near by tourist attractions
        let poiList = try await locationManager.findPOIs(lat: result.lat, lon: result.lon)
        self.pois = poiList
        
        // save new place for later use
        let place = Place(name: result.name, latitude: result.lat, longitude: result.lon)
        visited.insert(place, at: 0)
        
        //update ui
        activePlaceName = result.name
        focus(on: .init(latitude: result.lat, longitude: result.lon))
        
        isLoading = false
        
        
        
    }
    // load from saved places loaded weather and poi using the saved place if exists
    func loadLocation(fromPlace place: Place) async {
        isLoading = true
        // update ui with selected place name
        activePlaceName = place.name
        
        //load everyhting using know lat and long
        do { try await loadAll(for: place) }
        catch { appError = .networkError(error) }
        
        isLoading = false
    }
    
    
    
    // deals with serious errors like invalid city, network error
    private func revertToDefaultWithAlert(message: String) async {
        appError = .missingData(message: message)
        await loadDefaultLocation()
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
    }
    
    //update to visible region of the map used when poi tapped and zoom in and out
    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // create new map region centred on the cooridnats
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
        )
        
    }
    
    //loads data for place using stored cooridnates
    private func loadAll(for place: Place) async throws {
        // call weather api using saved cooridinates
        let response = try await weatherService.fetchWeather(
            lat: place.latitude,
            lon: place.longitude
        )
        //update ui for current wether and forcat
        self.currentWeather = response.current
        self.forecast = response.daily
        
        
        // Always reload POIs for the selected place
        self.pois = try await locationManager.findPOIs(
            lat: place.latitude,
            lon: place.longitude
        )
        //put selected place at top of visted list
        visited.removeAll { $0.id == place.id }
        visited.insert(place, at: 0)
        // update map to centre on the place
        focus(on: CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        ))
    }
    
    
    
    //delete place from saved places when user swipes
    func delete(place: Place) {
        context.delete(place)
        visited.removeAll { $0.id == place.id }
        //attemp to save changes to data base
        try? context.save()
        // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
        // Attempts to save the context.
    }
    
    
    
}




