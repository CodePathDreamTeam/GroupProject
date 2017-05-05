//
//  HistoricalCurrencyViewController.swift
//  GroupProject
//
//  Created by Nana on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Charts

class HistoricalCurrencyViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var chartView: LineChartView!

    var sourceCurrency: String!
    var targetCurrency: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Chart View
        chartView.delegate = self
        chartView.setViewPortOffsets(left: 0, top: 20, right: 0, bottom: 0)
        chartView.backgroundColor = .white
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.maxHighlightDistance = 300.0
        chartView.xAxis.enabled = false

        let yAxis = chartView.leftAxis
        yAxis.labelFont = UIFont.boldSystemFont(ofSize: 12.0)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .black
        yAxis.labelPosition = .insideChart
        yAxis.drawGridLinesEnabled = false
        yAxis.axisLineColor = .black

        chartView.rightAxis.enabled = true
        chartView.legend.enabled = true

        // Need to be replaced with remote API call
        setData(count: 20, range: 5)

        chartView.animate(xAxisDuration: 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setData(count: Int, range: Double) {

        var yVals1 = Array<ChartDataEntry>()

        for i in 0..<count {
            let val = Double(arc4random_uniform(UInt32(range + 1))) + 20.0
            yVals1.append(ChartDataEntry(x: Double(i), y: val))
        }

        let set1: LineChartDataSet!

        if chartView.data != nil && chartView.data!.dataSetCount > 0 {
            set1 = chartView.data?.dataSets.first as! LineChartDataSet
            set1.values = yVals1
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = LineChartDataSet(values: yVals1, label: "DataSet 1")
            set1.mode = .linear
            set1.drawCirclesEnabled = true
            set1.drawValuesEnabled = true
            set1.lineWidth = 1.8
            set1.circleRadius = 4.0
            set1.setCircleColor(.black)
            set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
            set1.setColor(.black)
            set1.fillColor = .black
            set1.fillAlpha = 1.0
            set1.drawHorizontalHighlightIndicatorEnabled = false

            let data = LineChartData(dataSet: set1)
            data.setValueFont(UIFont.systemFont(ofSize: 9.0))
            data.setDrawValues(false)

            chartView.data = data
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
