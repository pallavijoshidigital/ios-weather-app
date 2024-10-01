//
//  ContentView.swift
//  WeatherApp
//
//  Created by Pallavi Joshi on 9/28/24.
//

import SwiftUI

/// Landing screen
struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var isPresented = false
    
    var body: some View {
        ScrollView {
            ZStack {
                // Reserve space matching the scroll view's frame
                Spacer().containerRelativeFrame([.horizontal, .vertical])
                switch viewModel.viewState {
                case .idle:
                    IdleView()
                case .loading:
                    LoadingView()
                case .success(let weather):
                    SuccessView(weather: weather)
                case .error(let messageKey):
                    ErrorView(messageKey: messageKey)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            viewModel.startUpdatingLocation()
        }
        .onDisappear {
            viewModel.stopUpdatingLocation()
        }
        .navigationTitle(LocalizedStringKey("HomeViewTitle"))
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchText, isPresented: $isPresented, prompt: LocalizedStringKey("StartSearch"))
        .onSubmit(of: .search, {
            isPresented = false
            viewModel.fetchWeather(name: viewModel.searchText)
        })
        .task(id: $viewModel.searchText.wrappedValue) {
            try? await Task.sleep(for: .seconds(0.5))
            if Task.isCancelled || !isPresented { return }
            viewModel.fetchLocationSuggestions()
        }
        .searchSuggestions {
            if !$viewModel.locationSuggestions.isEmpty {
                ForEach($viewModel.locationSuggestions, id: \.id) { suggestion in
                    Text(suggestion.displayName.wrappedValue)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundStyle(.label)
                        .searchCompletion(suggestion.displayName.wrappedValue)
                }
            } else {
                Text("NoResultFound")
                    .font(.system(size: 20, weight: .regular, design: .default))
            }
        }
        
    }
}

/// Initial screen for first time launch when app neither has user's location nor a last searched location
struct IdleView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("StartSearch")
                .font(.system(size: 20, weight: .regular, design: .default))
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Progress View
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .controlSize(.extraLarge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// View to handle errors
struct ErrorView: View {
    let messageKey: String
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(LocalizedStringKey(messageKey))
                .font(.system(size: 20, weight: .regular, design: .default))
                .padding()
        }
    }
}

/// Weather details screen
struct SuccessView: View {
    let weather: Weather
    
    var body: some View {
        VStack {
            Text(weather.displayName)
                .font(.system(size: 32, weight: .medium, design: .default))
            weatherImage(weather)
            tempertureView(weather)
            Text(weather.description)
                .font(.system(size: 25, weight: .medium, design: .default))
            minMaxView(weather)
            currentConditionsView(weather)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder private func tempertureView(_ weather: Weather) -> some View {
        HStack(spacing: 1) {
            Text(weather.temperature)
                .font(.system(size: 50, weight: .regular, design: .default))
        }
    }
    
    @ViewBuilder private func weatherImage(_ weather: Weather) -> some View {
        if let url = weather.iconUrl {
            AsyncImage(
                url: url,
                transaction: Transaction(animation: .easeInOut)
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .transition(.scale(scale: 0.1, anchor: .center))
                case .failure:
                    Image(systemName: "wifi.slash")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .background(.gray)
            .clipShape(Circle())
        }
    }
    
    @ViewBuilder private func minMaxView(_ weather: Weather) -> some View {
        HStack {
            Text("L: \(weather.minTemperature)")
                .font(.system(size: 25, weight: .medium, design: .default))
                .padding()
            Text("H: \(weather.maxTemperature)")
                .font(.system(size: 25, weight: .medium, design: .default))
        }
    }
    
    @ViewBuilder private func currentConditionsView(_ weather: Weather) -> some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .fill(.gray)
                    .overlay(
                        Text("Wind: \(weather.wind) mph")
                    )
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .fill(.gray)
                    .overlay(
                        Text("Humidity: \(weather.humidity) %")
                    )
            }
            .frame(height: 70)
        }
        .padding()
    }
}

#Preview {
    IdleView()
}

#Preview {
    ErrorView(messageKey: "Something went wrong")
}

#Preview {
    SuccessView(weather: Weather(displayName: "City, Country", description: "Overcast", temperature: "38F", feelsLikeTemperature: "39F", minTemperature: "20F", maxTemperature: "40F", iconUrl: URL(string: "https://openweathermap.org/img/wn/01n@2x.png"), wind: "12", humidity: "60"))
}
