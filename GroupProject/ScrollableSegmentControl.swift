//
//  ScrollableSegmentControl.swift
//  GroupProject
//
//  Created by Nana on 5/13/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

protocol ScrollableSegmentControlDelegate: AnyObject {
    func segmentControl(_ segmentControl: ScrollableSegmentControl, didSelectIndex index: Int)
}

class ScrollableSegmentControl: UIScrollView {

    weak var segmentControlDelegate: ScrollableSegmentControlDelegate?

    var segmentTitles: [String] = ["Item 1", "Item 2"] {
        didSet {
            // Setup the "items"
            segmentControl.items = segmentTitles
            // Update the segment button frame
            let estimatedWidthUnit = 150
            let newWidth = estimatedWidthUnit * segmentTitles.count
            segmentControl.frame = CGRect(x: 0, y: 0, width: CGFloat(newWidth), height: frame.height)
            // reset scroll view's content size
            contentSize = segmentControl.frame.size
        }
    }

    private var segmentControl = CustomSegmentedControl(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSegmentControl()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSegmentControl()
    }

    func initSegmentControl() {

        // Setup custom page control
        let estimatedWidthUnit = 150
        let newWidth = estimatedWidthUnit * segmentTitles.count
        segmentControl.frame = CGRect(x: 0, y: 0, width: CGFloat(newWidth), height: frame.height)

        segmentControl.items = segmentTitles
        segmentControl.backColor = .white
        segmentControl.cornerRadius = 0
        segmentControl.bottomBorderEnabled = true
        segmentControl.highlightedLabelColor = .black
        segmentControl.unSelectedLabelColor = UIColor(colorLiteralRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        segmentControl.fontSize = 12.0
        segmentControl.radiusStyle = false
        segmentControl.flatStyle = true
        segmentControl.selectedLabelViewColor = .black
        segmentControl.selectedLabelBorderWidth = 0
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged(_:)), for: .valueChanged)

        // Setup scrollview attributes for page control
        contentSize = segmentControl.frame.size
        addSubview(segmentControl)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
    }

    func segmentControlValueChanged(_ segmentControl: CustomSegmentedControl){
        // Figure out the new rect to display based on selected index
        let labelWidthWithPadding: CGFloat = 200
        let index = segmentControl.selectedIndex
        let xPosition = CGFloat(index) * labelWidthWithPadding
        let rectToDisplay = CGRect(x: xPosition, y: 0, width: labelWidthWithPadding, height: frame.height)

        // Scroll to new rect
        scrollRectToVisible(rectToDisplay, animated: true)

        // Notify the delegate
        segmentControlDelegate?.segmentControl(self, didSelectIndex: index)
    }
}
