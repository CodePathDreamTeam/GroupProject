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
    
    var nativeLocation: String?
    var destinationLocation: String?
    var latitude: Double?
    var longitude: Double?
    
    func updateUser() {
        nativeLocation = defaults.value(forKey: "nativeLocation") as! String?
        destinationLocation = defaults.value(forKey: "destinationLocation") as! String?
        latitude = defaults.value(forKey: "latitude") as! Double?
        longitude = defaults.value(forKey: "longitude") as! Double?
    }
}
