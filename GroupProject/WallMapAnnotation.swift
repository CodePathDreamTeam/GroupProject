//
//  WallMapAnnotation.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/27/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation
import MapKit

class WallMapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let item: ARItem
    
    init(location: CLLocationCoordinate2D, item: ARItem) {
        self.coordinate = location
        self.item = item
        self.title = item.itemDescription
        
        super.init()
    }
}
