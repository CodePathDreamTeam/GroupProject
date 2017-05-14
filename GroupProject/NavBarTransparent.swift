//
//  NavBarTransparent.swift
//  GroupProject
//
//  Created by CRISTINA MACARAIG on 5/13/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class NavBarTransparent: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Customize Appearance
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationBar.tintColor = .white
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barStyle = .black
        self.navigationBar.isTranslucent = true
        

    }
    
}
