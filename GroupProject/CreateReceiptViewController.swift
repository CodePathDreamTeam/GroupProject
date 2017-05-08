//
//  CreateReceiptViewController.swift
//  GroupProject
//
//  Created by Nana on 5/7/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

enum ReceiptSource: Int {
    case camera
    case manual
}

class CreateReceiptViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var localAmountField: UITextField!
    @IBOutlet weak var localCurrencyCdLabel: UILabel!
    @IBOutlet weak var nativeAmountField: UITextField!
    @IBOutlet weak var nativeCurrencyCdLabel: UILabel!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var detailsImageView: UIImageView!

    var sourceType: ReceiptSource = .manual
    var source: CurrencyConverter?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let receiptSource = source {
            localAmountField.text = String(format: "%.2f", receiptSource.localCurrencyAmount)
            localCurrencyCdLabel.text = receiptSource.localCurrencyCode
            nativeAmountField.text = String(format: "%.2f", receiptSource.nativeCurrencyAmount)
            nativeCurrencyCdLabel.text = receiptSource.nativeCurrencyCode

            if sourceType == .manual {
                detailsImageView.isHidden = true
            } else {
                detailsTextView.isHidden = true
            }
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

    @IBAction func save(_ sender: Any) {
        // TODO: Save new receipt to core data persistent store
        // And then Dimiss view controller
        dismiss()
    }

    @IBAction func cancel(_ sender: Any) {
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
