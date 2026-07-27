//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 14/07/26.
//

import Foundation
import CoreLocation
import MapKit

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol WeatherServiceProtocol {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
    func searchCitiesWithName(_ query: String) async throws -> [CityResult]
}

actor WeatherService: WeatherServiceProtocol {
    private let weatherCache: NSCache<NSString, CacheEntryObject> = NSCache()
    let cacheExpiration: TimeInterval = 900
    
    let session: URLSessionProtocol
    let geocoder = CLGeocoder()
    private let baseURL = "https://api.open-meteo.com/v1"
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        
        let urlString = "\(baseURL)/forecast?" +
        "latitude=\(latitude)" +
        "&longitude=\(longitude)" +
        "&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m" +
        "&timezone=auto" +
        "&hourly=temperature_2m,weather_code,wind_speed_10m"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        if let cached = await weatherCache[url] {
            switch cached {
            case .ready(let weather, let timestamp):
                if Date().timeIntervalSince(timestamp) < cacheExpiration {
                    return weather
                }
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task = Task<WeatherResponse, Error> {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherError.invalidResponse
            }
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherResponse.self, from: data)
        }
        
        weatherCache[url] = .inProgress(task)
        
        do {
            let weather = try await task.value
            weatherCache[url] = .ready(weather, timestamp: Date())
            return weather
        } catch {
            weatherCache[url] = nil
            throw error
        }
    }
    
    func fetchWeatherByCity(_ city: String) async throws -> WeatherResponse {
        switch city.lowercased() {
        case "campinas", "campinas, sp":
            return try await fetchWeather(latitude: -22.9, longitude: -47.0)
        case "são paulo", "sp":
            return try await fetchWeather(latitude: -23.55, longitude: -46.63)
        default:
            throw WeatherError.cityNotFound
        }
    }
    
    func searchCitiesWithName(_ query: String) async throws -> [CityResult] {
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(query)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        
        return response.results ?? []
    }
    
    struct GeocodingResponse: Codable {
        let results: [CityResult]?
    }
    
    
    func getPlacemarkLocation(latitude: Double, longitude: Double) async throws -> PlacemarkLocation {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first,
              let city = placemark.locality ?? placemark.administrativeArea else {
            throw WeatherError.cityNotFound
        }
        
        return PlacemarkLocation(city: city, country: placemark.country ?? "")
    }
}

struct PlacemarkLocation {
    let city: String
    let country: String
}

enum WeatherError: Error {
    case invalidURL
    case invalidResponse
    case cityNotFound
    case decodingError
}
