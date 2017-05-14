
//
//  HomeLocationsCell.swift
//  GroupProject
//
//  Created by CRISTINA MACARAIG on 5/13/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class HomeLocationsCell: UICollectionViewCell {
    
    @IBOutlet weak var locationImages: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width
        
        locationImages.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 2)
        
    }
    
}
