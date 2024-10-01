//
//  LocationSuggestionTests.swift
//  WeatherAppTests
//
//  Created by Pallavi Joshi on 9/30/24.
//

import XCTest
@testable import WeatherApp

final class LocationSuggestionTests: XCTestCase {
    
    func testNewInstance() throws {
        let model = LocationSuggestion(name: "City", lat: 10.22, lon: 12.33, state: "State", country: "Country")
        
        XCTAssertNotNil(model)
        XCTAssertEqual(model.name, "City")
        XCTAssertEqual(model.lat, 10.22)
        XCTAssertEqual(model.lon, 12.33)
        XCTAssertEqual(model.state, "State")
        XCTAssertEqual(model.country, "Country")
        XCTAssertEqual(model.displayName, "City, State, Country")
        XCTAssertEqual(model.id, "10.22-12.33")
    }
    
    func testNewInstanceWithOptional() throws {
        let model = LocationSuggestion(name: "City", lat: 10.22, lon: 12.33, state: nil, country: nil)
        
        XCTAssertNotNil(model)
        XCTAssertEqual(model.name, "City")
        XCTAssertEqual(model.lat, 10.22)
        XCTAssertEqual(model.lon, 12.33)
        XCTAssertNil(model.state)
        XCTAssertNil(model.country)
        XCTAssertEqual(model.displayName, "City")
        XCTAssertEqual(model.id, "10.22-12.33")
    }
    
}
