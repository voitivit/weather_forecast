//
//  Weather.swift
//  weather
//
//  Created by emil kurbanov on 26.09.2023.
//

import Foundation

struct Weather: Decodable {
    let list: [DailyTemperature]
    let cityName: String

    enum CodingKeys: String, CodingKey {
        case city
        case list

        enum CityCodingKeys: String, CodingKey {
            case name
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        list = try container.decode([DailyTemperature].self, forKey: .list)
        let tempsContainer = try container.nestedContainer(keyedBy: CodingKeys.CityCodingKeys.self, forKey: .city)
        cityName = try tempsContainer.decode(String.self, forKey: .name)
    }
}

struct DailyTemperature: Decodable {
    let date: Date
    let temperatureMax: Double
    let temperatureMin: Double
    let day: Double
    let weather: [DailyWeather]

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case weather
        case main = "main"

        enum TempCodingKeys: String, CodingKey {
            case temperatureMax = "temp_max"
            case temperatureMin = "temp_min"
            case day = "temp"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let dateInt = try container.decode(Int.self, forKey: .date)
            date = Date(timeIntervalSince1970: TimeInterval(dateInt))
        }
        let ratingsContainer = try container.nestedContainer(keyedBy: CodingKeys.TempCodingKeys.self, forKey: .main)
        temperatureMax = try ratingsContainer.decode(Double.self, forKey: .temperatureMax)
        temperatureMin = try ratingsContainer.decode(Double.self, forKey: .temperatureMin)
        day = try ratingsContainer.decode(Double.self, forKey: .day)
        weather = try container.decode([DailyWeather].self, forKey: .weather)
    }
}

struct DailyWeather: Decodable {
    let main: WeatherType
}

enum WeatherType: String, Decodable {
    case clouds = "Clouds"
    case snow = "Snow"
    case rain = "Rain"
    case clear = "Clear"
}
