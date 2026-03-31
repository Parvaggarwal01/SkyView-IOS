import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityInput = ""
    @State private var isCelsius = true
    @State private var showSearchBar = false
    @FocusState private var isSearchFocused: Bool

    // Dynamic background colors based on weather
    var backgroundColors: [Color] {
        guard let condition = viewModel.weather?.weather.first?.main else {
            return [Color(hex: "1C1C2E"), Color(hex: "2D2D44")]
        }
        switch condition {
        case "Rain", "Drizzle":
            return [Color(hex: "374151"), Color(hex: "1F2937")]
        case "Thunderstorm":
            return [Color(hex: "1F1F3D"), Color(hex: "3D1F5C")]
        case "Snow":
            return [Color(hex: "4A5568"), Color(hex: "2D3748")]
        case "Clear":
            return [Color(hex: "1E3A5F"), Color(hex: "0F1C2E")]
        case "Clouds":
            return [Color(hex: "2D3748"), Color(hex: "1A202C")]
        case "Mist", "Fog", "Haze":
            return [Color(hex: "4A5568"), Color(hex: "2D3748")]
        default:
            return [Color(hex: "1C1C2E"), Color(hex: "2D2D44")]
        }
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: backgroundColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: viewModel.weather?.weather.first?.main)

            VStack(spacing: 0) {
                // Top bar with search
                topBar

                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            loadingView
                        } else if let error = viewModel.errorMessage {
                            errorView(error)
                        } else if let weather = viewModel.weather {
                            weatherContent(weather)
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onTapGesture {
            if showSearchBar && cityInput.isEmpty {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSearchBar = false
                    isSearchFocused = false
                }
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {
            // Search button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSearchBar.toggle()
                    if showSearchBar {
                        isSearchFocused = true
                    }
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }

            // Animated search bar
            if showSearchBar {
                HStack {
                    TextField("Search city...", text: $cityInput)
                        .foregroundColor(.white)
                        .focused($isSearchFocused)
                        .onSubmit {
                            if !cityInput.isEmpty {
                                Task { await viewModel.fetchWeather(for: cityInput) }
                                withAnimation {
                                    showSearchBar = false
                                }
                            }
                        }

                    if !cityInput.isEmpty {
                        Button {
                            Task { await viewModel.fetchWeather(for: cityInput) }
                            withAnimation {
                                showSearchBar = false
                                isSearchFocused = false
                            }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.title2)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }

            Spacer()

            // Temperature unit toggle
            HStack(spacing: 4) {
                Button {
                    isCelsius = true
                } label: {
                    Text("°C")
                        .font(.headline)
                        .foregroundColor(isCelsius ? .white : .white.opacity(0.5))
                }

                Text("/")
                    .foregroundColor(.white.opacity(0.3))

                Button {
                    isCelsius = false
                } label: {
                    Text("°F")
                        .font(.headline)
                        .foregroundColor(!isCelsius ? .white : .white.opacity(0.5))
                }
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Weather Content
    @ViewBuilder
    private func weatherContent(_ weather: WeatherResponse) -> some View {
        // Main temperature display
        VStack(spacing: 4) {
            Text(weather.name)
                .font(.system(size: 34, weight: .regular))
                .foregroundColor(.white)

            Text(convertTemp(weather.main.temp))
                .font(.system(size: 96, weight: .thin))
                .foregroundColor(.white)

            Text(weather.weather.first?.description.uppercased() ?? "")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1.5)

            Text("H:\(convertTemp(weather.main.tempMax))  L:\(convertTemp(weather.main.tempMin))")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)

        // Hourly forecast card
        if let forecast = viewModel.forecast {
            HourlyForecastCard(forecasts: Array(forecast.list.prefix(8)), isCelsius: isCelsius)
                .padding(.horizontal, 16)
        }

        // 5-Day forecast card
        if let forecast = viewModel.forecast {
            DailyForecastCard(forecasts: forecast.list, isCelsius: isCelsius)
                .padding(.horizontal, 16)
        }

        // Additional details
        WeatherDetailsCard(weather: weather, isCelsius: isCelsius)
            .padding(.horizontal, 16)
    }

    // MARK: - Helper Views
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text("Loading weather...")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 100)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            Text(error)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button {
                withAnimation {
                    showSearchBar = true
                    isSearchFocused = true
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
            }
        }
        .padding(.top, 80)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow.opacity(0.8))

            Text("Welcome to SkyView")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Tap the search icon to find\nweather for any city")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSearchBar = true
                    isSearchFocused = true
                }
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search City")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.2))
                .cornerRadius(25)
            }
            .padding(.top, 10)
        }
        .padding(.top, 60)
    }

    // MARK: - Helper Functions
    private func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius))°"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit))°"
        }
    }
}

// MARK: - Hourly Forecast Card

