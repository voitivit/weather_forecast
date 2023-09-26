//
//  WeatherService.swift
//  weather
//
//  Created by emil kurbanov on 26.09.2023.
//

import UIKit
import Alamofire

final class WeatherService {

    func loadWeathers(city: String, completion: @escaping((Result<Weather, Error>) -> ())) {
        var urlcomponents = URLComponents()
        urlcomponents.scheme = "https"
        urlcomponents.host = "api.openweathermap.org"
        urlcomponents.path = "/data/2.5/forecast"
        urlcomponents.queryItems = [URLQueryItem(name: "q", value: city),
                                    URLQueryItem(name: "cnt", value: "3"),
                                    URLQueryItem(name: "appid", value: "018441804a8539ccd50064425268f7d9")
        ]

        guard let url = urlcomponents.url else { return }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
            }
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(Weather.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
