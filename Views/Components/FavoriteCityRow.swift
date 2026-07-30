//
//  FavoriteCityRow.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 21/07/26.
//

import SwiftUI
import SwiftData

struct FavoriteCityRow: View {
    let favorite: FavoriteCity
    var onSelect: () -> Void = {}

    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteCity]

    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(favorite.cityName)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(favorite.cityCountry)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.bold())
                        .foregroundStyle(.white.opacity(0.5))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: removeFavorite) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(WeatherTheme.cardBackground)
        .clipShape(.rect(cornerRadius: WeatherTheme.cardCornerRadius))
    }

    private func removeFavorite() {
        favoritesViewModel.toggleFavorite(
            name: favorite.cityName,
            country: favorite.cityCountry,
            latitude: favorite.latitude,
            longitude: favorite.longitude,
            favorites: favorites,
            context: modelContext
        )
    }
}

//#Preview {
//    ZStack {
//        LinearGradient(colors: WeatherTheme.gradientColors, startPoint: .top, endPoint: .bottom)
//            .ignoresSafeArea()
//        FavoriteCityRow(favorite: FavoriteCity(cityName: "Campinas", cityCountry: "Brazil", latitude: -22.9, longitude: -47.0))
//            .padding()
//    }
//    .environmentObject(FavoritesViewModel())
//    .modelContainer(for: [FavoriteCity.self], inMemory: true)
//}
