//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit


@MainActor
final class LocationManager {

    //creates a new instance of CLGeocoer
    private func newGeocoder() -> CLGeocoder {
        print("im in the new geocoder")//test
            return CLGeocoder()
        
        }
        //converts text adress into coordinates
        //return lat, lon, name
        func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
            print("im in the geocoder address")//test
            let geocoder = newGeocoder()// new geocoder instance
            print("ive made the new geocoder")
            do {
                let placemarks = try await geocoder.geocodeAddressString(address)
                print("im in the do ive tring the placemarks",placemarks)
                //guard let used to cornfirm coordinates exist ans at least one exists
                guard let placemark = placemarks.first,
                      let location = placemark.location else {
                    //esle stop right away 
                    print("the geocodeing has failed")
                    throw WeatherMapError.geocodingFailed("failed")
                }
                print("ive done the guard let")
                //set the name change pick the correct and most suitable one e.g paris, Paris
                let name = placemark.locality ?? placemark.name ?? address
                print("i have the name \(name)")//show name of location
                //return tuple containing name, lon, lat
                return (name, location.coordinate.latitude, location.coordinate.longitude)
                
                
            } catch {
                print("Geocoding failed:", error)
                throw WeatherMapError.geocodingFailed("failed")
            }
        }
    // Uses `CLGeocoder` to convert a string address into geographic coordinates.
    // Extracts the name, latitude, and longitude from the first resulting placemark.
    // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.
    
    // DUMMY RETURN TO SATISFY COMPILER
    
    
   
    //find pois for that location limit of 5
    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {

            //convert coordinates into a mapkit compatiable struct
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
            //define visitble region around city larger span wider area
            let region = MKCoordinateRegion(center: center,
                                            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
            //congig mapkit search requst
            let request = MKLocalSearch.Request()
            request.region = region
            
            //natural lang query tells what to search for
            request.naturalLanguageQuery = "Tourist Attractions"
            //do search asynconously
            let response = try await MKLocalSearch(request: request).start()

            //convert mapkit result to apps annotationmodel
        return response.mapItems.prefix(limit)//use limit
            .compactMap { item in
                //gives poi usable name
                guard let name = item.name else { return nil }
                //convert map kit item to annotation model so swift ui can use
                return AnnotationModel(
                    name: name,
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        
        // Executes the search request.
        // Maps the `MKMapItem` results into an array of `AnnotationModel`s, filtering out any without a name.
        // Limits the final array size to the specified `limit`.
        
        // DUMMY RETURN TO SATISFY COMPILER
        
    }
    
}
