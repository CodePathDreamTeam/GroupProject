//
//  HomeViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class HomeViewController: DashBaseViewController {

    @IBOutlet weak var homeCurrencyTF: UITextField!
    @IBOutlet weak var destinationCurrencyTF: UITextField!

    var rate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FixerClient.sharedInstance.getJSON(home: "USD", destination: "JPY", completionHandler: {
             rate in DispatchQueue.main.async {
                self.rate = rate as! Double
                self.homeCurrencyTF.text = "1"
                self.destinationCurrencyTF.text = "\(self.rate!)"
            }
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeViewController: UITextFieldDelegate {
    
}
