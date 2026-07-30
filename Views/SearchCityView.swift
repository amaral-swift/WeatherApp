//
//  SearchCityView.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 16/07/26.
//

import SwiftUI
import SwiftData

struct SearchCityView: View {
    let weatherService: WeatherServiceProtocol
    @StateObject private var searchViewModel = CitySearchViewModel()
    @State private var searchText = ""
    @State private var selectedCity: CityResult?
    @State private var displayedTemperature: Double = WeatherTheme.defaultTemperature
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                searchContent
            }
            .navigationTitle("Buscar Clima")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Digite uma cidade"
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .task(id: searchText) {
                guard !searchText.isEmpty else {
                    searchViewModel.clear()
                    return
                }

                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }

                await searchViewModel.search(searchText)
            }
            .navigationDestination(item: $selectedCity) { city in
                ZStack {
                    backgroundGradient
                    selectedCityContent(city)
                }
                .navigationTitle(city.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: WeatherTheme.gradientColors(temperature: displayedTemperature),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(WeatherTheme.backgroundTransition, value: displayedTemperature)
    }

    private func selectedCityContent(_ city: CityResult) -> some View {
        CityWeatherDetailView(city: city, weatherService: weatherService, onTemperatureChange: { temperature in
            displayedTemperature = temperature ?? WeatherTheme.defaultTemperature
        }) {
            CityFavoriteControls(city: city)
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        if searchViewModel.isSearching {
            ProgressView()
                .tint(.white)
        } else if let errorMessage = searchViewModel.errorMessage {
            WeatherErrorView(message: errorMessage) {
                Task { await searchViewModel.search(searchText) }
            }
        } else if searchText.isEmpty {
            ContentUnavailableView(
                "Buscar Cidade",
                systemImage: "magnifyingglass",
                description: Text("Digite o nome de uma cidade para ver o clima.")
            )
            .foregroundStyle(.white)
        } else if searchViewModel.results.isEmpty {
            ContentUnavailableView.search(text: searchText)
                .foregroundStyle(.white)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(searchViewModel.results) { city in
                        CitySearchRow(city: city, onSelect: { selectCity(city) })
                    }
                }
                .padding()
            }
        }
    }

    private func selectCity(_ city: CityResult) {
        // Resign the search field's focus so the keyboard doesn't stay open
        // underneath the pushed city detail screen.
        dismissSearch()
        selectedCity = city
    }
}

#Preview {
    SearchCityView(weatherService: WeatherService())
        .environmentObject(FavoritesViewModel())
        .modelContainer(for: [FavoriteCity.self], inMemory: true)
}
