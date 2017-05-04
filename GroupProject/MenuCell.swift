//
//  MenuCell.swift
//  GroupProject
//
//  Created by Tran, Leland on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
