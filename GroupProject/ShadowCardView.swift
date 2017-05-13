//
//  ShadowCardView.swift
//  GroupProject
//
//  Created by Nana on 5/13/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class ShadowCardView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShadow()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
    }

    func setupShadow() {
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.8
    }
}
