//
//  WeatherService.swift
//  SkyView
//
//  Created by Parv Aggarwal on 01/04/26.
//

import Foundation

/// Network service for fetching weather data from OpenWeatherMap API
actor WeatherService {
    static let shared = WeatherService()

    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = Secrets.openWeatherAPIKey

    private init() {}

    /// Fetch current weather for a city
    func fetchCurrentWeather(for city: String) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/weather?q=\(city)&appid=\(apiKey)&units=metric"

        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            throw WeatherError.invalidCity
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.networkError
        }

        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        case 404:
            throw WeatherError.cityNotFound
        case 401:
            throw WeatherError.invalidAPIKey
        default:
            throw WeatherError.networkError
        }
    }

    /// Fetch 5-day forecast for a city
    func fetchForecast(for city: String) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast?q=\(city)&appid=\(apiKey)&units=metric"

        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            throw WeatherError.invalidCity
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.networkError
        }

        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(ForecastResponse.self, from: data)
        case 404:
            throw WeatherError.cityNotFound
        case 401:
            throw WeatherError.invalidAPIKey
        default:
            throw WeatherError.networkError
        }
    }
}

/// Weather-related errors
enum WeatherError: LocalizedError {
    case invalidCity
    case cityNotFound
    case invalidAPIKey
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCity:
            return "Invalid city name."
        case .cityNotFound:
            return "City not found. Please check the name and try again."
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .networkError:
            return "Something went wrong. Please try again."
        }
    }
}
