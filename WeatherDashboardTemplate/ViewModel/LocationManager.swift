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
    
    private let geocoder = CLGeocoder()

    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            
            guard let placemark = placemarks.first,
                  let location = placemark.location else {
                throw WeatherMapError.geocodingFailed("failed")
            }
            let name = placemark.locality ?? placemark.name ?? address
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            return( name , lat, lon)
            
        } catch {
            print("Geocoding failed:", error)
            throw WeatherMapError.geocodingFailed("failed")
        }
    }
        // Uses `CLGeocoder` to convert a string address into geographic coordinates.
        // Extracts the name, latitude, and longitude from the first resulting placemark.
        // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.

        // DUMMY RETURN TO SATISFY COMPILER
        
    }

    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        
        // Executes the search request.
        // Maps the `MKMapItem` results into an array of `AnnotationModel`s, filtering out any without a name.
        // Limits the final array size to the specified `limit`.

        // DUMMY RETURN TO SATISFY COMPILER
        preconditionFailure("Stubbed function not implemented. Requires a [AnnotationModel] return.")
    }

