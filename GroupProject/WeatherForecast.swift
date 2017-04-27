//
//  WeatherForecast.swift
//  GroupProject
//
//  Created by Tran, Leland on 4/25/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class WeatherForecast: NSObject {

    var day: String?
    var tempHigh: String?
    var tempLow: String?
    var conditions: String?
    var rawDictionary: NSDictionary?
    
    init(_ dictionary: NSDictionary){
        if let date = dictionary["date"] as? NSDictionary {
            day = date["weekday"] as? String
        }
        if let high = dictionary["high"] as? NSDictionary {
            tempHigh = high["fahrenheit"] as? String
        }
        if let low = dictionary["low"] as? NSDictionary {
            tempLow = low["fahrenheit"] as? String
        }
        conditions = dictionary["conditions"] as? String
        rawDictionary = dictionary
    }
    
    class func weatherForecastsWith(array: [NSDictionary]) -> [WeatherForecast]{
        var weatherForecasts = [WeatherForecast]()
        for dictionary in array {
            weatherForecasts.append(WeatherForecast(dictionary))
        }
        return weatherForecasts
    }
}
