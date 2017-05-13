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
import Photos

class PhotoMapViewController: DashBaseViewController {
    
    var photos: [NSManagedObject] = []

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var myImage: UIImage!
    var imgURL: NSURL!
    
    var visibleAnnotations = [PhotoAnnotation]()
    
    // Setups up action buttons for adding receipts - Quick Import via Camera or Manually create receipt
    override var floatingActionButtons: [UIButton] {
        let buttonFrame = CGRect(x: 0, y: 0, width: 66, height: 66)
        
        let camera = UIButton(frame: buttonFrame)
        camera.addTarget(self, action: #selector(importImage(_:)), for: .touchUpInside)
        camera.setImage(UIImage(named:"cbutton_camera"), for: .normal)
        camera.setImage(UIImage(named:"cbutton_camera-tap"), for: .highlighted)
        
        let manual = UIButton(frame: buttonFrame)
        manual.addTarget(self, action: #selector(createReceipt(_:)), for: .touchUpInside)
        manual.setImage(UIImage(named:"cbutton_pencil"), for: .normal)
        manual.setImage(UIImage(named:"cbutton_pencil-tap"), for: .highlighted)
        
        return [camera, manual]
    }

    func createReceipt(_ sender: AnyObject) {
        print("ello")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFromCoreData()
        
        mapView.delegate = self
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
    }
    
    func importImage(_ sender: AnyObject) {
        // End editing to discard keyboards or input views, if any
        view.endEditing(true)
        
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .actionSheet)
        
        // Check for device compabtability before adding Camera button
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerActionSheet.addAction(UIAlertAction(title: "Take Photo",
                                                           style: .default) { (alert) -> Void in
                                                            let imagePicker = UIImagePickerController()
                                                            imagePicker.delegate = self
                                                            imagePicker.sourceType = .camera
                                                            self.present(imagePicker,animated: true,completion: nil)
            })
        }
        
        // Option to pick existing images
        imagePickerActionSheet.addAction(UIAlertAction(title: "Choose Existing",
                                                       style: .default) { (alert) -> Void in
                                                        let imagePicker = UIImagePickerController()
                                                        imagePicker.delegate = self
                                                        imagePicker.sourceType = .photoLibrary
                                                        self.present(imagePicker,animated: true,completion: nil)
        })
        
        // Option to cancel the import action
        imagePickerActionSheet.addAction(UIAlertAction(title: "Cancel",
                                                       style: .cancel) { (alert) -> Void in
        })
        
        present(imagePickerActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func segmentController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
            visibleAnnotations = mapView.visibleAnnotations()
            collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullImageSegue" {
            let vc = segue.destination as! FullImageViewController
            vc.imgURL = imgURL
        }
    }
    
    func loadFromCoreData() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        let result = Globals.fetch(request)

        if result.isSuccess {
            let photos = result.value!

            for photo in photos {

                let imageURL = photo.value(forKey: "photoURLString")
                print(imageURL)
                let annotation = PhotoAnnotation()

                let locationCoordinate = CLLocationCoordinate2D(latitude: photo.value(forKey: "photoLatitude") as! CLLocationDegrees,
                                                                longitude: photo.value(forKey: "photoLongitude") as! CLLocationDegrees)
                annotation.coordinate = locationCoordinate

                let assetURL = URL(string: imageURL as! String)

                if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL!], options: nil).firstObject {

                    PHImageManager.default().requestImage(for: asset,
                                                          targetSize: CGSize(width: 100, height: 100),
                                                          contentMode: .aspectFill,
                                                          options: nil,
                                                          resultHandler: { (result, info) ->Void in

                                                            self.myImage = result!

                                                            annotation.photo = result!
                    })
                }
                annotation.photoURL = NSURL(string: imageURL as! String)
                mapView.addAnnotation(annotation)
            }
        } else {
            print("PhotoMapViewController.loadFromCoreData Error: \(String(describing: result.error?.localizedDescription))")
        }
    }
}

extension PhotoMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let annotation = PhotoAnnotation()
        
        //change to current location
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
        annotation.coordinate = locationCoordinate
        let assetURL = imageURL as URL
        
        if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 1000, height: 1000),
                                                  contentMode: .aspectFill,
                                                  options: nil,
                                                  resultHandler: { (result, info) ->Void in
                
                self.myImage = result!
                
                annotation.photo = result!
            })
        }
        
        annotation.photoURL = imageURL
        savePhoto(view: annotation)
        mapView.addAnnotation(annotation)
        
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
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.infoDark)
            annotationView?.isDraggable = true
        }
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotationView?.image = thumbnail
        
        return annotationView
    }
            
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let photoAnnotation = view.annotation as! PhotoAnnotation
        
        myImage = photoAnnotation.photo
        imgURL = photoAnnotation.photoURL
        self.performSegue(withIdentifier: "fullImageSegue", sender: self)
    }
    
    func updatePhoto(view: PhotoAnnotation) {
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        let predicate = NSPredicate(format: "photoURLString = '\(view.photoURL.absoluteString!)'")
        request.predicate = predicate

        let result = Globals.fetch(request)

        if result.isSuccess {
            let test = result.value!

            if test.count == 1 {
                let objectUpdate = test[0]
                objectUpdate.setValue(view.coordinate.latitude, forKey: "photoLatitude")
                objectUpdate.setValue(view.coordinate.longitude, forKey: "photoLongitude")

                Globals.saveContext()
            }
        } else {
            print("PhotoMapViewController.loadFromCoreData Error: \(String(describing: result.error?.localizedDescription))")
        }
    }

    func savePhoto(view: PhotoAnnotation) {
        
        let photo = Photo(context: Globals.managedContext)
        photo.photoLatitude = view.coordinate.latitude
        photo.photoLongitude = view.coordinate.longitude
        photo.photoURLString = view.photoURL.absoluteString
        
        Globals.saveContext()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            updatePhoto(view: view.annotation as! PhotoAnnotation)
            view.dragState = .none
        default: break
        }
    }
}

extension PhotoMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        imgURL = visibleAnnotations[indexPath.row].photoURL
        self.performSegue(withIdentifier: "fullImageSegue", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoMapCollectionViewCell", for: indexPath) as! PhotoMapCollectionViewCell
        
        let photoURL = visibleAnnotations[indexPath.row].photoURL

        let assetURL = photoURL as! URL
        
        if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: cell.imageView.frame.maxX,
                                                                     height: cell.imageView.frame.maxY),
                                                  contentMode: .aspectFill,
                                                  options: nil,
                                                  resultHandler: { (result, info) ->Void in
                                                    
                                                    cell.imageView.image = result!

            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleAnnotations.count
    }
}

extension MKMapView {
    func visibleAnnotations() -> [PhotoAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> PhotoAnnotation in return obj as! PhotoAnnotation }
    }
}
