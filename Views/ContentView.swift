//
//  ContentView.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 14/07/26.
//

import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    @StateObject var weatherViewModel: WeatherViewModel
    @StateObject var locationViewModel = LocationViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var loadingStarted = false

    init(weatherService: WeatherServiceProtocol) {
        _weatherViewModel = StateObject(wrappedValue: WeatherViewModel(service: weatherService))
    }

    private var errorMessage: String? {
        weatherViewModel.errorMessage ?? locationViewModel.errorMessage
    }

    private var currentCity: CityResult? {
        guard let cityName = locationViewModel.cityName,
              locationViewModel.latitude != 0,
              locationViewModel.longitude != 0 else { return nil }

        return CityResult(
            name: cityName,
            latitude: locationViewModel.latitude,
            longitude: locationViewModel.longitude,
            country: locationViewModel.countryName ?? ""
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: WeatherTheme.gradientColors(temperature: weatherViewModel.weather?.current.temperature ?? WeatherTheme.defaultTemperature),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(WeatherTheme.backgroundTransition, value: weatherViewModel.weather?.current.temperature)
                
                ScrollView {
                    VStack(spacing: WeatherTheme.contentSpacing) {
                        if let weather = weatherViewModel.weather {
                            WeatherIconView(weatherCode: weather.current.weatherCode)
                        }
                        
                        Text("Clima Agora")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        
                        if let cityName = locationViewModel.cityName {
                            Text(cityName)
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        
                        if weatherViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                        } else if let errorMessage {
                            WeatherErrorView(message: errorMessage, retryAction: retryLoading)
                        } else if let weather = weatherViewModel.weather {
                            CurrentWeatherCard(weather: weather.current)
                        }
                        
                        if let weather = weatherViewModel.weather {
                            HourlyForecastView(
                                forecast: weatherViewModel.hourlyForecast,
                                timezone: weather.timezone
                            )
                        }

                        if let currentCity, weatherViewModel.weather != nil {
                            CityFavoriteControls(city: currentCity)
                        }

                        if locationViewModel.latitude != 0 && locationViewModel.longitude != 0 {
                            LocationMapView(
                                cameraPosition: $cameraPosition,
                                latitude: locationViewModel.latitude,
                                longitude: locationViewModel.longitude
                            )
                        } else {
                            ProgressView()
                                .tint(.white)
                                .frame(minHeight: WeatherTheme.minMapHeight)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: startLoadingIfNeeded)
        .onChange(of: locationViewModel.latitude) { _, newLatitude in
            guard newLatitude != 0, locationViewModel.longitude != 0 else { return }
            fetchWeatherAndCity(lat: newLatitude, lon: locationViewModel.longitude)
        }
        .refreshable {
            await weatherViewModel.fetchWeather(
                latitude: locationViewModel.latitude,
                longitude: locationViewModel.longitude,
                forceRefresh: true
            )
            await locationViewModel.fetchCity(
                latitude: locationViewModel.latitude,
                longitude: locationViewModel.longitude
            )
        }
    }
    
    private func startLoadingIfNeeded() {
        guard !loadingStarted else { return }
        loadingStarted = true
        locationViewModel.requestLocation()
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            if locationViewModel.latitude == 0 {
                loadWeatherWithFallback()
            }
        }
    }
    
    private func retryLoading() {
        loadingStarted = false
        weatherViewModel.errorMessage = nil
        locationViewModel.errorMessage = nil
        startLoadingIfNeeded()
    }
    
    private func loadWeatherWithFallback() {
        Task {
            await weatherViewModel.fetchWeather(latitude: -22.9, longitude: -47.0)
            await locationViewModel.fetchCity(latitude: -22.9, longitude: -47.0)
        }
    }
    
    private func fetchWeatherAndCity(lat: Double, lon: Double) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
        
        Task {
            async let weather: () = weatherViewModel.fetchWeather(latitude: lat, longitude: lon)
            async let city: () = locationViewModel.fetchCity(latitude: lat, longitude: lon)
            
            _ = await (weather, city)
        }
    }
}

#Preview {
    ContentView(weatherService: WeatherService())
}
