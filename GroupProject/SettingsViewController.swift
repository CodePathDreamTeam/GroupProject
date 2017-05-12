//
//  SettingsViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/26/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import CoreData
import GooglePlaces
import CoreLocation

protocol SettingsViewControllerDelegate {
    func settingsViewController(didUpdatePhoto: UIImage)
    func settingsViewController(didUpdateName: String)
    func settingsViewController(didUpdateLocation: GMSPlace)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var setLocationButton: UIButton!
    
    var placesClient: GMSPlacesClient!
    
    var userPhoto: UIImage?
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedName = defaults.string(forKey: "name") {
            nameTextField.text = savedName
        } else {
            nameTextField.text = ""
        }
        
        placesClient = GMSPlacesClient.shared()
        loadFromCoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSetLocationButton(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }

    @IBAction func onEditingNameDidEnd(_ sender: Any) {
        let newName = nameTextField.text
        defaults.setValue(newName, forKey: "name")
        defaults.synchronize()
        print("New saved Name: \(defaults.string(forKey: "name"))")
        delegate?.settingsViewController(didUpdateName: newName!)
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(false)
    }

}

extension SettingsViewController : GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address:  \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinates: \(place.coordinate)")
        print("Place: \(place)")
        
        defaults.set("\(place.coordinate.latitude)", forKey: "latitude")
        defaults.set("\(place.coordinate.longitude)", forKey: "longitude")
        if let address = place.formattedAddress {
            defaults.setValue(address, forKey: "nativeLocation")
            defaults.set("\(address)", forKey: "address")
        }
        defaults.synchronize()
        dismiss(animated: true, completion: nil)
        print("defaults[latitude]: \(defaults.object(forKey: "latitude") as? String)")
        print("defaults[longitude]: \(defaults.object(forKey: "longitude") as? String)")
        print("defaults[address]: \(defaults.object(forKey: "address") as? String)")
        delegate?.settingsViewController(didUpdateLocation: place)
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



extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBAction func onUploadPhotoButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        photoImageView.image = editedImage
        print("got the image")
        
        self.update(photo: editedImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    func update(photo: UIImage) {

        let request = NSFetchRequest<NSManagedObject>(entityName: "UserPhoto")
        let result = Globals.fetch(request)

        if result.isSuccess {
            let fetchedPhotoData = result.value!

            for photoData in fetchedPhotoData {
                Globals.managedContext.delete(photoData)
            }
        } else {
            print("PhotoMapViewController.loadFromCoreData Error: \(String(describing: result.error?.localizedDescription))")
        }

        let contextUserPhoto = UserPhoto(context: Globals.managedContext)
        contextUserPhoto.photoImage  = (UIImagePNGRepresentation(photo)! as NSData)
        
        Globals.saveContext()
        print("appDelegate.saveContext() for userPhoto")
        delegate?.settingsViewController(didUpdatePhoto: photo)

    }
    
    func loadFromCoreData() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "UserPhoto")
        let result = Globals.fetch(request)
        if result.isSuccess {

            let fetchedPhotoData = result.value!
            print(fetchedPhotoData.count)
            if let photoData = fetchedPhotoData.first as? UserPhoto {
                if let userPhotoData = photoData.photoImage as Data? {
                    userPhoto = UIImage(data: userPhotoData)
                    photoImageView.image = userPhoto
                }
            }
        } else {
            print("PhotoMapViewController.loadFromCoreData Error: \(String(describing: result.error?.localizedDescription))")
        }
    }
}
