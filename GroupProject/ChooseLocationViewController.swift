//
//  ChooseLocationViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import GooglePlaces

class ChooseLocationViewController: UIViewController {

    
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placesClient = GMSPlacesClient.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onStartButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Hamburger", bundle: nil)
        let hamburgerViewController = HamburgerViewController.sharedInstance
        
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController

        menuViewController.hamburgerViewController = hamburgerViewController
        hamburgerViewController.menuViewController = menuViewController
        
        present(hamburgerViewController, animated: true, completion: nil)

    }
    
    @IBAction func onChooseLocation(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }

}

extension ChooseLocationViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address:  \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinates: \(place.coordinate)")
        print("Place: \(place)")
        
        let defaults = UserDefaults.standard
        defaults.set("\(place.coordinate.latitude)", forKey: "latitude")
        defaults.set("\(place.coordinate.longitude)", forKey: "longitude")
        if let address = place.formattedAddress {
            defaults.set("\(address)", forKey: "address")
        }
        defaults.synchronize()
        dismiss(animated: true, completion: nil)
        print("defaults[latitude]: \(defaults.object(forKey: "latitude") as? String)")
        print("defaults[longitude]: \(defaults.object(forKey: "longitude") as? String)")
        print("defaults[address]: \(defaults.object(forKey: "address") as? String)")
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

