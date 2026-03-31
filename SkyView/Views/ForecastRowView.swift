//
//  ForecastRowView.swift
//  SkyView
//
//  Created by Parv Aggarwal on 01/04/26.
//

import SwiftUI

struct ForecastRowView: View {
    let forecast: ForecastItem
    let isCelsius: Bool

    func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius))°"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit))°"
        }
    }

    var weatherEmoji: String {
        switch forecast.weather.first?.main {
        case "Clear": return "☀️"
        case "Clouds": return "☁️"
        case "Rain", "Drizzle": return "🌧️"
        case "Thunderstorm": return "⛈️"
        case "Snow": return "❄️"
        case "Mist", "Fog": return "🌫️"
        default: return "🌤️"
        }
    }

    var body: some View {
        HStack {
            // Day & Time
            VStack(alignment: .leading, spacing: 2) {
                Text(forecast.dayName)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(forecast.timeString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 60, alignment: .leading)

            Spacer()

            // Weather emoji & description
            HStack(spacing: 8) {
                Text(weatherEmoji)
                    .font(.title2)
                Text(forecast.weather.first?.main ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }

            Spacer()

            // Temperature
            Text(convertTemp(forecast.main.temp))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Forecast Section View

struct ForecastSectionView: View {
    let forecasts: [ForecastItem]
    let isCelsius: Bool

    /// Get one forecast per day (noon time preferred)
    var dailyForecasts: [ForecastItem] {
        var seenDays = Set<String>()
        return forecasts.filter { item in
            let day = item.dayName
            if seenDays.contains(day) {
                return false
            }
            // Prefer forecasts around noon (12:00)
            if item.timeString.contains("12") || item.timeString.contains("1 PM") || item.timeString.contains("2 PM") {
                seenDays.insert(day)
                return true
            }
            // If we haven't seen this day yet, include first occurrence
            if !seenDays.contains(day) {
                seenDays.insert(day)
                return true
            }
            return false
        }
        .prefix(5)
        .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(dailyForecasts) { forecast in
                    ForecastRowView(forecast: forecast, isCelsius: isCelsius)
                }
            }
            .padding(.horizontal)
        }
    }
}
