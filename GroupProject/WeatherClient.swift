//
//  WeatherClient.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/25/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation

class WeatherClient {
    
    let key = "c7b6d2a6854f038d"
    
    var baseURL = "https://api.wunderground.com/api/c7b6d2a6854f038d/forecast10day/q/"
    
    
    //"https://api.wunderground.com/api/c7b6d2a6854f038d/conditions/q/CA/"
    //"https://api.wunderground.com/api/c7b6d2a6854f038d/forecast10day/q/CA/San_Francisco.json"
    //"https://api.wunderground.com/api/c7b6d2a6854f038d/hourly10day/q/CA/San_Francisco.json"
    
    static let sharedInstance = WeatherClient()
    
    func getForecast10Day(latitude: String, longitude: String, completionHandler: @escaping((_ json: AnyObject) -> Void)) {
        let urlString = "\(baseURL)\(latitude),\(longitude).json"
        let nsURL = URL(string: urlString)!
        print("urlString: \(urlString)")
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            if error != nil{
                completionHandler(error as AnyObject)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
                print("\(jsonData)")
                if let jsonForecast = jsonData["forecast"] as? NSDictionary {
                    print(jsonForecast)
                    if let simpleForecast = jsonForecast["simpleforecast"] as? NSDictionary {
                        if let forecastDay = simpleForecast["forecastday"] as? [NSDictionary] {
                            let weatherForecasts = WeatherForecast.weatherForecastsWith(array: forecastDay)
                            completionHandler(weatherForecasts as AnyObject)
                        }
                    }
                }
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
    
    func getForecast10Day(city: String, completionHandler: @escaping ((_ json: AnyObject) -> Void)) {
        let city = "CA/San_Francisco"
        let baseURL = "https://api.wunderground.com/api/c7b6d2a6854f038d/forecast10day/q/CA/"
        let urlString = "\(baseURL)\(city).json"
        let nsURL = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            if error != nil{
                completionHandler(error as AnyObject)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
//                print(jsonData)
                
                if let jsonForecast = jsonData["forecast"] as? NSDictionary {
                    print(jsonForecast)
                    if let simpleForecast = jsonForecast["simpleforecast"] as? NSDictionary {
                        if let forecastDay = simpleForecast["forecastday"] as? [NSDictionary] {
                            let weatherForecasts = WeatherForecast.weatherForecastsWith(array: forecastDay)
                            completionHandler(weatherForecasts as AnyObject)
                        }
                    }
                }
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
    
    func getWeather(latitude: String, longitude: String, completionHandler: @escaping ((_ json: AnyObject) -> Void)) {
        let baseURL = "https://api.wunderground.com/api/c7b6d2a6854f038d/conditions/q/"
        let urlString = "\(baseURL)\(latitude),\(longitude).json"
        let nsURL = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            if error != nil{
                completionHandler(error as AnyObject)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
                print(jsonData)
                
                if let current = jsonData["current_observation"] as? [String:AnyObject] {
                    let temp = current["temp_f"] as? Int
                    let weather = current["weather"] as? String
                    if temp == nil || weather == nil {
                        print("temp or weather was nil")
                        completionHandler(error as AnyObject)
                    }
                    else {
                        completionHandler(WeatherForecast(temp: "\(temp!)", weather: weather!))
                    }
                    if let temp = current["temp_f"] as? String {
                        print(temp)
                        completionHandler(temp as AnyObject)
                    }
                }
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
    
    func getWeather(city: String, completionHandler: @escaping ((_ json: AnyObject) -> Void)) {
        let city = "San_Francisco"
        let urlString = "\(baseURL)\(city).json"
        let nsURL = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            if error != nil{
                completionHandler(error as AnyObject)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
                print(jsonData)

                if let current = jsonData["current_observation"] as? [String:AnyObject] {
                    if let temp = current["temp_f"] as? Int {
                        print(temp)
                        completionHandler(temp as AnyObject)
                    }
                }
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
    
    // 24HR WEATHER
    func getWeather24hours(city: String, completionHandler: @escaping ((_ json: AnyObject) -> Void)) {
        let city = "San_Francisco"
        let baseURL = "https://api.wunderground.com/api/c7b6d2a6854f038d/hourly/q/CA/"
        let urlString = "\(baseURL)\(city).json"
        let nsURL = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            if error != nil{
                completionHandler(error as AnyObject)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
                print("getWeather24hours\(jsonData)")
                if let jsonHourlyForecast = jsonData["hourly_forecast"] as? [NSDictionary] {
                    
                    let weatherForecasts = WeatherForecast.weatherForecastsWith(array: jsonHourlyForecast)
                    completionHandler(weatherForecasts as AnyObject)
                    
                }
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }

}
