//
//  CreateReceiptViewController.swift
//  GroupProject
//
//  Created by Nana on 5/7/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import AFNetworking
import Photos

enum ReceiptSource: Int {
    case camera
    case manual
}

protocol ReceiptDataSourceRefreshing: AnyObject {
    func receiptDidCreate(info: Receipts)
}

class CreateReceiptViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var localAmountCodeLabel: UILabel!
    @IBOutlet weak var localCurrencySignLabel: UILabel!
    @IBOutlet weak var nativeAmountCodeLabel: UILabel!
    @IBOutlet weak var nativeCurrencySignLabel: UILabel!
    @IBOutlet weak var receiptDescriptionField: UITextField!

    var sourceType: ReceiptSource = .manual
    var source: CurrencyConverter?
    var receiptImageURL: URL?

    weak var delegate: ReceiptDataSourceRefreshing?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        let trippinLogo = UIImage(named: "Trippin.png")
        let logoImage = UIImageView(image: trippinLogo)
        logoImage.frame.size.width = 78
        logoImage.frame.size.height = 23
        logoImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImage

        if let receiptSource = source {
            localAmountCodeLabel.text = String(format: "%.2f \(receiptSource.localCurrencyCode)", receiptSource.localCurrencyAmount)
            localCurrencySignLabel.text = receiptSource.localCurrencySign
            nativeAmountCodeLabel.text = String(format: "%.2f \(receiptSource.nativeCurrencyCode)", receiptSource.nativeCurrencyAmount)
            nativeCurrencySignLabel.text = receiptSource.nativeCurrencySign

            /*
            if sourceType == .manual {
                detailsImageView.isHidden = true
            } else {
                detailsTextView.isHidden = true
                if let assetUrl = receiptImageURL {
                    if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: nil).firstObject {

                        PHImageManager.default().requestImage(for: asset,
                                                              targetSize: CGSize(width: 200, height: 200),
                                                              contentMode: .aspectFill,
                                                              options: nil,
                                                              resultHandler: { (result, info) ->Void in
                                                                self.detailsImageView.image = result
                        })
                    }
                }
            } */
        }

        // Setup category picker view
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        categoryField.inputView = pickerView
        categoryField.text = ReceiptCategory.categoryNames.first
        categoryField.becomeFirstResponder()
    }

    // MARK: Action Methods

    @IBAction func save(_ sender: UIButton) {
        if source != nil {
            // Save new receipt to core data persistent store
            let newReceipt = Receipts(context: Globals.managedContext)
            newReceipt.localCurrencySign = source?.localCurrencySign
            newReceipt.localCurrencyCode = source?.localCurrencyCode
            newReceipt.localCurrencyAmount = source!.localCurrencyAmount
            newReceipt.nativeCurrencySign = source?.nativeCurrencySign
            newReceipt.nativeCurrencyCode = source?.nativeCurrencyCode
            newReceipt.nativeCurrencyAmount = source!.nativeCurrencyAmount
            newReceipt.category = categoryField.text
            newReceipt.receiptDescription = receiptDescriptionField.text

            Globals.saveContext()

            // Notify delegate for possible refresh
            delegate?.receiptDidCreate(info: newReceipt)
        }

        // And then Dimiss view controller
        dismiss()
    }

    @IBAction func cancel(_ sender: UIButton) {
        // Discard and dimiss view controller
        dismiss()
    }

    func dismiss() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    // UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ReceiptCategory.categoryNames.count
    }

    // UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ReceiptCategory.categoryNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryField.text = ReceiptCategory.categoryNames[row]
    }

    // UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false // Restrict user edits. Category should be chosen form picker view.
    }
}
