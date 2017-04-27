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

    var rate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FixerClient.sharedInstance.getRates(home: "USD", destination: "JPY", completionHandler: {
            rate in DispatchQueue.main.async {
//                self.rate = rate as! Double
//                self.homeCurrencyTF.text = "1"
//                self.destinationCurrencyTF.text = "\(self.rate!)"
            }
        })
        
        WeatherClient.sharedInstance.getWeather(city: "hardcoded for now", completionHandler: {
            weather in DispatchQueue.main.async {
                print(weather)
            }
        })
    }
}

extension HomeViewController: UITextFieldDelegate {
    
}
