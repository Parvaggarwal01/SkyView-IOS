import Foundation

struct WeatherResponse: Codable {
    let name: String              // City name
    let main: MainWeather
    let weather: [WeatherInfo]
    let wind: Wind
}

struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    let tempMin: Double
    let tempMax: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct WeatherInfo: Codable {
    let description: String
    let icon: String
    let main: String
}

struct Wind: Codable {
    let speed: Double
}

// MARK: - Forecast Models

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable, Identifiable {
    let dt: Int
    let main: MainWeather
    let weather: [WeatherInfo]
    let wind: Wind
    let dtTxt: String

    var id: Int { dt }

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, wind
        case dtTxt = "dt_txt"
    }

    /// Returns the date from the Unix timestamp
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }

    /// Formatted day name (e.g., "Mon", "Tue")
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Formatted time (e.g., "3 PM")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
}

struct City: Codable {
    let name: String
    let country: String
}
