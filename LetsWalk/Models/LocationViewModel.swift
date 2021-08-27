//
//  Location.swift
//  LetsWalk
//
//  Created by Sabri Sönmez on 8/27/21.
//

import Foundation
import CoreLocation
import HealthKit

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?

    private let locationManager: CLLocationManager
    private let routeBuilder = HKWorkoutRouteBuilder(healthStore: HKHealthStore(), device: nil)

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)
        
        
           // Filter the raw data.
           let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
               location.horizontalAccuracy <= 50.0
           }
           
           guard !filteredLocations.isEmpty else { return }
           
           // Add the filtered data to the route.
           routeBuilder.insertRouteData(filteredLocations) { (success, error) in
               if !success {
                   // Handle any errors here.
               }
           }
    }

    func end() {
        
        // Create, save, and associate the route with the provided workout.
        let end = Date()
        let start = end.addingTimeInterval(-3600)
        routeBuilder.finishRoute(with: HKWorkout(activityType: .walking, start: start, end: end), metadata: nil) { (newRoute, error) in
            
            guard newRoute != nil else {
                // Handle any errors here.
                return
            }
            
            // Optional: Do something with the route here.
        }
    }
    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
    }
}