struct HourlyForecastCard: View {
    let forecasts: [ForecastItem]
    let isCelsius: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("HOURLY FORECAST", systemImage: "clock")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(forecasts.enumerated()), id: \.element.id) { index, forecast in
                        VStack(spacing: 8) {
                            Text(index == 0 ? "Now" : forecast.timeString)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)

                            Image(systemName: weatherIcon(for: forecast.weather.first?.main ?? ""))
                                .font(.title2)
                                .foregroundColor(iconColor(for: forecast.weather.first?.main ?? ""))

                            Text(convertTemp(forecast.main.temp))
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(glassBackground)
        .cornerRadius(16)
    }

    private func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius))°"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit))°"
        }
    }

    private func weatherIcon(for condition: String) -> String {
        switch condition {
        case "Clear": return "sun.max.fill"
        case "Clouds": return "cloud.fill"
        case "Rain", "Drizzle": return "cloud.rain.fill"
        case "Thunderstorm": return "cloud.bolt.fill"
        case "Snow": return "cloud.snow.fill"
        case "Mist", "Fog", "Haze": return "cloud.fog.fill"
        default: return "sun.max.fill"
        }
    }

    private func iconColor(for condition: String) -> Color {
        switch condition {
        case "Clear": return .yellow
        case "Clouds": return .white.opacity(0.8)
        case "Rain", "Drizzle": return .cyan
        case "Thunderstorm": return .yellow
        case "Snow": return .white
        default: return .yellow
        }
    }

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Daily Forecast Card

struct DailyForecastCard: View {
    let forecasts: [ForecastItem]
    let isCelsius: Bool

    var dailyForecasts: [DailyForecast] {
        var daily: [String: DailyForecast] = [:]
        let calendar = Calendar.current

        for item in forecasts {
            let dayKey = item.dayName
            if var existing = daily[dayKey] {
                existing.tempMin = min(existing.tempMin, item.main.tempMin)
                existing.tempMax = max(existing.tempMax, item.main.tempMax)
                daily[dayKey] = existing
            } else {
                let isToday = calendar.isDateInToday(item.date)
                daily[dayKey] = DailyForecast(
                    dayName: isToday ? "Today" : dayKey,
                    condition: item.weather.first?.main ?? "",
                    tempMin: item.main.tempMin,
                    tempMax: item.main.tempMax,
                    date: item.date
                )
            }
        }

        return daily.values.sorted { $0.date < $1.date }.prefix(5).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("5-DAY FORECAST", systemImage: "calendar")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))

            VStack(spacing: 0) {
                ForEach(dailyForecasts) { day in
                    DailyForecastRow(day: day, isCelsius: isCelsius, allDays: dailyForecasts)

                    if day.id != dailyForecasts.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
        }
        .padding(16)
        .background(glassBackground)
        .cornerRadius(16)
    }

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

struct DailyForecast: Identifiable {
    let id = UUID()
    var dayName: String
    var condition: String
    var tempMin: Double
    var tempMax: Double
    var date: Date
}

struct DailyForecastRow: View {
    let day: DailyForecast
    let isCelsius: Bool
    let allDays: [DailyForecast]

    var globalMin: Double {
        allDays.map { $0.tempMin }.min() ?? 0
    }

    var globalMax: Double {
        allDays.map { $0.tempMax }.max() ?? 100
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(day.dayName)
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 80, alignment: .leading)

            Image(systemName: weatherIcon(for: day.condition))
                .font(.title3)
                .foregroundColor(iconColor(for: day.condition))
                .frame(width: 30)

            Text(convertTemp(day.tempMin))
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 40, alignment: .trailing)

            // Temperature range bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    let range = globalMax - globalMin
                    let startPercent = range > 0 ? (day.tempMin - globalMin) / range : 0
                    let endPercent = range > 0 ? (day.tempMax - globalMin) / range : 1

                    Capsule()
                        .fill(temperatureGradient)
                        .frame(width: geometry.size.width * CGFloat(endPercent - startPercent), height: 4)
                        .offset(x: geometry.size.width * CGFloat(startPercent))
                }
            }
            .frame(height: 4)

            Text(convertTemp(day.tempMax))
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 10)
    }

    private var temperatureGradient: LinearGradient {
        LinearGradient(
            colors: [.cyan, .yellow, .orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius))°"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit))°"
        }
    }

    private func weatherIcon(for condition: String) -> String {
        switch condition {
        case "Clear": return "sun.max.fill"
        case "Clouds": return "cloud.fill"
        case "Rain", "Drizzle": return "cloud.rain.fill"
        case "Thunderstorm": return "cloud.bolt.fill"
        case "Snow": return "cloud.snow.fill"
        case "Mist", "Fog", "Haze": return "cloud.fog.fill"
        default: return "sun.max.fill"
        }
    }

    private func iconColor(for condition: String) -> Color {
        switch condition {
        case "Clear": return .yellow
        case "Clouds": return .white.opacity(0.8)
        case "Rain", "Drizzle": return .cyan
        case "Thunderstorm": return .yellow
        case "Snow": return .white
        default: return .yellow
        }
    }
}

// MARK: - Weather Details Card

struct WeatherDetailsCard: View {
    let weather: WeatherResponse
    let isCelsius: Bool

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            DetailBox(
                icon: "thermometer.medium",
                title: "FEELS LIKE",
                value: convertTemp(weather.main.feelsLike)
            )

            DetailBox(
                icon: "humidity.fill",
                title: "HUMIDITY",
                value: "\(weather.main.humidity)%"
            )

            DetailBox(
                icon: "wind",
                title: "WIND",
                value: "\(Int(weather.wind.speed)) m/s"
            )

            DetailBox(
                icon: "thermometer.sun.fill",
                title: "HIGH / LOW",
                value: "\(convertTemp(weather.main.tempMax)) / \(convertTemp(weather.main.tempMin))"
            )
        }
    }

    private func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius))°"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit))°"
        }
    }
}

struct DetailBox: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))

            Text(value)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
