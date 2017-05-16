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
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsImageView: UIImageView!
    
    static var weatherIconMap: [String : UIImage]? {
        var iconMap = [String : UIImage]()
        iconMap["Clear"] = #imageLiteral(resourceName: "weathericon_sunny")
        iconMap["Partly Cloudy"] = #imageLiteral(resourceName: "weathericon_sunnycloudy")
        return iconMap
    }
    
    var weatherForecast: WeatherForecast? {
        didSet {
            dayLabel.text = weatherForecast?.day
            if let forecastConditions = weatherForecast?.conditions {
            conditionsImageView.image = WeatherCell.weatherIconMap?[forecastConditions]
            }
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
