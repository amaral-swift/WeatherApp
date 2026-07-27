//
//  HourlyForecastView.swift
//  WeatherApp
//
//  Created by Gabriel Amaral on 20/07/26.
//

import SwiftUI
import Charts

struct HourlyForecastView: View {
    let forecast: [HourlyForecast]
    let timezone: String

    private var timeZone: TimeZone {
        TimeZone(identifier: timezone) ?? .current
    }

    private func axisLabel(for date: Date) -> String {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return "\(calendar.component(.hour, from: date))h"
    }

    private var temperatureRange: ClosedRange<Double> {
        let temperatures = forecast.map(\.temperature)
        guard let minTemperature = temperatures.min(), let maxTemperature = temperatures.max() else {
            return 0...1
        }
        return (minTemperature - 4)...(maxTemperature + 6)
    }

    // Swift Charts pads its automatic date domain slightly past the last data
    // point, which pushes the final hour-stride tick beyond any real value and
    // clips its label against the frame edge. Clamping to the actual first/last
    // forecast times keeps every tick tied to a real point.
    private var timeDomain: ClosedRange<Date> {
        let dates = forecast.map(date(for:))
        guard let first = dates.first, let last = dates.last, first < last else {
            let now = Date()
            return now...now.addingTimeInterval(3600)
        }
        return first...last
    }

    var body: some View {
        if !forecast.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Próximas Horas")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                Chart(Array(forecast.enumerated()), id: \.element.id) { index, hourly in
                    let point = date(for: hourly)

                    AreaMark(
                        x: .value("Hora", point),
                        y: .value("Temperatura", hourly.temperature)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .accessibilityHidden(true)

                    LineMark(
                        x: .value("Hora", point),
                        y: .value("Temperatura", hourly.temperature)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)

                    PointMark(
                        x: .value("Hora", point),
                        y: .value("Temperatura", hourly.temperature)
                    )
                    .symbolSize(index == 0 ? 70 : 30)
                    .foregroundStyle(.white.opacity(index == 0 ? 1 : 0.7))
                    .annotation(position: .top, spacing: 6) {
                        Text("\(Int(hourly.temperature.rounded()))°")
                            .font(.caption.weight(index == 0 ? .semibold : .regular))
                            .foregroundStyle(.white.opacity(index == 0 ? 1 : 0.8))
                    }
                    .accessibilityLabel(index == 0 ? "Agora" : formatHourlyTime(hourly.time, timezone: timezone))
                    .accessibilityValue("\(Int(hourly.temperature.rounded()))°, \(describeWeather(hourly.weatherCode))")
                }
                .chartYScale(domain: temperatureRange)
                .chartYAxis(.hidden)
                .chartXScale(domain: timeDomain)
                .chartXAxis {
                    AxisMarks(preset: .inset, values: .stride(by: .hour)) { value in
                        AxisGridLine().foregroundStyle(.white.opacity(0.15))
                        AxisValueLabel {
                            if let axisDate = value.as(Date.self) {
                                Text(axisLabel(for: axisDate))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
            .padding()
            .background(WeatherTheme.cardBackground)
            .clipShape(.rect(cornerRadius: WeatherTheme.cardCornerRadius))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func date(for hourly: HourlyForecast) -> Date {
        hourlyDate(hourly.time, timezone: timezone) ?? .now
    }
}

// Kept for now in case the card-based layout is needed again later.
//#Preview {
//    ZStack {
//        LinearGradient(colors: WeatherTheme.gradientColors, startPoint: .top, endPoint: .bottom)
//            .ignoresSafeArea()
//        HourlyForecastView(
//            forecast: [
//                HourlyForecast(time: "2026-07-20T14:00", temperature: 22, weatherCode: 0, windSpeed: 10),
//                HourlyForecast(time: "2026-07-20T15:00", temperature: 21, weatherCode: 3, windSpeed: 12),
//                HourlyForecast(time: "2026-07-20T16:00", temperature: 20, weatherCode: 61, windSpeed: 14)
//            ],
//            timezone: "America/Sao_Paulo"
//        )
//        .padding()
//    }
//}

//    ScrollView(.horizontal, showsIndicators: false) {
//        HStack(spacing: 12) {
//            ForEach(forecast.enumerated(), id: \.element.id) { index, hourly in
//                HourlyForecastRow(hourly: hourly, timezone: timezone, isNow: index == 0)
//            }
//        }
//    }
