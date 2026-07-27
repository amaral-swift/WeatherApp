//
//  CityResult.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 16/07/26.
//

import Foundation

struct CityResult: Codable, Identifiable, Equatable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String

    var id: String { "\(name)-\(country)-\(latitude)-\(longitude)" }
}
