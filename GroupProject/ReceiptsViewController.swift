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

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        let trippinLogo = UIImage(named: "Trippin.png")
        let logoImage = UIImageView(image: trippinLogo)
        logoImage.frame.size.width = 78
        logoImage.frame.size.height = 23
        logoImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImage
        
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
        return receipts.count + 2 // To accomodate Header and Totals rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header")!
            return cell

        case (receipts.count + 1): // Totals row index
            let cell = tableView.dequeueReusableCell(withIdentifier: "Total")!

            let totalLabel = cell.viewWithTag(1) as? UILabel
            totalLabel?.text = String(format: "\(receipts.first?.nativeCurrencySign ?? "") %.2f \(receipts.first?.nativeCurrencyCode ?? "")", receipts.reduce(0){$0 + $1.nativeCurrencyAmount})

            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptInfo")!
            let receipt = receipts[indexPath.row - 1] // To account for header row

            let dateLabel = cell.viewWithTag(1) as? UILabel
            dateLabel?.text = dateFormatter.string(from: Date.init())

            let categoryLabel = cell.viewWithTag(2) as? UILabel
            categoryLabel?.text = receipt.category

            let amountInfoLabel = cell.viewWithTag(3) as? UILabel
            amountInfoLabel?.text = String(format: "\(receipt.nativeCurrencySign ?? "") %.2f \(receipt.nativeCurrencyCode ?? "")", receipt.nativeCurrencyAmount)

            return cell
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 60
        case receipts.count + 1:
            return 60
        default:
            return 30
        }
    }
}
