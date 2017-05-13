//
//  User.swift
//  GroupProject
//
//  Created by Brandon on 5/9/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation


class User {
    
    static let sharedInstance = User()
    
    var nativeCountry: String?
    var destinationCountry: String?
    
    var nativeCurrency: String?
    var destinationCurrency: String?
    
    var latitude: Double?
    var longitude: Double?
    
    func updateUser() {
        
        nativeCountry = defaults.value(forKey: "nativeCountry") as! String?
        destinationCountry = defaults.value(forKey: "destinationCountry") as! String?
        
        nativeCurrency = defaults.value(forKey: "nativeCurrency") as! String?
        destinationCurrency = defaults.value(forKey: "destinationCurrency") as! String?
        
        latitude = defaults.value(forKey: "latitude") as! Double?
        longitude = defaults.value(forKey: "longitude") as! Double?
    }
}
