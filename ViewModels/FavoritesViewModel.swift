//
//  FavoritesViewModel.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 21/07/26.
//

import Foundation
import Combine
import SwiftData

@MainActor
class FavoritesViewModel: ObservableObject {

    @Published var saveError: String?

    func isFavorite(name: String, country: String, in favorites: [FavoriteCity]) -> Bool {
        favorite(name: name, country: country, in: favorites) != nil
    }

    func favorite(name: String, country: String, in favorites: [FavoriteCity]) -> FavoriteCity? {
        favorites.first { $0.cityName == name && $0.cityCountry == country }
    }

    @discardableResult
    func toggleFavorite(
        name: String,
        country: String,
        latitude: Double,
        longitude: Double,
        favorites: [FavoriteCity],
        context: ModelContext
    ) -> FavoriteCity? {
        if let existing = favorite(name: name, country: country, in: favorites) {
            context.delete(existing)
            saveContext(context)
            return nil
        } else {
            let newFavorite = FavoriteCity(
                cityName: name,
                cityCountry: country,
                latitude: latitude,
                longitude: longitude
            )
            context.insert(newFavorite)
            saveContext(context)
            return newFavorite
        }
    }

    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            saveError = "Não foi possível salvar: \(error.localizedDescription)"
        }
    }
}
