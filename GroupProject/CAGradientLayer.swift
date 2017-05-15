//
//  CAGradientLayer.swift
//  GroupProject
//
//  Created by CRISTINA MACARAIG on 5/14/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    func violetColor() -> CAGradientLayer {
        let topColor = UIColor.purple
        let bottomColor = UIColor(red: 111.0/255.0, green: 95.0/255.0, blue: 135.0/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        
        let gradientLayer : CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.50, y: 0.0)
        
        return gradientLayer
    }
    
    func creymeColor() -> CAGradientLayer {
        let topColor = UIColor(red: 188.0/255.0, green: 96.0/255.0, blue: 27.0/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 232.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        
        let gradientLayer : CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.50, y: 0.0)
        
        return gradientLayer
    }
    
}
