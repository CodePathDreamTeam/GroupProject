//
//  AddReceiptNavigationButton.swift
//  GroupProject
//
//  Created by Nana on 5/10/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

// Used only for Bar Button Item's custom view in Navigation Item
class AddReceiptNavigationButton: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cameraBackView: UIView!
    @IBOutlet weak var manualBackView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }

    func initSubView() {

        let contentViewNib = UINib(nibName: "AddReceiptNavigationButton", bundle: nil)
        contentViewNib.instantiate(withOwner: self, options: nil)

        // contentView outlet will be setup now.
        // Setup the frame such that the button hangs below nagivation bar and add the subview.
        contentView.frame = CGRect(x: 0, y: bounds.size.height / 2, width: bounds.size.width, height: bounds.size.height)
        backgroundView.layer.cornerRadius = 22.0
        cameraBackView.layer.cornerRadius = 22.0
        manualBackView.layer.cornerRadius = 22.0

        addSubview(contentView)
    }

    @IBAction func addButtonClicked(_ sender: UIButton) {

            if self.backgroundView.transform == .identity {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.backgroundView.transform = CGAffineTransform(scaleX: 40, y: 40)
                    self.backgroundView.alpha = 0.75

                }, completion: { (_) in
                    UIView.animate(withDuration: 0.5, animations: { 
                        self.cameraBackView.transform = CGAffineTransform(translationX: 0, y: 50)
                        self.cameraBackView.alpha = 1.0
                        self.manualBackView.transform = CGAffineTransform(translationX: 0, y: 100)
                        self.manualBackView.alpha = 1.0
                    })
                })

            } else {

                UIView.animate(withDuration: 0.5, animations: {
                    self.cameraBackView.transform = .identity
                    self.cameraBackView.alpha = 0.0
                    self.manualBackView.transform = .identity
                    self.manualBackView.alpha = 0.0

                }, completion: { (_) in

                    UIView.animate(withDuration: 0.5, animations: { 
                        self.backgroundView.transform = .identity
                        self.backgroundView.alpha = 1.0
                    })
                })
            }
    }

    @IBAction func cameraButtonClicked(_ sender: UIButton) {

    }

    @IBAction func manualButtonClicked(_ sender: UIButton) {

    }


}
