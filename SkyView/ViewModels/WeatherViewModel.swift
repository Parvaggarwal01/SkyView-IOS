import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiKey = Secrets.openWeatherAPIKey

    func fetchWeather(for city: String) async {
        guard !city.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        errorMessage = nil
        weather = nil
        defer { isLoading = false }

        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"

        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            errorMessage = "Invalid city name."
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                errorMessage = "City not found. Please check the name and try again."
                return
            }

            weather = try JSONDecoder().decode(WeatherResponse.self, from: data)

        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
