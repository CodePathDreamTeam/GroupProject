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
            addFloatingClip(for: buttons)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If floating clip button is needed and not part of the nav view hierarchy, add it.

        if floatingClipButton != nil &&
            navigationController != nil &&
            (floatingClipButton.isDescendant(of: navigationController!.view) == false) {
            
            addFloatingClip()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // If floating clip button is present, remove it from the nav view hierarchy before transitioning out
        if floatingClipButton != nil &&
            navigationController != nil &&
            floatingClipButton.isDescendant(of: navigationController!.view) {

            floatingClipButton.removeFromSuperview()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
    }
    
    @IBAction func openHamburgerMenu(_ sender: Any) {
        self.HamburgerButton.showsMenu = !self.HamburgerButton.showsMenu
        HamburgerViewController.sharedInstance.moveMenu()
    }

    func addFloatingClip(for buttons: [UIButton] = []) {
        // Frame position is hard set to mimic a clip over nav bar
        let floatingClipFrame = CGRect(x: view.bounds.size.width - 86, y: 60, width: 66, height: 66)

        if floatingClipButton == nil {
            floatingClipButton = SpiderButton(frame: floatingClipFrame, actionButtons:buttons)
        } else {
            floatingClipButton.frame = floatingClipFrame
        }
        // Add floating clip on nav controller's view
        navigationController?.view.addSubview(floatingClipButton)
    }
}
