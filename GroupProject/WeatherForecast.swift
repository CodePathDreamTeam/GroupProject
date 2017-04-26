//
//  WeatherForecast.swift
//  GroupProject
//
//  Created by Tran, Leland on 4/25/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class WeatherForecast: NSObject {

    var date: Int?
    var temperature: Double?
    var forecast: String?
    var rawDictionary: NSDictionary?
    
    init(_ dictionary: NSDictionary){
        date = dictionary["dt"] as? Int
        temperature = (dictionary["main"] as? NSDictionary)?["temp"] as? Double
        forecast = (dictionary["weather"] as? NSDictionary)?["main"] as? String
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
