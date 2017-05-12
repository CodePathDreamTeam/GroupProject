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
    var currencyConverter: CurrencyConverter!
    var currencyConverterTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyConverter = CurrencyConverter(localCurrencyCd: "USD", nativeCurrencyCd: "JPY")
        currencyConverter.updateCurrencyConversionFactors {(result) in
            DispatchQueue.main.async {
                if result.isSuccess {
                    self.updateUI(isInteractive: false)
                } else {
                    // Display UI alert, if needed...
                    print("error:  \(String(describing: result.error?.localizedDescription))")
                }
            }
        }

        /*FixerClient.shared.getCurrencyRate(for: "JPY", relativeTo: "USD") {[weak self] (result) in

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
        }*/
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navigationController = segue.destination as? UINavigationController {
            if let settingsViewController = navigationController.topViewController as? SettingsViewController {
                settingsViewController.delegate = HamburgerViewController.sharedInstance.menuViewController as? SettingsViewControllerDelegate
            }
        }
        
    }
    
    func updateUI(isInteractive: Bool) {
        
        switch currencyConverter.conversionMode {
            
        case .localToNative:
            //sourceImageView.image = UIImage(named: currencyConverter.localCurrencyImage!)
            //homeCurrencyTF.text = currencyConverter.localCurrencyCode
            //sourceCurrencyNameLabel.text = currencyConverter.localCurrencyName
            
            if isInteractive == false {
                homeCurrencyTF.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
            }
            
            //targetImageView.image = UIImage(named: currencyConverter.nativeCurrencyImage!)
            //targetCurrencyCodeLabel.text = currencyConverter.nativeCurrencyCode
            //targetCurrencyNameLabel.text = currencyConverter.nativeCurrencyName
            destinationCurrencyTF.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
            
        case .nativeToLocal:
            //sourceImageView.image = UIImage(named: currencyConverter.nativeCurrencyImage!)
            //sourceCurrencyCodeLabel.text = currencyConverter.nativeCurrencyCode
            //sourceCurrencyNameLabel.text = currencyConverter.nativeCurrencyName
            
            if isInteractive == false {
                homeCurrencyTF.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
            }
            
            //targetImageView.image = UIImage(named: currencyConverter.localCurrencyImage!)
            //targetCurrencyCodeLabel.text = currencyConverter.localCurrencyCode
            //targetCurrencyNameLabel.text = currencyConverter.localCurrencyName
            destinationCurrencyTF.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
        }
    }

}

extension HomeViewController: UITextFieldDelegate {
    
    
    
    // UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.characters.count == 0 && string == "" {
            textField.text = "1"
        }
        
        if textField == homeCurrencyTF {
            currencyConverterTimer.invalidate()
            currencyConverterTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false, block: { (_) in
                if let sourceAmountStr = textField.text, let sourceAmount = Double(sourceAmountStr) {
                    DispatchQueue.main.async {
                        switch self.currencyConverter.conversionMode {
                        case .localToNative:
                            self.currencyConverter.localCurrencyAmount = sourceAmount
                        case .nativeToLocal:
                            self.currencyConverter.nativeCurrencyAmount = sourceAmount
                        }
                        self.updateUI(isInteractive: true)
                    }
                }
            })
            return true
            
        } else {
            return false
        }
    }

    
}
