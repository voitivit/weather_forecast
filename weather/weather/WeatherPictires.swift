//
//  WeatherPictires.swift
//  weather
//
//  Created by emil kurbanov on 26.09.2023.
//

import UIKit

enum SemanticImage: String, CaseIterable {
    case snow = "snow"
    case clear = "clear"
    case clouds = "clouds"
    case rain = "rain"
}

extension SemanticImage {
    var image: UIImage? {
        return UIImage(named: self.rawValue)
    }
}
