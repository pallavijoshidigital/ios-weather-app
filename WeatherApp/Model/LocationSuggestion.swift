//
//  LocationSuggestion.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import Foundation

struct LocationSuggestion: Codable, Hashable {
    var name: String
    var lat: Double
    let lon: Double
    let state: String?
    let country: String?
}

extension LocationSuggestion {
    /// Concatenate `name`, `state`, `country` for display purpose
    var displayName: String {
        get {
            var displayName = name
            if let state = state {
                displayName.append(", ")
                displayName.append(state)
            }
            if let country = country {
                displayName.append(", ")
                displayName.append(country)
            }
            return displayName
        }
        set { }
    }
}

extension LocationSuggestion: Identifiable {
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    /// Use `lat-lon` as the identifier because the `/geo/1.0/direct` API can return
    /// location suggestions that have the same city, state and country but different latitude and longitude.
    var id: String {
        guard let latStr = LocationSuggestion.formatter.string(for: lat),
              let longStr = LocationSuggestion.formatter.string(for: lon) else { return "" }
        return "\(latStr)-\(longStr)"
    }
}
