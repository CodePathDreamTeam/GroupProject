//
//  ReceiptsViewController.swift
//  GroupProject
//
//  Created by Nana on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ReceiptsViewController: UIViewController {
    
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!

    var receipts = Array<Receipts>() {
        didSet {

            if receipts.count > 0 {

                var categorizedAmounts = Dictionary<String, Double>()

                receipts.forEach({ (element) in

                    if let category = element.category {
                        var totalAmount = element.nativeCurrencyAmount

                        if let currentAmount = categorizedAmounts[category] {
                            totalAmount =  currentAmount + totalAmount
                        }
                        categorizedAmounts.updateValue(totalAmount, forKey: category)
                    }
                })

                self.categorizedAmounts = categorizedAmounts
            }

            // Reload receipts table view
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    fileprivate var categorizedAmounts = Dictionary<String, Double>() {
        didSet {
            DispatchQueue.main.async {
                // Setup chart data sets
                self.reloadChartData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Chart View
        setupChartView()

        // Fetch saved receipts
        let request = NSFetchRequest<NSManagedObject>(entityName: "Receipts")
        let result = Globals.fetch(request)

        if result.isSuccess {
            receipts = result.value! as! Array<Receipts>
        } else {
            print("Error fetching receipts: \(String(describing: result.error?.localizedDescription))")
        }
    }

}

extension ReceiptsViewController: ChartViewDelegate {

    // MARK: Chart View Stack

    func setupChartView() {
        chartView.delegate = self

        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = false
        legend.xEntrySpace = 7.0
        legend.yEntrySpace = 0.0
        legend.yOffset = 0.0

        chartView.entryLabelColor = .white
        chartView.entryLabelFont = UIFont.systemFont(ofSize: 12.0)
    }

    func reloadChartData() {

        var values = Array<PieChartDataEntry>()
        
        for key in categorizedAmounts.keys {
            values.append(PieChartDataEntry(value: categorizedAmounts[key]!, label: key))
        }

        let dataset = PieChartDataSet(values: values, label: "Trip Expenses")

        dataset.drawIconsEnabled = false
        dataset.sliceSpace = 2.0
        dataset.iconsOffset = CGPoint(x: 0, y: 40)

        let colors = NSMutableArray()
        colors.addObjects(from: ChartColorTemplates.vordiplom())
        colors.addObjects(from: ChartColorTemplates.joyful())
        colors.addObjects(from: ChartColorTemplates.colorful())
        colors.addObjects(from: ChartColorTemplates.liberty())
        colors.addObjects(from: ChartColorTemplates.pastel())
        colors.addObjects(from: [UIColor(red: 51/255, green:181/255, blue:229/255, alpha:1)])

        dataset.colors = colors as! [NSUIColor]

        let data = PieChartData(dataSet: dataset)

        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 1
        percentFormatter.multiplier = 1.0
        percentFormatter.percentSymbol = " JPY"

        data.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter))
        data.setValueFont(UIFont.systemFont(ofSize: 11.0))
        data.setValueTextColor(.black)
        
        chartView.data = data
        chartView.highlightValues(nil)

        // Animate and render chart
        self.chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutCirc)
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
        cell.detailTextLabel?.text = String(format: "%.2f \(receipt.nativeCurrencyCode!)", receipt.nativeCurrencyAmount)

        return cell
    }
}
