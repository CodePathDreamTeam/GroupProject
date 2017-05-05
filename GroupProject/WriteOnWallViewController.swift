//
//  WriteOnWallViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/27/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Parse

class WriteOnWallViewController: UIViewController {
    
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages = [PFObject]()
    var currentLocation: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: currentLocation)
        query.includeKey("text")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground(){
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                
                self.messages = objects!
                self.tableView.reloadData()
                
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSendMessage(_ sender: UIButton) {
        if messageTF.text == "" {
            return
        }
        
        let message = PFObject(className: currentLocation)
        message["text"] = messageTF.text
        //message["user"] = PFUser.current()
        message["location"] = currentLocation
        message.saveInBackground {
            (success: Bool, error: Error?) -> Void in
            if (success) {
                print("save")
                // The object has been saved.
            } else {
                print("not saved")
                // There was a problem, check error.description
            }
        }
    }
}

extension WriteOnWallViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell")
        
        cell?.textLabel?.text = messages[indexPath.row]["text"] as! String
        if let user = messages[indexPath.row]["user"] as? String{
            cell?.detailTextLabel?.text = user
        }
        return cell!
    }
}
