//
//  DashBaseViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class DashBaseViewController: UIViewController {
    
    @IBOutlet weak var HamburgerButton: HamburgerTwo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.HamburgerButton.transform = CGAffineTransform(scaleX: 2, y: 2)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openHamburgerMenuTest(_ sender: Any) {
        //self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
        HamburgerViewController.sharedInstance.moveMenu()

    }
    @IBAction func openHamburgerMenu(_ sender: UIBarButtonItem) {
        HamburgerViewController.sharedInstance.moveMenu()
    }
}
