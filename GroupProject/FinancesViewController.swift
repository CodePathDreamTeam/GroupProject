//
//  FinancesViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class FinancesViewController: DashBaseViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var sourceCurrencyCodeLabel: UILabel!
    @IBOutlet weak var sourceCurrencyNameLabel: UILabel!
    @IBOutlet weak var sourceAmountField: UITextField!

    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var targetCurrencyCodeLabel: UILabel!
    @IBOutlet weak var targetCurrencyNameLabel: UILabel!
    @IBOutlet weak var targetAmountField: UITextField!

    // TODO: Temp outlet, to be removed.
    @IBOutlet weak var importTextLabel: UILabel!

    fileprivate var activityIndicator:UIActivityIndicatorView!

    fileprivate var currencyConverterTimer = Timer()
    fileprivate var currencyConverter: CurrencyConverter!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Setup source and target fields (right now its stubbed in the storyboard)
        currencyConverter = CurrencyConverter(localCurrencyCd: "USD", nativeCurrencyCd: "JPY")
        currencyConverter.updateCurrencyConversionFactors {[weak self] (result) in

            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.updateUI(isInteractive: false)
                } else {
                    // TODO: Throw UI alert
                    // Display UI alert, if needed...
                    print("error: \(String(describing: result.error?.localizedDescription))")
                }
            }
        }
    }

    // MARK: View Updates

    func updateUI(isInteractive: Bool) {

        switch currencyConverter.conversionMode {

        case .localToNative:
            sourceImageView.image = UIImage(named: currencyConverter.localCurrencyImage!)
            sourceCurrencyCodeLabel.text = currencyConverter.localCurrencyCode
            sourceCurrencyNameLabel.text = currencyConverter.localCurrencyName

            if isInteractive == false {
                sourceAmountField.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
            }

            targetImageView.image = UIImage(named: currencyConverter.nativeCurrencyImage!)
            targetCurrencyCodeLabel.text = currencyConverter.nativeCurrencyCode
            targetCurrencyNameLabel.text = currencyConverter.nativeCurrencyName
            targetAmountField.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)

        case .nativeToLocal:
            sourceImageView.image = UIImage(named: currencyConverter.nativeCurrencyImage!)
            sourceCurrencyCodeLabel.text = currencyConverter.nativeCurrencyCode
            sourceCurrencyNameLabel.text = currencyConverter.nativeCurrencyName

            if isInteractive == false {
                sourceAmountField.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
            }

            targetImageView.image = UIImage(named: currencyConverter.localCurrencyImage!)
            targetCurrencyCodeLabel.text = currencyConverter.localCurrencyCode
            targetCurrencyNameLabel.text = currencyConverter.localCurrencyName
            targetAmountField.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
        }
    }

    // MARK: Action Methods

    @IBAction func toggleSourceTargetCurrencies(_ sender: Any) {
        // Toggle the conversion mode
        currencyConverter.conversionMode.toggle()
        // Update the UI
        updateUI(isInteractive: false)
    }

    // UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField.text?.characters.count == 0 && string == "" {
            textField.text = "1"
        }

        if textField == sourceAmountField {
            currencyConverterTimer.invalidate()
            currencyConverterTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false, block: { (_) in
                if let sourceAmountStr = textField.text, let sourceAmount = Double(sourceAmountStr) {
                    DispatchQueue.main.async {
                        switch self.currencyConverter.conversionMode {
                        case .localToNative:
                            self.currencyConverter.localCurrencyAmount = sourceAmount
                        case .nativeToLocal:
                            self.currencyConverter.nativeCurrencyAmount = sourceAmount
                        }
                        self.updateUI(isInteractive: true)
                    }
                }
            })
            return true

        } else {
            return false
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HistoricalCurrencyView" {
            let destination = segue.destination as! ReceiptsViewController
            destination.sourceCurrency = "USD"
            destination.targetCurrency = "JPY"
        }
    }
}

extension FinancesViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scale(image: selectedPhoto, maxDimension: 640)

        addActivityIndicator()

        dismiss(animated:true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }

    // Import currency amounts for conversion
    @IBAction func importImage(_ sender: AnyObject) {
        view.endEditing(true)

        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .actionSheet)

        // Check for device compabtability before adding Camera button
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerActionSheet.addAction(UIAlertAction(title: "Take Photo",
                                                           style: .default) { (alert) -> Void in
                                                            let imagePicker = UIImagePickerController()
                                                            imagePicker.delegate = self
                                                            imagePicker.sourceType = .camera
                                                            self.present(imagePicker,animated: true,completion: nil)
            })
        }

        // Option to pick existing images
        imagePickerActionSheet.addAction(UIAlertAction(title: "Choose Existing",
                                                       style: .default) { (alert) -> Void in
                                                        let imagePicker = UIImagePickerController()
                                                        imagePicker.delegate = self
                                                        imagePicker.sourceType = .photoLibrary
                                                        self.present(imagePicker,animated: true,completion: nil)
        })

        // Option to cancel the import action
        imagePickerActionSheet.addAction(UIAlertAction(title: "Cancel",
                                                       style: .cancel) { (alert) -> Void in
        })

        present(imagePickerActionSheet, animated: true, completion: nil)
    }

    // Tesseract conversion of image to text
    func performImageRecognition(_ image: UIImage) {

        let tesseract = G8Tesseract()

        tesseract.language = "eng+fra"
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()

        tesseract.recognize()

        importTextLabel.text = tesseract.recognizedText
        removeActivityIndicator()
    }

    // Scaling image for better recognition
    func scale(image: UIImage, maxDimension: CGFloat) -> UIImage {

        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat

        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }

        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return scaledImage
    }

    // Activity Progress indicators while processing image
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }

    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
}
