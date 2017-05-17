//
//  MapCollectionViewCell.swift
//  GroupProject
//
//  Created by Brandon on 5/12/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class MapCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    
    func bind(country: (String, String)) {
        mapImage.image = UIImage(named: country.0)
        mapImage.asCircle()
        countryLabel.text = country.1
    }
}

extension UIImageView{
    
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 4;
        self.layer.masksToBounds = true
    }
    
}
