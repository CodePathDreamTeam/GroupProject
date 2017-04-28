//
//  WriteOnWallViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/27/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class WriteOnWallViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
