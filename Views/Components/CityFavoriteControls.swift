//
//  CityFavoriteControls.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 21/07/26.
//

import SwiftUI
import SwiftData
struct CityFavoriteControls: View {
    let city: CityResult

    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteCity]

    private var favorite: FavoriteCity? {
        favoritesViewModel.favorite(name: city.name, country: city.country, in: favorites)
    }

    var body: some View {
        Button(action: toggleFavorite) {
            Label(favorite != nil ? "Favoritado" : "Favoritar", systemImage: favorite != nil ? "star.fill" : "star")
        }
        .foregroundStyle(favorite != nil ? .yellow : .white)
        .font(.subheadline.bold())
        .padding()
        .frame(maxWidth: .infinity)
        .background(WeatherTheme.cardBackground)
        .clipShape(.rect(cornerRadius: WeatherTheme.cardCornerRadius))
    }

    private func toggleFavorite() {
        favoritesViewModel.toggleFavorite(
            name: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            favorites: favorites,
            context: modelContext
        )
    }
}

//#Preview {
//    ZStack {
//        LinearGradient(colors: WeatherTheme.gradientColors, startPoint: .top, endPoint: .bottom)
//            .ignoresSafeArea()
//        CityFavoriteControls(city: CityResult(name: "Campinas", latitude: -22.9, longitude: -47.0, country: "Brazil"))
//            .padding()
//    }
//    .environmentObject(FavoritesViewModel())
//    .modelContainer(for: [FavoriteCity.self], inMemory: true)
//}
