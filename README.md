# SkyView 🌤️

A clean, modern iOS weather app built with **Swift** and **SwiftUI** using MVVM architecture.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- 🔍 **City Search** — Search weather for any city worldwide
- 🌡️ **Temperature Toggle** — Switch between Celsius and Fahrenheit
- 🎨 **Dynamic Backgrounds** — Gradient changes based on weather conditions
- 💨 **Weather Stats** — Humidity, wind speed, feels-like temperature
- 📅 **5-Day Forecast** — See upcoming weather predictions
- ⚡ **Modern Swift** — Built with async/await and Combine
- 📱 **Clean UI** — Loading, error, and empty states handled gracefully

## Screenshots

| Search | Weather Display | Error State |
|--------|-----------------|-------------|
| *Enter a city name* | *Current weather with stats* | *City not found message* |

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Swift 5.9 | Primary language |
| SwiftUI | UI framework |
| MVVM | Architecture pattern |
| URLSession + async/await | Networking |
| OpenWeatherMap API | Weather data |

## Project Structure

```
SkyView/
├── SkyViewApp.swift              # App entry point
├── Config/
│   ├── Secrets.swift             # API key loader
│   └── Secrets.xcconfig          # Your API key (gitignored)
├── Models/
│   └── WeatherModel.swift        # Codable structs for API response
├── ViewModels/
│   └── WeatherViewModel.swift    # State management & API calls
├── Views/
│   ├── ContentView.swift         # Main search & display screen
│   ├── WeatherCardView.swift     # Temperature & stats card
│   └── ForecastRowView.swift     # 5-day forecast components
├── Services/
│   └── WeatherService.swift      # Network service layer
└── Assets.xcassets/              # App assets
```

## Requirements

- **macOS** 13.0+ (Ventura or later)
- **Xcode** 15.0+
- **iOS** 17.0+ deployment target
- **OpenWeatherMap API key** (free)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/SkyView.git
cd SkyView
```

### 2. Get an API Key (Free)

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account (no credit card required)
3. Navigate to **API Keys** in your dashboard
4. Copy your API key (takes ~10 minutes to activate)

### 3. Add Your API Key

**Option A: Using Config File (Recommended)**

Edit `SkyView/Config/Secrets.xcconfig`:
```
OPENWEATHER_API_KEY = your_actual_api_key_here
```

**Option B: Quick Setup (For Testing)**

Edit `SkyView/Config/Secrets.swift` and replace the fallback value:
```swift
return "your_actual_api_key_here"
```

> ⚠️ **Important**: The `Secrets.xcconfig` file is gitignored to protect your API key. Never commit API keys to version control.

### 4. Run the App

**Using Xcode (Recommended)**

1. Open `SkyView.xcodeproj` in Xcode:
   ```bash
   open SkyView.xcodeproj
   ```
2. Select a simulator (iPhone 15, iPhone 15 Pro, etc.)
3. Press `Cmd + R` or click the **Run** button

**Using Command Line**

```bash
# List available simulators
xcrun simctl list devices available | grep iPhone

# Build and run on simulator
xcodebuild -project SkyView.xcodeproj \
           -scheme SkyView \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build
```

## Usage

1. Launch the app
2. Enter a city name in the search bar (e.g., "London", "New York", "Tokyo")
3. Tap the search button or press Enter
4. View current weather conditions
5. Toggle between °C and °F using the segmented control
6. Scroll down to see the 5-day forecast

## API Reference

This app uses the [OpenWeatherMap API](https://openweathermap.org/api):

**Current Weather:**
```
GET https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric
```

**5-Day Forecast:**
```
GET https://api.openweathermap.org/data/2.5/forecast?q={city}&appid={API_KEY}&units=metric
```

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   View      │ ◄── │  ViewModel   │ ◄── │ WeatherService  │
│  (SwiftUI)  │     │ (@Published) │     │   (Network)     │
└─────────────┘     └──────────────┘     └─────────────────┘
                                                  │
                                                  ▼
                                         ┌─────────────────┐
                                         │ OpenWeatherMap  │
                                         │      API        │
                                         └─────────────────┘
```

- **Model**: Codable structs that map to API JSON response
- **ViewModel**: Handles business logic, API calls, and publishes state changes
- **View**: SwiftUI views that observe and display ViewModel state
- **Service**: Network layer for API communication

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Invalid API key" error | Wait 10 minutes after creating key, or check if key is correctly entered |
| "City not found" error | Check spelling, try major city names |
| Build fails | Clean build folder (Cmd+Shift+K) and rebuild |
| Simulator not showing | Update Xcode or download iOS simulator runtime |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Built with ❤️ using Swift and SwiftUI

---

*Made for demonstrating Swift, SwiftUI, MVVM, and REST API integration.*
