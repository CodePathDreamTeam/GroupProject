//
//  PlaceLoader.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation
import CoreLocation

struct PlacesLoader {
    let apiURL = "https://maps.googleapis.com/maps/api/place/"
    let apiKey = "AIzaSyC11OQ4loHbjXLhOaQl-zXJWDPPGbLcgts"
    
    //https://maps.googleapis.com/maps/api/place/radarsearch/json?location=51.503186,-0.126446&radius=5000&type=museum&key=YOUR_API_KEY
    //https://maps.googleapis.com/maps/api/place/radarsearch/json?location=48.859294,2.347589&radius=5000&type=cafe&keyword=vegetarian&key=YOUR_API_KEY

    
    func loadPOIS(location: CLLocation, radius: Int = 30, completionHandler: @escaping ((Result<NSDictionary>) -> Void))  {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let uri = apiURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&sensor=true&types=establishment&key=\(apiKey)"
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completionHandler(Result.failure(APIError.ReasonableError(error.localizedDescription)))
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        guard let responseDict = responseObject as? NSDictionary else {
                            return
                        }
                        completionHandler(Result.success(responseDict))
                        
                    } catch let error as NSError {
                        completionHandler(Result.failure(APIError.ReasonableError(error.localizedDescription)))
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func loadDetailInformation(forPlace: Place, completionHandler: @escaping ((Result<NSDictionary>) -> Void)) {
        
        let uri = apiURL + "details/json?reference=\(forPlace.reference)&sensor=true&key=\(apiKey)"
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completionHandler(Result.failure(APIError.ReasonableError(error.localizedDescription)))
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        guard let responseDict = responseObject as? NSDictionary else {
                            return
                        }
                        completionHandler(Result.success(responseDict))//  responseDict, nil)
                        
                    } catch let error as NSError {
                        completionHandler(Result.failure(APIError.ReasonableError(error.localizedDescription)))
                    }
                }
            }
        }
        dataTask.resume()
    }
}
