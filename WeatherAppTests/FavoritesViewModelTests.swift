//
//  FavoritesViewModelTests.swift
//  WeatherAppTests
//
//  Created by Gabriel Amaral on 21/07/26.
//

import XCTest
import SwiftData
@testable import WeatherApp

@MainActor
final class FavoritesViewModelTests: XCTestCase {

    var sut: FavoritesViewModel!
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        sut = FavoritesViewModel()
        container = try! ModelContainer(
            for: FavoriteCity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        container = nil
        context = nil
    }

    // Testa: "Favoritar uma cidade nova cria um FavoriteCity e reporta como favorita?"
    func testToggleFavoriteAddsCity() {
        // ACT
        sut.toggleFavorite(
            name: "Campinas",
            country: "Brazil",
            latitude: -22.9,
            longitude: -47.0,
            favorites: [],
            context: context
        )

        // ASSERT
        let favorites = try! context.fetch(FetchDescriptor<FavoriteCity>())
        XCTAssertEqual(favorites.count, 1)
        XCTAssertTrue(sut.isFavorite(name: "Campinas", country: "Brazil", in: favorites))
    }

    // Testa: "Favoritar uma cidade já favorita remove ela (toggle)?"
    func testToggleFavoriteRemovesExistingCity() {
        // ARRANGE
        let existing = FavoriteCity(cityName: "Campinas", cityCountry: "Brazil", latitude: -22.9, longitude: -47.0)
        context.insert(existing)

        // ACT
        sut.toggleFavorite(
            name: "Campinas",
            country: "Brazil",
            latitude: -22.9,
            longitude: -47.0,
            favorites: [existing],
            context: context
        )

        // ASSERT
        let favorites = try! context.fetch(FetchDescriptor<FavoriteCity>())
        XCTAssertTrue(favorites.isEmpty)
    }

    // Testa: "Cidades com o mesmo nome em países diferentes não colidem?"
    func testIsFavoriteDistinguishesSameNameDifferentCountry() {
        // ARRANGE
        let londonUK = FavoriteCity(cityName: "London", cityCountry: "United Kingdom", latitude: 51.5, longitude: -0.12)

        // ASSERT
        XCTAssertTrue(sut.isFavorite(name: "London", country: "United Kingdom", in: [londonUK]))
        XCTAssertFalse(sut.isFavorite(name: "London", country: "Canada", in: [londonUK]))
    }
}
