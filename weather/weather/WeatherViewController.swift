//
//  WeatherViewController.swift
//  weather
//
//  Created by emil kurbanov on 26.09.2023.
//

import UIKit

class WeatherViewController: UIViewController {

    private let service = WeatherService()
    private var nameCity: String = ""
    private var weatherCollection: Weather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadWeather()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalCentering
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.gray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var nameCities: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight(rawValue: 17))
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var weatherImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var date: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight(rawValue: 17))
        label.textAlignment = .center
        label.highlightedTextColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight(rawValue: 17))
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var temperatureMinMax: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(rawValue: 10))
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupConstraints() {
        [date, nameCities, weatherImage, temperatureLabel, temperatureMinMax].forEach {
            stackView.addArrangedSubview($0)
        }
        view.addSubview(stackView)
        setPlusButton()
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 2),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 2),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 2),
            
            date.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            
            nameCities.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 50),
            
            weatherImage.topAnchor.constraint(equalTo: nameCities.bottomAnchor, constant: 70),
            
            weatherImage.heightAnchor.constraint(equalToConstant: 120),
            weatherImage.widthAnchor.constraint(equalToConstant: 120),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 50),
            
            temperatureMinMax.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            
        ])
    }
    
    private func setPlusButton() {
        let button = UIButton(type: .custom)
        let buttonSize: CGFloat = 60
        button.frame = CGRect(x: (view.bounds.width - buttonSize) / 2, y: view.bounds.height - buttonSize - 20, width: buttonSize, height: buttonSize)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = buttonSize / 2
        button.setTitle("+", for: .normal)
        button.addTarget(self, action: #selector(showAddUserAlert), for: .touchUpInside)
        
        view.addSubview(button)
    }


    
    private func loadWeather() {
        service.loadWeathers(city: nameCity) { [weak self] result in
            switch result {
            case .success(let weather):
                DispatchQueue.main.async { [ weak self ] in
                    
                    guard let self = self else { return }
                    guard let data = weather.list.first?.date else { return }
                    guard let temperatureMax = weather.list.first?.temperatureMax else { return }
                    guard let temperatureMin = weather.list.first?.temperatureMin else { return }
                    guard let weatherDay = weather.list.first?.day else { return }
                    guard let weatherList = weather.list.first?.weather else { return }
                    
                    self.weatherCollection = weather
                    self.nameCities.text = weather.cityName
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateFormat = "d.MM.YYYY"
                    self.date.text = dateFormatter.string(from: data)
                    
                    let celsMax = String(format: "%0.1f" + "C", Double(temperatureMax) - 273)
                    let celsMin = String(format: "%0.1f" + "C", Double(temperatureMin) - 273)
                    let celsDay = String(format: "%0.1f" + "C", Double(weatherDay) - 273)
                    let minMaxLabelText = "min: \(celsMin)" + "/" + "max: \(celsMax)"
                    
                    self.temperatureMinMax.text = minMaxLabelText
                    self.temperatureLabel.text = celsDay
                    
                    weatherList.forEach { weather in
                        let iconName: UIImage?
                        switch weather.main {
                        case .clear:
                            iconName = SemanticImage.clear.image
                        case .clouds:
                            iconName = SemanticImage.clouds.image
                        case .rain:
                            iconName = SemanticImage.rain.image
                        case .snow:
                            iconName = SemanticImage.snow.image
                        }

                        if let icon = iconName {
                            self.weatherImage.image = icon
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc private func showAddUserAlert() {
        let alertController = UIAlertController(title: "Добавьте город", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Добавить", style: .default) { (_) in
            if let txtField = alertController.textFields?.first,
               let text = txtField.text {
                self.nameCity = text
                self.loadWeather()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { textField in
            textField.placeholder = "Добавьте город"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func backButtonTapped() {}
}




