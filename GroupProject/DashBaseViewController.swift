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

    // Floating button positioned like a clip over nagivation bar
    var floatingClipButton: SpiderButton!

    // Floating action buttons
    var floatingActionButtons: [UIButton] {
        // Default implementation returns empty list
        // Subclass need to override, if required
        return []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup floating button, if required
        let buttons = floatingActionButtons
        if buttons.count > 0 {
            // Frame position is hard set to mimic a clip over nav bar
            let floatingClipFrame = CGRect(x: view.bounds.size.width - 86, y: 32, width: 66, height: 66)
            floatingClipButton = SpiderButton(frame: floatingClipFrame, actionButtons:buttons)

            navigationController?.view.addSubview(floatingClipButton)
        }

        //self.HamburgerButton.transform = CGAffineTransform(scaleX: 1, y: 1)

        // Do any additional setup after loading the view.
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
    }
    
    @IBAction func openHamburgerMenu(_ sender: Any) {
        self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
        HamburgerViewController.sharedInstance.moveMenu()
    }
}
