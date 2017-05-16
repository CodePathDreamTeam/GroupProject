//
//  SpiderButton.swift
//  GroupProject
//
//  Created by Nana on 5/10/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

// Why SpiderButton? It sprays the action buttons from its arm and weaves a web. You got it, just like Spider man. :)
class SpiderButton: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var addButton: UIButton!

    var actionButtons: [UIButton]!
    var image: UIImage! {
        didSet {
            if image != nil {
                addButton.setImage(image, for: .normal)
            }
        }
    }

    private var originalFrame = CGRect(x: 0, y: 0, width: 0, height: 0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, actionButtons: [UIButton]) {
        self.init(frame: frame)
        // Persist original frame
        self.originalFrame = frame
        // Hold the action buttons
        self.actionButtons = actionButtons
        // Setup the sub views from xib template
        initSubView()
    }

    func initSubView() {
        // Instantiate the xib template
        let contentViewNib = UINib(nibName: "SpiderButton", bundle: nil)
        contentViewNib.instantiate(withOwner: self, options: nil)

        // All outlets will be setup now.
        backgroundView.layer.cornerRadius = 22.0

        // Add the buttons beneath the
        actionButtons?.forEach { (button) in
            button.frame = addButton.frame
            button.clipsToBounds = true
            button.alpha = 0
            button.isUserInteractionEnabled = true
            button.addTarget(self, action: #selector(fallback), for: .touchUpInside)
            contentView.insertSubview(button, belowSubview: addButton)
        }

        //  Add content view to self and setup constraints
        let subViews = ["contentView": contentView!]
        var contentViewConstraints: [NSLayoutConstraint] = []
        contentViewConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[contentView]", options: [.alignAllTop], metrics: nil, views: subViews))
        contentViewConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[contentView]", options: [.alignAllTop], metrics: nil, views: subViews))

        addSubview(contentView)
        addConstraints(contentViewConstraints)
    }

    @IBAction func addButtonClicked(_ sender: UIButton) {

        // End superview editing, if any
        superview?.endEditing(true)

        if self.backgroundView.transform == .identity {
            // Extend the frame to support interaction with transformed action buttons
            let verticalPadding: CGFloat = 75.0
            let buttonsCount = CGFloat(actionButtons != nil ? actionButtons!.count : 0)
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: frame.size.height + (buttonsCount * verticalPadding)))

            // Animate and transform to dispaly action buttons
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: { 
                self.backgroundView.transform = CGAffineTransform(scaleX: 40, y: 40)
                self.backgroundView.alpha = 0.85;
                self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat((45 * Double.pi)/180))

            }, completion: { (_) in
                let verticalPadding: CGFloat = 75.0
                var buttonIndex: CGFloat = 0
                UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                    // Transform action buttons
                    self.actionButtons?.forEach({ (button) in
                        buttonIndex += 1
                        button.transform = CGAffineTransform(translationX: 0, y: buttonIndex * verticalPadding)
                        button.alpha = 1.0
                    })
                }, completion: nil)
            })
        } else {
            // Fallback to original states
            fallback()
        }
    }

    // This will be a convenience api to fallback all buttons to their respective original state
    func fallback() {

        UIView.animate(withDuration: 0.5, animations: {
            // Revert transforms on action buttons
            self.actionButtons?.forEach({ (button) in
                button.transform = .identity
                button.alpha = 0
            })
        }, completion: { (_) in

            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundView.transform = .identity
                self.backgroundView.alpha = 1.0
                self.addButton.transform = .identity
            }, completion: {(_) in
                self.frame = self.originalFrame
            })
        })
    }
}
