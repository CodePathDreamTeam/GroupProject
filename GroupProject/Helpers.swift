//
//  Helpers.swift
//  GroupProject
//
//  Created by Brandon on 5/12/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation

class Helpers {
    class func setupGradient(view : UIView, topColor: UIColor, bottomColor: UIColor) {
        
        let gradientColors:[CGColor] = [topColor.cgColor, bottomColor.cgColor]
        
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
