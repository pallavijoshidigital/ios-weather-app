//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import Combine
import Foundation
import CoreLocation

/// UI Model
struct Weather {
    let displayName: String
    let description: String
    let temperature: String
    let feelsLikeTemperature: String
    let minTemperature: String
    let maxTemperature: String
    let iconUrl: URL?
    let wind: String
    let humidity: String
}

@MainActor
class HomeViewModel: ObservableObject {
    
    /// Enum denoting the current UI state
    enum ViewState {
        case idle
        case loading
        case success(weather: Weather)
        case error(messageKey: String)
    }
    
    private static let errorGenericKey = "ErrorGeneric"
    private static let lastSearchedWeather = "last_searched_weather"
    
    private var subscriptions = Set<AnyCancellable>()
    private let locationManager = LocationManager()
    private let weatherService: WeatherService
    
    @Published private(set) var viewState: ViewState = .idle
    @Published var searchText: String = ""
    @Published var locationSuggestions = [LocationSuggestion]()
    
    init(weatherService: WeatherService = WeatherServiceImpl.shared) {
        self.weatherService = weatherService
        
        // Listen for location updates
        locationManager.$lastKnownLocation
            .sink { location in
                guard let coordinate = location?.coordinate else { return }
                
                self.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }.store(in: &subscriptions)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        Task {
            self.viewState = .loading
            do {
                let weather = try await weatherService.fetchWeather(latitude, longitude)
                    .mapToWeather()
                UserDefaults.standard.setValue(weather.displayName, forKey: HomeViewModel.lastSearchedWeather)
                self.viewState = .success(weather: weather)
            } catch {
                self.viewState = .error(messageKey: HomeViewModel.errorGenericKey)
            }
        }
    }
    
    func fetchWeather(name: String) {
        Task {
            self.viewState = .loading
            do {
                let weather = try await weatherService.fetchWeather(name)
                    .mapToWeather()
                UserDefaults.standard.setValue(name, forKey: HomeViewModel.lastSearchedWeather)
                self.viewState = .success(weather: weather)
            } catch {
                self.viewState = .error(messageKey: HomeViewModel.errorGenericKey)
            }
        }
    }
    
    func fetchLocationSuggestions() {
        // Make sure the user has typed enough to search for locations
        guard searchText.count >= 3 else { return }
        Task {
            do {
                self.locationSuggestions = try await weatherService.fetchLocationSuggestions(searchText)
            } catch {
                self.locationSuggestions = []
            }
        }
    }
    
    func startUpdatingLocation() {
        if !locationManager.isAuthorized() {
            guard let lastLocation = UserDefaults.standard.value(forKey: HomeViewModel.lastSearchedWeather) as? String else {
                locationManager.startUpdatingLocation()
                return
            }
            fetchWeather(name: lastLocation)
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        if locationManager.isAuthorized() {
            locationManager.stopUpdatingLocation()
        }
    }
}
