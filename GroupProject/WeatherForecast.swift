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
    var tempCurr: String?
    var tempHigh: String?
    var tempLow: String?
    var conditions: String?
    var rawDictionary: NSDictionary?
    
    // hourly
    var hourlyWeatherTime = NSDictionary()
    var hourlyWeatherTemp = NSDictionary()
    
    var hour: String?
    var tempHour: String?
    var conditionHour: String?

    
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
        if let cond = dictionary["conditions"] as? String {
            conditions = cond
        }
        rawDictionary = dictionary
        
        // hourly
        hourlyWeatherTime = (dictionary["FCTTIME"] as? NSDictionary)!
        hour = hourlyWeatherTime.value(forKeyPath: "hour") as? String
        
        hourlyWeatherTemp = (dictionary["temp"] as? NSDictionary)!
        tempHour = hourlyWeatherTemp.value(forKeyPath: "english") as? String
        
        conditionHour = dictionary["condition"] as? String

    }
    
    init(temp: String, weather: String){
        tempCurr = temp
        conditions = weather
        
    }
    
    class func weatherForecastsWith(array: [NSDictionary]) -> [WeatherForecast]{
        var weatherForecasts = [WeatherForecast]()
        for dictionary in array {
            weatherForecasts.append(WeatherForecast(dictionary))
        }
        return weatherForecasts
    }
}
