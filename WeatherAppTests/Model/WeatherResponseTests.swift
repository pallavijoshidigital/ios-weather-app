//
//  WeatherResponseTests.swift
//  WeatherAppTests
//
//  Created by Pallavi Joshi on 9/30/24.
//

import XCTest
@testable import WeatherApp

final class WeatherResponseTests: XCTestCase {

    func testNewInstance() throws {
        let model = WeatherResposne(cityName: "City",
                                    main: WeatherResposne.Main(temp: 70.0, feelsLike: 72.1, tempMin: 65.3, tempMax: 80.9, humidity: 40),
                                    wind: WeatherResposne.Wind(speed: 12),
                                    weatherType: [WeatherResposne.WeatherType(id: 1, main: "Cloudy", description: "Mostly clouds", icon: "04n")],
                                    sys: WeatherResposne.Sys(country: "US"))
        
        XCTAssertNotNil(model)
        XCTAssertEqual(model.cityName, "City")
        let main = model.main
        XCTAssertEqual(main.temp, 70.0)
        XCTAssertEqual(main.feelsLike, 72.1)
        XCTAssertEqual(main.tempMin, 65.3)
        XCTAssertEqual(main.tempMax, 80.9)
        XCTAssertEqual(main.humidity, 40)
        XCTAssertNotNil(model.wind)
        XCTAssertEqual(model.wind.speed, 12)
        XCTAssertEqual(model.weatherType.count, 1)
        XCTAssertEqual(model.weatherType.first?.id, 1)
        XCTAssertEqual(model.sys?.country, "US")
    }
    
    func testNewInstanceWithOptional() throws {
        let model = WeatherResposne(cityName: "City",
                                    main: WeatherResposne.Main(temp: 70.0, feelsLike: 72.1, tempMin: 65.3, tempMax: 80.9, humidity: 40),
                                    wind: WeatherResposne.Wind(speed: 12),
                                    weatherType: [WeatherResposne.WeatherType(id: 1, main: "Cloudy", description: "Mostly clouds", icon: "04n")],
                                    sys: nil)
        
        XCTAssertNotNil(model)
        XCTAssertEqual(model.cityName, "City")
        let main = model.main
        XCTAssertEqual(main.temp, 70.0)
        XCTAssertEqual(main.feelsLike, 72.1)
        XCTAssertEqual(main.tempMin, 65.3)
        XCTAssertEqual(main.tempMax, 80.9)
        XCTAssertEqual(main.humidity, 40)
        XCTAssertNotNil(model.wind)
        XCTAssertEqual(model.wind.speed, 12)
        XCTAssertEqual(model.weatherType.count, 1)
        XCTAssertEqual(model.weatherType.first?.id, 1)
        XCTAssertNil(model.sys)
    }
    
    func testMapToWeather() throws {
        let model = WeatherResposne(cityName: "City",
                                    main: WeatherResposne.Main(temp: 70.1, feelsLike: 72.1, tempMin: 65.3, tempMax: 80.9, humidity: 40.0),
                                    wind: WeatherResposne.Wind(speed: 12.0),
                                    weatherType: [WeatherResposne.WeatherType(id: 1, main: "Cloudy", description: "Mostly clouds", icon: "04n")],
                                    sys: nil)
        
        XCTAssertNotNil(model)
        
        let weather = model.mapToWeather()
        XCTAssertNotNil(weather)
        XCTAssertEqual(weather.displayName, "City")
        XCTAssertEqual(weather.description, "Mostly Clouds")
        XCTAssertEqual(weather.temperature, "70.1°F")
        XCTAssertEqual(weather.feelsLikeTemperature, "72.1°F")
        XCTAssertEqual(weather.minTemperature, "65.3°F")
        XCTAssertEqual(weather.maxTemperature, "80.9°F")
        XCTAssertEqual(weather.iconUrl, URL(string: "https://openweathermap.org/img/wn/04n@2x.png"))
        XCTAssertEqual(weather.wind, "12.0")
        XCTAssertEqual(weather.humidity, "40.0")
    }

}
