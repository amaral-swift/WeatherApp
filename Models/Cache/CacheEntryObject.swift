//
//  CacheEntryObject.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 27/07/26.
//

import Foundation

final class CacheEntryObject {
    let entry: CacheEntry
    init(entry: CacheEntry) { self.entry = entry }
}

enum CacheEntry {
    case inProgress(Task<WeatherResponse, Error>)
    case ready(WeatherResponse, timestamp: Date)
}
