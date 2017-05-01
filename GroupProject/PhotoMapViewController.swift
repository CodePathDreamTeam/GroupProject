//
//  PhotoMapViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import AssetsLibrary

class PhotoMapViewController: DashBaseViewController {
    
    var photos: [NSManagedObject] = []

    @IBOutlet var mapView: MKMapView!
    var myImage: UIImage!
    var imgURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        do {
            photos = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        mapView.delegate = self

        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openCameraButton(_ sender: UIBarButtonItem) {
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        let alert = UIAlertController(title: "Photo", message: "What would you like to do", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { action in
            vc.sourceType = .camera
            self.present(vc, animated: true, completion: nil)

        })
        
        alert.addAction(UIAlertAction(title: "Photo Roll", style: .default) { action in
            vc.allowsEditing = false
            vc.sourceType = .photoLibrary
            self.present(vc, animated: true, completion: nil)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Photos",
                                                in: managedContext)!
        
        let photo = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        photo.setValue(name, forKeyPath: "name")
        
        do {
            try managedContext.save()
            photos.append(photo)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       /* if segue.identifier == "tagSegue" {
            let vc = segue.destination as! LocationsViewController
            vc.delegate = self
        }*/
        if segue.identifier == "fullImageSegue" {
            let vc = segue.destination as! FullImageViewController
            vc.imgURL = imgURL
        }
    }
}



extension PhotoMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       /* if let imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL{
            let assetLibrary = ALAssetsLibrary()
            assetLibrary.asset(for: imageUrl as URL! , resultBlock: { (asset: ALAsset!) -> Void in
                if let actualAsset = asset as ALAsset? {
                    let assetRep: ALAssetRepresentation = actualAsset.defaultRepresentation()
                    let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    let image = UIImage(CGImage: iref)
                    let controller = CropViewController(image: image)
                    controller.delegate = self
                    picker.presentViewController(controller, animated: true, completion: nil)
                }
            }, failureBlock: { (error) -> Void in
            })
        }*/
        
        
        /*
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        //let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        print(imageURL)
        myImage = originalImage
        
        let annotation = PhotoAnnotation()

        //change to current location
        let locationCoordinate = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
        annotation.coordinate = locationCoordinate
        annotation.photo = myImage
        annotation.photoURL = imageURL
        mapView.addAnnotation(annotation)*/
        
        dismiss(animated: true, completion: nil)
    }
}



extension PhotoMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            annotationView?.isDraggable = true
            
        }
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        
//        let imageUrl = (annotation as? PhotoAnnotation)?.photoURL
//        
//        if let data = NSData(contentsOfURL: imageUrl as! URL) {
//            resizeRenderImageView.image = UIImage(data: data)
//        }
        
        resizeRenderImageView.image = myImage// setImageWith((annotation as? PhotoAnnotation)?.photoURL as! URL)
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = thumbnail
        annotationView?.image = thumbnail
        
        return annotationView
    }
            
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let photoAnnotation = view.annotation as! PhotoAnnotation
        
        myImage = photoAnnotation.photo
        imgURL = photoAnnotation.photoURL
        self.performSegue(withIdentifier: "fullImageSegue", sender: self)
    }
    
    func savePhoto(view: MKAnnotationView) {
        print(view.annotation?.coordinate.latitude)
        print(view.annotation?.coordinate.longitude)
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            savePhoto(view: view)
            view.dragState = .none
        default: break
        }
    }
}
