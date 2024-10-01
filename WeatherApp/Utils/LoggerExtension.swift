//
//  LoggerExtension.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? ""
    // A simple logger
    static let shared = Logger(subsystem: subsystem, category: "Weather")
}
