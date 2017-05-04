//
//  HomeViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class HomeViewController: DashBaseViewController {

    @IBOutlet weak var homeCurrencyTF: UITextField!
    @IBOutlet weak var destinationCurrencyTF: UITextField!
    @IBOutlet weak var weatherConditionsLabel: UILabel!
    @IBOutlet weak var weatherTemperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    var rate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FixerClient.shared.getCurrencyRate(for: "JPY", relativeTo: "USD") {[weak self] (result) in

            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.rate = result.value
                    self?.homeCurrencyTF.text = "1"
                    self?.destinationCurrencyTF.text = "\(result.value!)"
                } else {
                    // Display UI alert, if needed...
                    print("error: \(String(describing: result.error?.localizedDescription))")
                }
            }
        }
        
        let defaults = UserDefaults.standard
        var latitude = defaults.string(forKey: "latitude")
        var longitude = defaults.string(forKey: "longitude")
        if latitude == nil || longitude == nil {
            print("Using default SF coordinates")
            latitude = "37.7749"
            longitude = "-122.4194"
        }
        print("coordinates: \(latitude), \(longitude)")
        WeatherClient.sharedInstance.getWeather(latitude: latitude!, longitude: longitude!, completionHandler: {
            response in DispatchQueue.main.async {
                if let error = response as? Error {
                    print("error: \(error)")
                }
                if let weather = response as? WeatherForecast {
                    print("weather.temp: \(weather.tempCurr)")
                    print("weather.conditions: \(weather.conditions)")
                    print("address: \(defaults.string(forKey: "address"))")
                    self.locationLabel.text = defaults.string(forKey: "address") ?? ""
                    self.weatherConditionsLabel.text = weather.conditions!
                    self.weatherTemperatureLabel.text = weather.tempCurr!
                }
            }
        })
    }
}

extension HomeViewController: UITextFieldDelegate {
    
}
