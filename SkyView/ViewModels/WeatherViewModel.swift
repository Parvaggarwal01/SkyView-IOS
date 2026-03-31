import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var forecast: ForecastResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiKey = Secrets.openWeatherAPIKey

    func fetchWeather(for city: String) async {
        guard !city.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        errorMessage = nil
        weather = nil
        forecast = nil
        defer { isLoading = false }

        let weatherURLString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        let forecastURLString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"

        guard let encodedWeather = weatherURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let weatherURL = URL(string: encodedWeather),
              let encodedForecast = forecastURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let forecastURL = URL(string: encodedForecast) else {
            errorMessage = "Invalid city name."
            return
        }

        do {
            // Fetch current weather
            let (weatherData, weatherResponse) = try await URLSession.shared.data(from: weatherURL)

            if let httpResponse = weatherResponse as? HTTPURLResponse, httpResponse.statusCode == 404 {
                errorMessage = "City not found. Please check the name and try again."
                return
            }

            weather = try JSONDecoder().decode(WeatherResponse.self, from: weatherData)
            
            // Fetch forecast
            let (forecastData, _) = try await URLSession.shared.data(from: forecastURL)
            forecast = try JSONDecoder().decode(ForecastResponse.self, from: forecastData)

        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
