//
//  ViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/23/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoginButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChooseLocation", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        present(viewController!, animated: true, completion: nil)
    }

}

