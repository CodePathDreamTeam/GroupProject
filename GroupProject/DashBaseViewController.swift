//
//  DashBaseViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class DashBaseViewController: UIViewController {
    
    @IBOutlet weak var HamburgerButton: HamburgerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.HamburgerButton.transform = CGAffineTransform(scaleX: 1, y: 1)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
    }
    
    @IBAction func openHamburgerMenu(_ sender: Any) {
        self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
        HamburgerViewController.sharedInstance.moveMenu()
    }
}
