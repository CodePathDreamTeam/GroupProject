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
    var tempHigh: Int?
    var tempLow: Int?
    var conditions: String?
    var rawDictionary: NSDictionary?
    
    init(_ dictionary: NSDictionary){
        if let date = dictionary["date"] as? NSDictionary {
            day = date["weekday"] as? String
        }
        if let high = dictionary["high"] as? NSDictionary {
            tempHigh = high["fahrenheit"] as? Int
        }
        if let low = dictionary["low"] as? NSDictionary {
            tempLow = low["fahrenheit"] as? Int
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
