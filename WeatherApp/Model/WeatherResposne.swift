//
//  WeatherResposne.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.

import Foundation

struct WeatherResposne: Codable {
    
    let cityName: String
    let main: Main
    let wind: Wind
    let weatherType: [WeatherType]
    let sys: Sys?
    
    private enum CodingKeys: String, CodingKey {
        case cityName = "name"
        case main
        case wind
        case weatherType = "weather"
        case sys
    }
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Double
        
        private enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case humidity
        }
    }
    
    struct Wind: Codable {
        let speed: Double
    }
    
    struct WeatherType: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Sys: Codable {
        let country: String?
    }
}

extension WeatherResposne {
    
    /// Maps `WeatherResponse` to a UI model.
    func mapToWeather() -> Weather {
        var displayName = cityName
        if let country = sys?.country {
            displayName.append(", ")
            displayName.append(country)
        }
        
        var url: URL?
        if let icon = weatherType.first?.icon {
            // OpenWeatherMap only supports `2X` images.
            url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        }
        
        let weather = Weather(displayName: displayName,
                              description: weatherType.first?.description.capitalized ?? "",
                              temperature: Measurement.format(temperature: main.temp),
                              feelsLikeTemperature:  Measurement.format(temperature: main.feelsLike),
                              minTemperature: Measurement.format(temperature: main.tempMin),
                              maxTemperature: Measurement.format(temperature: main.tempMax),
                              iconUrl: url,
                              wind: String(wind.speed),
                              humidity: String(main.humidity))
        
        return weather
    }
    
}

extension Measurement {
    /// Formats the temperature as a degree Farenheit value
    /// Would be nice to give an option (setting) to the user to switch between imperial and metric units.
    static func format(temperature: Double) -> String {
        return Measurement<UnitTemperature>(value: temperature, unit: .fahrenheit).formatted()
    }
}



