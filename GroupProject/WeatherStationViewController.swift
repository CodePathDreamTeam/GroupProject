//
//  WeatherStationViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class WeatherStationViewController: DashBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherForecasts: [WeatherForecast]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        var defaultsLatitude = defaults.string(forKey: "latitude")
        var defaultsLongitude = defaults.string(forKey: "longitude")
        if defaultsLatitude == nil || defaultsLongitude == nil {
            print("Using default SF coordinates")
            defaultsLatitude = "37.7749"
            defaultsLongitude = "-122.4194"
        }
        print("coordinates: \(defaultsLatitude), \(defaultsLongitude)")
        WeatherClient.sharedInstance.getForecast10Day(latitude: defaultsLatitude!, longitude: defaultsLongitude!,completionHandler: { (response) in
            DispatchQueue.main.async {
                if let weatherForecasts = response as? [WeatherForecast] {
                    self.weatherForecasts = weatherForecasts
                    print("it worked!")
                    if let location = defaults.string(forKey: "address") {
                        self.locationLabel.text = location
                    }
                    self.tableView.reloadData()
                }
            }
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
        cell.weatherForecast = weatherForecasts?[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
