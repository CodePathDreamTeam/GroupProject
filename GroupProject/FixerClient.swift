//
//  FixerClient.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/23/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation

class FixerClient {
    
    let latestCurrencyRatesUrl = "https://api.fixer.io/latest"
    
    static let shared = FixerClient()
    
    func getCurrencyRate(for target: String, relativeTo source: String, completionHandler: @escaping ((Result<Double>) -> Void)) {

        let urlStr = "\(latestCurrencyRatesUrl)?base=\(source)&symbols=\(target)"
        let url = URL(string: urlStr)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error -> Void in

            if error != nil {
                completionHandler(Result.failure(APIError.RemoteError(error?.localizedDescription)))

            } else if data != nil {
                let jsonData = (try! JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [String:Any]

                if let rates = jsonData["rates"] as? [String:AnyObject],
                    let targetRate = rates[target] as? Double {
                    completionHandler(Result.success(targetRate))
                } else {
                    completionHandler(Result.failure(APIError.InvalidData))
                }

            } else {
                completionHandler(Result.failure(APIError.DataUnavailable))
            }

            session.invalidateAndCancel()
        })
        task.resume()
    }
}

