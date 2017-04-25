//
//  FixerClient.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/23/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation

class FixerClient {
    
    let baseUrl = "https://api.fixer.io/latest?base="
    
    static let sharedInstance = FixerClient()
    
    func getJSON(home: String, destination: String, completionHandler: @escaping ((_ json: AnyObject) -> Void)) {
        let urlString = baseUrl + home
        let nsURL = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: nsURL, completionHandler: { data, response, error -> Void in
            if error != nil{
                completionHandler(error as AnyObject)
            }
            if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]
                //print(jsonData)
                if let rates = jsonData["rates"] as? [String:AnyObject] {
                    completionHandler(rates[destination]!)
                } else {
                //print(jsonData["Results"] as? NSDictionary[destination])
                completionHandler(1 as AnyObject)
                }
            }
            session.invalidateAndCancel()
        })
        task.resume()
    }
}

