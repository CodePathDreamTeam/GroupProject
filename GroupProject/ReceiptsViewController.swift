//
//  ReceiptsViewController.swift
//  GroupProject
//
//  Created by Nana on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Charts

class ReceiptsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var chartView: PieChartView!

    var sourceCurrency: String!
    var targetCurrency: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Chart View
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

        // Need to be replaced with remote API call
        setData(range: 5)

        // Animate and render chart
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutCirc)
    }

    func setData(range: Double) {

        var values = Array<PieChartDataEntry>()

        for i in 0..<ReceiptCategory.count {
            values.append(PieChartDataEntry(value: (Double(arc4random_uniform(UInt32(range))) + range/5), label: ReceiptCategory.categoryNames[i]))
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
        percentFormatter.percentSymbol = " %"

        data.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter))
        data.setValueFont(UIFont.systemFont(ofSize: 11.0))
        data.setValueTextColor(.black)

        chartView.data = data
        chartView.highlightValues(nil)
    }
}