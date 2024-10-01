//
//  HomeViewModelTests.swift
//  WeatherAppTests
//
//  Created by Pallavi Joshi on 9/30/24.
//

import XCTest
import Combine
@testable import WeatherApp

@MainActor
final class HomeViewModelTest: XCTestCase {

    private var viewModel: HomeViewModel!
    private var weatherService: MockWeatherService!
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        weatherService = MockWeatherService()
        viewModel = HomeViewModel(weatherService: weatherService)
    }

    override func tearDownWithError() throws {
        weatherService = nil
        viewModel = nil
        try super.tearDownWithError()
    }

    func testFetchWeatherSuccess() throws {
        let idleExpectation = XCTestExpectation(description: "ViewState is .idle")
        let loadingExpectation = XCTestExpectation(description: "ViewState is .loading")
        let successExpectation = XCTestExpectation(description: "ViewState is .success")
        let failureExpectation = XCTestExpectation(description: "ViewState is .error")
        failureExpectation.isInverted = true
        
        viewModel.$viewState
            .sink { viewState in
                switch viewState {
                case .idle:
                    idleExpectation.fulfill()
                case .loading:
                    loadingExpectation.fulfill()
                case .success(let weather):
                    XCTAssertNotNil(weather)
                    XCTAssertEqual(weather.displayName, "CityName, US")
                    successExpectation.fulfill()
                case .error(_):
                    failureExpectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.fetchWeather(name: "City")
        
        wait(for: [idleExpectation, loadingExpectation, successExpectation, failureExpectation], timeout: 2)
    }
    
    func testFetchWeatherError() throws {
        let idleExpectation = XCTestExpectation(description: "ViewState is .idle")
        let loadingExpectation = XCTestExpectation(description: "ViewState is .loading")
        let successExpectation = XCTestExpectation(description: "ViewState is .success")
        successExpectation.isInverted = true
        let failureExpectation = XCTestExpectation(description: "ViewState is .error")
        
        viewModel.$viewState
            .sink { viewState in
                switch viewState {
                case .idle:
                    idleExpectation.fulfill()
                case .loading:
                    loadingExpectation.fulfill()
                case .success(_):
                    successExpectation.fulfill()
                case .error(let message):
                    XCTAssertNotNil(message)
                    failureExpectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        weatherService.shouldFail = true
        viewModel.fetchWeather(name: "City")
        
        wait(for: [idleExpectation, loadingExpectation, successExpectation, failureExpectation], timeout: 2)
    }
    
    func testFetchWeatherByCoordinateSuccess() throws {
        let idleExpectation = XCTestExpectation(description: "ViewState is .idle")
        let loadingExpectation = XCTestExpectation(description: "ViewState is .loading")
        let successExpectation = XCTestExpectation(description: "ViewState is .success")
        let failureExpectation = XCTestExpectation(description: "ViewState is .error")
        failureExpectation.isInverted = true
        
        viewModel.$viewState
            .sink { viewState in
                switch viewState {
                case .idle:
                    idleExpectation.fulfill()
                case .loading:
                    loadingExpectation.fulfill()
                case .success(let weather):
                    XCTAssertNotNil(weather)
                    XCTAssertEqual(weather.displayName, "CityName, US")
                    successExpectation.fulfill()
                case .error(_):
                    failureExpectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.fetchWeather(latitude: 10, longitude: 10)
        
        wait(for: [idleExpectation, loadingExpectation, successExpectation, failureExpectation], timeout: 2)
    }
    
    func testFetchWeatherByCoordinateError() throws {
        let idleExpectation = XCTestExpectation(description: "ViewState is .idle")
        let loadingExpectation = XCTestExpectation(description: "ViewState is .loading")
        let successExpectation = XCTestExpectation(description: "ViewState is .success")
        successExpectation.isInverted = true
        let failureExpectation = XCTestExpectation(description: "ViewState is .error")
        
        viewModel.$viewState
            .sink { viewState in
                switch viewState {
                case .idle:
                    idleExpectation.fulfill()
                case .loading:
                    loadingExpectation.fulfill()
                case .success(_):
                    successExpectation.fulfill()
                case .error(let message):
                    XCTAssertNotNil(message)
                    failureExpectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        weatherService.shouldFail = true
        viewModel.fetchWeather(latitude: 10, longitude: 10)

        wait(for: [idleExpectation, loadingExpectation, successExpectation, failureExpectation], timeout: 2)
    }
    
    func testFetchLocationSuggestionsSuccess() throws {
        let successExpectation = XCTestExpectation(description: "Location suggestions success")
        
        viewModel.$locationSuggestions
            .dropFirst()
            .sink { suggestions in
                XCTAssertTrue(!suggestions.isEmpty)
                XCTAssertEqual(suggestions.first!.displayName, "CityName, State, Country")
                successExpectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.searchText = "CityName"
        viewModel.fetchLocationSuggestions()
        
        wait(for: [successExpectation], timeout: 2)
    }
    
    func testFetchLocationSuggestionsError() throws {
        let failureExpectation = XCTestExpectation(description: "Location suggestions failure")
        
        viewModel.$locationSuggestions
            .sink { suggestions in
                XCTAssertTrue(suggestions.isEmpty)
                failureExpectation.fulfill()
            }
            .store(in: &subscriptions)
        
        weatherService.shouldFail = true
        viewModel.searchText = "CityName"
        viewModel.fetchLocationSuggestions()
        
        wait(for: [failureExpectation], timeout: 2)
    }
}

class MockWeatherService: WeatherService {
    var shouldFail: Bool = false
    
    func fetchWeather(_ name: String) async throws -> WeatherResposne {
        if shouldFail {
            throw NetworkError.general
        }
        return WeatherResposne(cityName: "CityName",
                               main: WeatherResposne.Main(temp: 70, feelsLike: 72, tempMin: 65, tempMax: 80, humidity: 40),
                               wind: WeatherResposne.Wind(speed: 12),
                               weatherType: [WeatherResposne.WeatherType(id: 1, main: "Cloudy", description: "Mostly clouds", icon: "04n")],
                               sys: WeatherResposne.Sys(country: "US"))
    }
    
    func fetchWeather(_ lat: Double, _ lon: Double) async throws -> WeatherResposne {
        if shouldFail {
            throw NetworkError.general
        }
        return WeatherResposne(cityName: "CityName",
                               main: WeatherResposne.Main(temp: 70, feelsLike: 72, tempMin: 65, tempMax: 80, humidity: 40),
                               wind: WeatherResposne.Wind(speed: 12),
                               weatherType: [WeatherResposne.WeatherType(id: 1, main: "Cloudy", description: "Mostly clouds", icon: "04n")],
                               sys: WeatherResposne.Sys(country: "US"))
    }
    
    func fetchLocationSuggestions(_ location: String) async throws -> [LocationSuggestion] {
        if shouldFail {
            throw NetworkError.general
        }
        
        return [LocationSuggestion(name: "CityName", lat: 10.34, lon: 70.23, state: "State", country: "Country")]
    }
}
