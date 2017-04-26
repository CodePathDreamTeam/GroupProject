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
        WeatherClient.sharedInstance.getWeather(city: "LosAngeles", completionHandler: { (response) in
            print(response)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
