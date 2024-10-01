//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import Combine
import SwiftUI

final class AppCoordinator: ObservableObject {
    
    @Published var path: NavigationPath
    
    init(path: NavigationPath) {
        self.path = path
    }
    
    func push<T: Hashable>(_ coordinator: T) {
        path.append(coordinator)
    }
    
    func pop() {
        path.removeLast()
    }
    
    @ViewBuilder
    func build(screen: AppScreens) -> some View {
        switch screen {
        case .home: HomeView()
        }
    }
}

