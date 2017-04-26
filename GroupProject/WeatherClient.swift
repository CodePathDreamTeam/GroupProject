//
//  WeatherClient.swift
//  GroupProject
//
//  Created by Tran, Leland on 4/25/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation


class WeatherClient {
    let baseUrl = "https://api.openweathermap.org/data/2.5/forecast="
    let appId = "3f153638753dbd24a9e6b375ff22e2c2"
    
    static let sharedInstance = WeatherClient()
    
    func getForecasts(city: String, country: String, completionHandler: @escaping ((_ data: NSDictionary?, _ error: Error?) -> Void)) {
        let urlString = "\(baseUrl)\(city),\(country)&appId=\(appId)"
        let nsURL = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            print("request sent to \(urlString)")
            if error != nil{
                completionHandler(nil, error)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
                print(jsonData)
                completionHandler(jsonData as NSDictionary, nil)
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
    

}
