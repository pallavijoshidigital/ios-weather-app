//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import SwiftUI

@main
struct WeatherApp: App {
    
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.path) {
                appCoordinator.build(screen: .home)
            }
            .environmentObject(appCoordinator)
        }
    }
}
