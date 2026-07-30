//
//  Models.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 17/07/26.
//

import SwiftData
import Foundation

@Model
final class FavoriteCity {
    @Attribute(.unique) var id: String
    var cityName: String
    var cityCountry: String
    var latitude: Double
    var longitude: Double
    var addedDate: Date

    init(cityName: String, cityCountry: String, latitude: Double, longitude: Double) {
        self.id = "\(cityName), \(cityCountry)"
        self.cityName = cityName
        self.cityCountry = cityCountry
        self.latitude = latitude
        self.longitude = longitude
        self.addedDate = Date()
    }

    var asCityResult: CityResult {
        CityResult(name: cityName, latitude: latitude, longitude: longitude, country: cityCountry)
    }
}
