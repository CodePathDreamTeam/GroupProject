//
//  WeatherStationViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class WeatherStationViewController: DashBaseViewController {

    var weatherForecasts: [WeatherForecast]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        WeatherClient.sharedInstance.getForecasts(city: "LosAngeles", country: "us") {
            (data, error) in
            if error != nil {
                print("error loading weather forecasts: \(error)")
            }
            if data != nil {
                print("In WeatherStationViewController - response: \(data!)")
                self.weatherForecasts = WeatherForecast.weatherForecastsWith(array: data?["list"] as! [NSDictionary])
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
