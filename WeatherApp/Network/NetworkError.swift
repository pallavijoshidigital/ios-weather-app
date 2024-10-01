//
//  NetworkError.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case general
    
    // TODO: Read from localizable string file
    var userMessage: String {
        switch self {
        case .badURL:
            return "Bad url"
        case .general:
            return "Oops, something went wrong. Please try again later."
        }
    }
}
