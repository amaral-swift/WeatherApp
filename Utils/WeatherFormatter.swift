//
//  WeatherFormatter.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 15/07/26.
//

import Foundation

func describeWeather(_ code: Int) -> String {
    switch code {
    case 0: return "Céu Limpo"
    case 1, 2: return "Parcialmente Nublado"
    case 3: return "Nublado"
    case 45, 48: return "Névoa"
    case 51...67: return "Chuva"
    case 71...77: return "Neve"
    default: return "Desconhecido"
    }
}

func weatherAnimation(_ code: Int) -> String {
    switch code {
    case 0: return "sun.max.fill"           // Céu limpo
    case 1, 2: return "cloud.sun.fill"      // Parcialmente nublado
    case 3: return "cloud.fill"             // Nublado
    case 45, 48: return "cloud.fog.fill"    // Névoa
    case 51...67: return "cloud.rain.fill"  // Chuva
    case 71...77: return "cloud.snow.fill"  // Neve
    default: return "cloud.fill"
    }
}

private func hourlyTimeParser(for timezone: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: timezone) ?? .current
    return formatter
}

func nextHours(
    from hourlyData: HourlyData,
    timezone: String,
    count: Int = 12,
    now: Date = Date()
) -> [HourlyForecast] {
    let parser = hourlyTimeParser(for: timezone)

    guard let startIndex = hourlyData.time.firstIndex(where: { timeString in
        guard let date = parser.date(from: timeString) else { return false }
        return date >= now
    }) else {
        return []
    }

    let endIndex = min(startIndex + count, hourlyData.time.count)

    return (startIndex..<endIndex).map { index in
        HourlyForecast(
            time: hourlyData.time[index],
            temperature: hourlyData.temperature[index],
            weatherCode: hourlyData.weatherCode[index],
            windSpeed: hourlyData.windSpeed[index]
        )
    }
}

func formatHourlyTime(_ dateString: String, timezone: String) -> String {
    let parser = hourlyTimeParser(for: timezone)

    guard let date = parser.date(from: dateString) else { return dateString }

    return date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: parser.timeZone))
}

func hourlyDate(_ dateString: String, timezone: String) -> Date? {
    hourlyTimeParser(for: timezone).date(from: dateString)
}
