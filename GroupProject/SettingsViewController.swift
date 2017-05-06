//
//  SettingsViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/26/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var userPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults.standard
        if let savedName = userDefaults.string(forKey: "name") {
            nameTextField.text = savedName
        } else {
            nameTextField.text = ""
        }
        // Do any additional setup after loading the view.
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

    @IBAction func onEditingNameDidEnd(_ sender: Any) {
        let newName = nameTextField.text
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(newName, forKey: "name")
        userDefaults.synchronize()
        print("New saved Name: \(userDefaults.string(forKey: "name"))")
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(false)
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

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBAction func onUploadPhotoButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        photoImageView.image = editedImage
        print("got the image")
        
        self.update(photo: editedImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    func update(photo: UIImage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserPhoto")
        do {
            let fetchedPhotoData = try managedContext.fetch(fetchRequest)
            for photoData in fetchedPhotoData {
                managedContext.delete(photoData)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let contextUserPhoto = UserPhoto(context: managedContext)
        contextUserPhoto.photoImage  = (UIImagePNGRepresentation(photo)! as NSData)
        
        appDelegate.saveContext()
        print("appDelegate.saveContext() for userPhoto")

    }
    
    func loadFromCoreData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserPhoto")
        do {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchedPhotoData = try managedContext.fetch(fetchRequest)
            print(fetchedPhotoData.count)
            if let photoData = fetchedPhotoData[0] as? UserPhoto {
                if let userPhotoData = photoData.photoImage as? Data {
                    userPhoto = UIImage(data: userPhotoData)
                    photoImageView.image = userPhoto
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
