//
//  ReceiptsViewController.swift
//  GroupProject
//
//  Created by Nana on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class ReceiptsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var receipts = Array<Receipts>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sort receipts by their category in ascending order
        receipts = receipts.sorted(by: { (first, second) -> Bool in
            if let firstStr = first.category, let secondStr = second.category {
                return firstStr < secondStr
            } else {
                return true
            }
        })
        // Fetch saved receipts
        tableView.reloadData()
    }
}

extension ReceiptsViewController: UITableViewDataSource, UITableViewDelegate {

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let receipt = receipts[indexPath.row]

        cell.textLabel?.text = receipt.category
        cell.detailTextLabel?.text = String(format: "\(receipt.nativeCurrencySign ?? "$")%.2f", receipt.nativeCurrencyAmount)

        return cell
    }
}
