//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import Foundation
import OSLog

protocol WeatherService {
    func fetchWeather(_ name: String) async throws -> WeatherResposne
    func fetchWeather(_ lat: Double, _ lon: Double) async throws -> WeatherResposne
    func fetchLocationSuggestions(_ location: String) async throws -> [LocationSuggestion]
}

final class WeatherServiceImpl: WeatherService {
    static let shared = WeatherServiceImpl()
    
    private let host = "https://api.openweathermap.org"
    private let apiKey = "<openWeatherAPIKey>" // Use API Key obtained from open weather portal
    // Hard-coding for now. Would be nice to give an option (setting) to the user to switch between imperial and metric units.
    private let unit = "imperial"
    
    private init() { }
    
    /// Fetch weather by `name`.
    func fetchWeather(_ name: String) async throws -> WeatherResposne {
        let urlString = "\(host)/data/2.5/weather?q=\(name)&units=\(unit)&appid=\(apiKey)"
        return try await get(urlString: urlString)
    }
    
    /// Fetch weather by `lat` and `lon`.
    func fetchWeather(_ lat: Double, _ lon: Double) async throws -> WeatherResposne {
        let urlString = "\(host)/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=\(unit)&appid=\(apiKey)"
        return try await get(urlString: urlString)
    }
    
    /// Fetch location suggestions for the given `location`.
    func fetchLocationSuggestions(_ location: String) async throws -> [LocationSuggestion] {
        let urlString = "\(host)/geo/1.0/direct?q=\(location)&limit=5&appid=\(apiKey)"
        return try await get(urlString: urlString)
    }
    
    private func get<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        Logger.shared.info("Request: \(urlString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            Logger.shared.debug("Response: \(responseString)")
        }
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw NetworkError.general
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
