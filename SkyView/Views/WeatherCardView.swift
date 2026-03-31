import SwiftUI

struct WeatherCardView: View {
    let weather: WeatherResponse
    let isCelsius: Bool

    func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius))°C"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit))°F"
        }
    }

    var weatherEmoji: String {
        switch weather.weather.first?.main {
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
        VStack(spacing: 16) {

            // City + Emoji
            VStack(spacing: 4) {
                Text(weather.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(weatherEmoji)
                    .font(.system(size: 70))

                Text(weather.weather.first?.description.capitalized ?? "")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.85))
            }

            // Temperature
            Text(convertTemp(weather.main.temp))
                .font(.system(size: 88, weight: .thin))
                .foregroundColor(.white)

            // Feels like
            Text("Feels like \(convertTemp(weather.main.feelsLike))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))

            // Stats Row
            HStack(spacing: 30) {
                StatView(icon: "humidity.fill", label: "\(weather.main.humidity)%", title: "Humidity")
                StatView(icon: "wind", label: "\(Int(weather.wind.speed)) m/s", title: "Wind")
                StatView(icon: "thermometer.low", label: convertTemp(weather.main.tempMin), title: "Low")
                StatView(icon: "thermometer.high", label: convertTemp(weather.main.tempMax), title: "High")
            }
            .padding()
            .background(.white.opacity(0.15))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

struct StatView: View {
    let icon: String
    let label: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.85))
            Text(label)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
