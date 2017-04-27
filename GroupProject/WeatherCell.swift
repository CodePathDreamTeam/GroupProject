//
//  WeatherCell.swift
//  GroupProject
//
//  Created by Tran, Leland on 4/25/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var weatherForecast: WeatherForecast? {
        didSet {
            dayLabel.text = weatherForecast?.day
            conditionsLabel.text = weatherForecast?.conditions
            temperatureLabel.text = weatherForecast?.tempHigh
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
