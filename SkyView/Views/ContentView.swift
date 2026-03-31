import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityInput = ""
    @State private var isCelsius = true

    var backgroundColors: [Color] {
        guard let condition = viewModel.weather?.weather.first?.main else {
            return [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]
        }
        switch condition {
        case "Rain", "Drizzle", "Thunderstorm":
            return [Color.gray, Color.blue.opacity(0.7)]
        case "Snow":
            return [Color.white.opacity(0.8), Color.blue.opacity(0.3)]
        case "Clear":
            return [Color.orange.opacity(0.7), Color.yellow.opacity(0.6)]
        case "Clouds":
            return [Color.gray.opacity(0.5), Color.blue.opacity(0.5)]
        default:
            return [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: viewModel.weather?.weather.first?.main)

            ScrollView {
                VStack(spacing: 24) {

                    // App Title
                    Text("SkyView")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 60)

                    // Search Bar
                    HStack {
                        TextField("Enter city name...", text: $cityInput)
                            .padding(14)
                            .background(.white.opacity(0.2))
                            .cornerRadius(14)
                            .foregroundColor(.white)
                            .tint(.white)
                            .onSubmit {
                                Task { await viewModel.fetchWeather(for: cityInput) }
                            }

                        Button {
                            Task { await viewModel.fetchWeather(for: cityInput) }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .padding(14)
                                .background(.white.opacity(0.3))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    // Celsius / Fahrenheit Toggle
                    Picker("Unit", selection: $isCelsius) {
                        Text("°C").tag(true)
                        Text("°F").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 60)

                    // Content Area
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                            .padding(.top, 60)

                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)

                    } else if let weather = viewModel.weather {
                        WeatherCardView(weather: weather, isCelsius: isCelsius)

                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "cloud.sun.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Search for a city to get started")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 60)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
    }
}
