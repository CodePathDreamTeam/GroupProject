

import UIKit
import MapKit
import CoreLocation

class WallMapViewController: DashBaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var targets = [ARItem]()
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var selectedAnnotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        setupLocations()
    }
    
    func setupLocations() {
        let firstTarget = ARItem(itemDescription: "wall", location: CLLocation(latitude: 34.180222, longitude: -118.311038), itemNode: nil)
        //let firstTarget = ARItem(itemDescription: "bridge", location: CLLocation(latitude: 34.159634, longitude: -118.333418), itemNode: nil)
        targets.append(firstTarget)
        
        //let secondTarget = ARItem(itemDescription: "wolf", location: CLLocation(latitude: 50.5184, longitude: 8.3895), itemNode: nil)
        //targets.append(secondTarget)
        
        //let thirdTarget = ARItem(itemDescription: "dragon", location: CLLocation(latitude: 50.5181, longitude: 8.3882), itemNode: nil)
        //targets.append(thirdTarget)
        
        for item in targets {
            let annotation = WallMapAnnotation(location: item.location.coordinate, item: item)
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension WallMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation.location
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = view.annotation!.coordinate
        
        if let userCoordinate = userLocation {
            if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) < 500 {
                let storyboard = UIStoryboard(name: "TheWall", bundle: nil)
                
                if let viewController = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? WallViewController {
                    
                    viewController.delegate = self
                    
                    if let mapAnnotation = view.annotation as? WallMapAnnotation {
                        
                        viewController.target = mapAnnotation.item
                        viewController.userLocation = mapView.userLocation.location!
                        selectedAnnotation = view.annotation
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
}

extension WallMapViewController: WallViewControllerDelegate {
    func viewController(controller: WallViewController, tappedTarget: ARItem) {
        self.dismiss(animated: true, completion: nil)
        let index = self.targets.index(where: {$0.itemDescription == tappedTarget.itemDescription})
        self.targets.remove(at: index!)
        
        if selectedAnnotation != nil {
            mapView.removeAnnotation(selectedAnnotation!)
        }
    }
}
