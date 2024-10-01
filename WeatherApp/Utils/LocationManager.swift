//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import CoreLocation
import OSLog

/// User location manager
final class LocationManager: NSObject, CLLocationManagerDelegate {
    @Published var lastKnownLocation: CLLocation?
    
    private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = CLLocationDistanceMax
        manager.delegate = self
        return manager
    }()
    
    func isAuthorized() -> Bool {
        let authorizationStatus = manager.authorizationStatus
        return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
    
    func startUpdatingLocation() {
        let authorizationStatus = manager.authorizationStatus
        Logger.shared.info("Location Status: \(authorizationStatus.rawValue)")
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locaiton = locations.first else { return }
        Logger.shared.info("Found location. Latitude: \(locaiton.coordinate.latitude) Longitude: \(locaiton.coordinate.longitude)")
        lastKnownLocation = locaiton
        stopUpdatingLocation()
    }
}
