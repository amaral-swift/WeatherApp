//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 14/07/26.
//

import SwiftUI
import SwiftData

@main
struct WeatherAppApp: App {
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    // Shared across every screen so its NSCache is actually reused instead of
    // each screen fetching the same city from scratch.
    private let weatherService: WeatherServiceProtocol = WeatherService()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Clima", systemImage: "cloud.sun.fill") {
                    ContentView(weatherService: weatherService)
                }
                Tab("Buscar", systemImage: "magnifyingglass") {
                    SearchCityView(weatherService: weatherService)
                }
                Tab("Favoritos", systemImage: "star.fill") {
                    FavoritesView(weatherService: weatherService)
                }
            }
            .environmentObject(favoritesViewModel)
            .preferredColorScheme(.dark)
            .alert(
                "Não foi possível concluir",
                isPresented: Binding(
                    get: { favoritesViewModel.saveError != nil },
                    set: { isPresented in
                        if !isPresented { favoritesViewModel.saveError = nil }
                    }
                )
            ) {
                Button("OK") {}
            } message: {
                Text(favoritesViewModel.saveError ?? "")
            }
        }
        .modelContainer(for: [FavoriteCity.self])
    }
}
