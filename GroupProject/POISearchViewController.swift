//
//  POISearchViewController.swift
//  GroupProject
//
//  Created by Brandon on 5/8/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class POISearchViewController: UIViewController {
    
    var distances = ("25", ["25", "50", "150", "250", "500"])
    var types = ("all", ["all","accounting", "airport", "amusement_park", "aquarium", "art_gallery", "atm","bakery","bank","bar","beauty_salon","bicycle_store", "book_store", "bowling_alley", "bus_station", "cafe", "campground", "car_dealer", "car_rental", "car_repair", "car_wash", "casino", "cemetery", "church", "city_hall", "clothing_store", "convenience_store", "courthouse", "dentist", "department_store", "doctor", "electrician", "electronics_store", "embassy", "fire_station", "florist", "funeral_home", "furniture_store", "gas_station", "gym", "hair_care", "hardware_store", "hindu_temple", "home_goods_store", "hospital", "insurance_agency", "jewelry_store", "laundry","lawyer", "library", "liquor_store", "local_government_office", "locksmith", "lodging", "meal_delivery", "meal_takeaway", "mosque", "movie_rental", "movie_theater", "moving_company", "museum", "night_club", "painter", "park", "parking", "pet_store", "pharmacy", "physiotherapist", "plumber", "police", "post_office", "real_estate_agency", "restaurant", "roofing_contractor", "rv_park", "school", "shoe_store", "shopping_mall", "spa", "stadium", "storage", "store", "subway_station", "synagogue", "taxi_stand", "train_station", "transit_station", "travel_agency", "university", "veterinary_care", "zoo"])

    var filtersArray = [Filter]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersArray.append(Filter(chosenValue: "Distance(meters)", values: distances, isExpanded: false))
        filtersArray.append(Filter(chosenValue: "Type", values: types, isExpanded: false))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onSearchbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension POISearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return filtersArray[section].chosenValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersArray[section].isExpanded ? filtersArray[section].values.1.count : 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filtersArray[indexPath.section].isExpanded = !filtersArray[indexPath.section].isExpanded
        tableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell")
        if filtersArray[indexPath.section].isExpanded {
            cell?.textLabel?.text = filtersArray[indexPath.section].values.1[indexPath.row]
        } else {
            cell?.textLabel?.text = filtersArray[indexPath.section].values.0
        }
        return cell!
    }
}

extension POISearchViewController: UISearchBarDelegate {
    
}

class Filter {
    
    var chosenValue: String
    var values: (String, [String])
    var isExpanded : Bool
    
    init(chosenValue: String, values: (String, [String]), isExpanded: Bool) {
        self.chosenValue = chosenValue
        self.values = values
        self.isExpanded = isExpanded
    }
}

