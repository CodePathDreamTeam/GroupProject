//
//  PoisViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PoisViewController: DashBaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    fileprivate var startedLoadingPOIs = false
    fileprivate var places = [Place]()
    
    fileprivate var arViewController: ARViewController!
    
    var distance = 500
    var type = "all"
    var search = ""
    var location = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func showARController(_ sender: Any) {
        arViewController = ARViewController()
        
        arViewController.dataSource = self
        
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        
        arViewController.setAnnotations(places)
        
        self.present(arViewController, animated: true, completion: nil)
    }
    
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        arViewController.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchBySegue" {
            let navigationController = segue.destination as! UINavigationController
            let psvc = navigationController.topViewController as! POISearchViewController
            psvc.delegate = self
        }
    }
    
    func populateMap(){
        
        places = []
        if !startedLoadingPOIs {
            startedLoadingPOIs = true
            
            let loader = PlacesLoader()
            loader.loadPOIS(location: location, radius: distance, type: type, keyword: search, completionHandler: {[weak self] (placesDict) in
                if let dict = placesDict.value {
                    guard let placesArray = dict.object(forKey: "results") as? [NSDictionary] else { return }
                    
                    for placeDict in placesArray {
                        let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                        let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                        let reference = placeDict.value(forKey: "reference") as! String
                        let name = placeDict.value(forKey: "name") as! String
                        let address = placeDict.value(forKey: "vicinity") as! String
                        
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        
                        let place = Place(location: location, reference: reference, name: name, address: address)
                        
                        self?.places.append(place)
                        
                        let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
                        
                        DispatchQueue.main.sync {
                            self?.mapView.addAnnotation(annotation)
                            self?.startedLoadingPOIs = false
                        }
                    }
                }
            })
        }
    }
}


extension PoisViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                populateMap()
            }
        }
    }
}

extension PoisViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension PoisViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        
        if let annotation = annotationView.annotation as? Place {
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: annotation) { [weak self] (resultDict)  in
                
                if let infoDict = resultDict.value?.object(forKey: "result") as? NSDictionary {
                    annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
                    annotation.website = infoDict.object(forKey: "website") as? String
                    
                    self?.showInfoView(forPlace: annotation)
                }
            }
        }
    }
}

extension PoisViewController: PoisViewControllerDelegate {
    func searchBy(distance: Int, type: String, search: String) {
        self.distance = distance
        self.type = type
        self.search = search
        let annotations = mapView.annotations
        self.mapView.removeAnnotations(annotations) 
        populateMap()
    }
}

