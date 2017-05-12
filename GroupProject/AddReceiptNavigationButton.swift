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
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var pencilButton: UIButton!

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
        contentView.frame = CGRect(x:0, y: 22.0, width: bounds.size.width, height: bounds.size.height)
        backgroundView.layer.cornerRadius = 22.0

        addSubview(contentView)
    }

    @IBAction func addButtonClicked(_ sender: UIButton) {

            if self.backgroundView.transform == .identity {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.backgroundView.transform = CGAffineTransform(scaleX: 40, y: 40)
                    self.backgroundView.alpha = 0.85;
                    self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat((45 * Double.pi)/180))

                }, completion: { (_) in
                    UIView.animate(withDuration: 0.5, animations: { 
                        self.cameraButton.transform = CGAffineTransform(translationX: 0, y: 75)
                        self.cameraButton.alpha = 1.0
                        self.pencilButton.transform = CGAffineTransform(translationX: 0, y: 150)
                        self.pencilButton.alpha = 1.0
                    })
                })

            } else {

                UIView.animate(withDuration: 0.5, animations: {
                    self.cameraButton.transform = .identity
                    self.cameraButton.alpha = 0.0
                    self.pencilButton.transform = .identity
                    self.pencilButton.alpha = 0.0

                }, completion: { (_) in

                    UIView.animate(withDuration: 0.5, animations: { 
                        self.backgroundView.transform = .identity
                        self.backgroundView.alpha = 1.0
                        self.addButton.transform = .identity
                    })
                })
            }
    }

    @IBAction func cameraButtonClicked(_ sender: UIButton) {

    }

    @IBAction func manualButtonClicked(_ sender: UIButton) {

    }


}
