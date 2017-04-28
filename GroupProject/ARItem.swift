//
//  ARItem.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/27/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

struct ARItem {
    let itemDescription: String
    let location: CLLocation
    var itemNode: SCNNode?
}
