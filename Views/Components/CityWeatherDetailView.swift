//
//  CityWeatherDetailView.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 21/07/26.
//

import SwiftUI
import MapKit

/// Displays icon, current conditions, hourly forecast and map for a given city.
/// Used both by search results and by the favorites list, so the two stay visually identical.
struct CityWeatherDetailView<Trailing: View>: View {
    let city: CityResult
    var onTemperatureChange: (Double?) -> Void = { _ in }
    @ViewBuilder var trailing: () -> Trailing

    @StateObject private var weatherViewModel: WeatherViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic

    init(
        city: CityResult,
        weatherService: WeatherServiceProtocol,
        onTemperatureChange: @escaping (Double?) -> Void = { _ in },
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.city = city
        self.onTemperatureChange = onTemperatureChange
        self.trailing = trailing
        _weatherViewModel = StateObject(wrappedValue: WeatherViewModel(service: weatherService))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WeatherTheme.contentSpacing) {
                if let weather = weatherViewModel.weather {
                    WeatherIconView(weatherCode: weather.current.weatherCode)
                }

                Text(city.name)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text(city.country)
                    .font(.headline)
                    .foregroundStyle(.white)

                if weatherViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else if let errorMessage = weatherViewModel.errorMessage {
                    WeatherErrorView(message: errorMessage) {
                        Task { await fetchWeather() }
                    }
                } else if let weather = weatherViewModel.weather {
                    CurrentWeatherCard(weather: weather.current)
                }

                HourlyForecastView(
                    forecast: weatherViewModel.hourlyForecast,
                    timezone: weatherViewModel.weather?.timezone ?? TimeZone.current.identifier
                )

                LocationMapView(
                    cameraPosition: $cameraPosition,
                    latitude: city.latitude,
                    longitude: city.longitude,
                    markerTitle: city.name
                )

                trailing()
            }
            .padding()
        }
        .task(id: city) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
            await fetchWeather()
        }
        .onChange(of: weatherViewModel.weather?.current.temperature) { _, newTemperature in
            onTemperatureChange(newTemperature)
        }
        .onDisappear {
            onTemperatureChange(nil)
        }
    }

    private func fetchWeather() async {
        await weatherViewModel.fetchWeather(latitude: city.latitude, longitude: city.longitude)
    }
}

extension CityWeatherDetailView where Trailing == EmptyView {
    init(city: CityResult, weatherService: WeatherServiceProtocol) {
        self.init(city: city, weatherService: weatherService, trailing: { EmptyView() })
    }
}

//#Preview {
//    ZStack {
//        LinearGradient(colors: WeatherTheme.gradientColors, startPoint: .top, endPoint: .bottom)
//            .ignoresSafeArea()
//        CityWeatherDetailView(city: CityResult(name: "Campinas", latitude: -22.9, longitude: -47.0, country: "Brazil"), weatherService: WeatherService())
//    }
//}
