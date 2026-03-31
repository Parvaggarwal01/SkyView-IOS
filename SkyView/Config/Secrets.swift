//
//  Secrets.swift
//  SkyView
//
//  API Key Configuration
//

import Foundation

enum Secrets {
    /// OpenWeatherMap API Key
    ///
    /// To set up:
    /// 1. Create a file named `Secrets.xcconfig` in the Config folder
    /// 2. Add: OPENWEATHER_API_KEY = your_api_key_here
    /// 3. Or directly replace the fallback value below (not recommended for production)
    static var openWeatherAPIKey: String {
        // Try to load from Info.plist (set via xcconfig)
        if let key = Bundle.main.infoDictionary?["OPENWEATHER_API_KEY"] as? String,
           !key.isEmpty,
           key != "$(OPENWEATHER_API_KEY)" {
            return key
        }

        // Fallback: Direct API key (replace this for quick testing)
        return "YOUR_API_KEY_HERE"
    }
}
