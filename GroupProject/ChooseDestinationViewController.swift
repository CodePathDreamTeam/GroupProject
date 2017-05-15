//
//  ChooseDestinationViewController.swift
//  GroupProject
//
//  Created by Tran, Leland on 5/15/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import GooglePlaces

protocol ChooseDestinationViewControllerDelegate {
    func chooseDestination(didChooseDestination: GMSPlace)
}

class ChooseDestinationViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var delegates = [ChooseDestinationViewControllerDelegate?]()

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: view.frame.width, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        if let homeNavController = HamburgerViewController.sharedInstance.contentViewController as? UINavigationController {
            if let homeViewController = homeNavController.topViewController as? HomeViewController {
                print("got home view controller")
                delegates.append(homeViewController)
            }
        }
        
        let menuViewController = HamburgerViewController.sharedInstance.menuViewController
        print("got menu view Controller")
        delegates.append(menuViewController)
        
    }
    @IBAction func onSetDestinationTap(_ sender: Any) {
        searchController?.isActive = true
        searchController?.searchBar.becomeFirstResponder()
        print("tapped set destination")
    }

    @IBAction func onSkipButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Setting Destination", message: "You can set your destination location at any time from the Settings page", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style:.default) {
            (action) in
            let presentingViewController = self.presentingViewController
            
            self.dismiss(animated: false, completion: {
                presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Handle the user's selection.
extension ChooseDestinationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        defaults.set("\(place.coordinate.latitude)", forKey: "latitude")
        defaults.set("\(place.coordinate.longitude)", forKey: "longitude")
        if let address = place.formattedAddress {
            defaults.setValue(address, forKey: "nativeLocation")
            defaults.set("\(address)", forKey: "address")
        }
        if let country = Helpers.getAddressComponent(["country"], for: place){
            defaults.setValue(country, forKey: "country")
        }
        if let city = Helpers.getAddressComponent(["neighborhood","locality","administrative_level_3"], for: place) {
            print("got city: \(city)")
            defaults.setValue(city, forKey: "city")
        }
        defaults.synchronize()
        
        for delegate in delegates {
            delegate?.chooseDestination(didChooseDestination: place)
        }
        
        let presentingViewController = self.presentingViewController
        
        self.dismiss(animated: false, completion: {
            presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
