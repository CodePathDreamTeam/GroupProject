//
//  FinancesViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class FinancesViewController: DashBaseViewController, UINavigationControllerDelegate, UITextFieldDelegate, ScrollableSegmentControlDelegate {

    @IBOutlet weak var localCurrencySignLabel: UILabel!
    @IBOutlet weak var localCountryNmLabel: UILabel!
    @IBOutlet weak var localAmountField: UITextField!

    @IBOutlet weak var nativeCurrencySignLabel: UILabel!
    @IBOutlet weak var nativeCountryNmLabel: UILabel!
    @IBOutlet weak var nativeAmountField: UITextField!

    @IBOutlet weak var pageControl: ScrollableSegmentControl!

    var receiptSource: ReceiptSource = .manual
    fileprivate var importedReceiptImageURL: URL?
    fileprivate var activityIndicator:UIActivityIndicatorView!

    fileprivate var currencyConverterTimer = Timer()
    fileprivate var currencyConverter: CurrencyConverter!

    // Setups up action buttons for adding receipts - Quick Import via Camera or Manually create receipt
    override var floatingActionButtons: [UIButton] {

        var buttons: [UIButton] = []

        let buttonFrame = CGRect(x: 0, y: 0, width: 66, height: 66)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let camera = UIButton(frame: buttonFrame)
            camera.addTarget(self, action: #selector(openCamera(_:)), for: .touchUpInside)
            camera.setImage(UIImage(named:"cbutton_camera"), for: .normal)
            camera.setImage(UIImage(named:"cbutton_camera-tap"), for: .highlighted)
            buttons.append(camera)
        }

        let photoLibrary = UIButton(frame: buttonFrame)
        photoLibrary.addTarget(self, action: #selector(openPhotoLibrary(_:)), for: .touchUpInside)
        photoLibrary.setImage(UIImage(named:"map"), for: .normal)
        photoLibrary.setImage(UIImage(named:"map"), for: .highlighted)
        buttons.append(photoLibrary)

        let manual = UIButton(frame: buttonFrame)
        manual.addTarget(self, action: #selector(createReceipt(_:)), for: .touchUpInside)
        manual.setImage(UIImage(named:"cbutton_pencil"), for: .normal)
        manual.setImage(UIImage(named:"cbutton_pencil-tap"), for: .highlighted)
        buttons.append(manual)

        return buttons
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup custom page control
        pageControl.segmentControlDelegate = self
        pageControl.segmentTitles = ["Expense Report","Denomination","Nearby Exchanges"]

        // Setup currency converter based on the user's current and native locations.
        let currentUser = User.sharedInstance
        setupCurrencyConverter(localCurrencyCd: currentUser.destinationCurrency ?? "USD", localCountry: currentUser.destinationCountry ?? "United States", nativeCurrencyCd: currentUser.nativeCurrency ?? "USD", nativeCountry: currentUser.nativeCountry ?? "United States")
    }

    // MARK: ScrollableSegmentControlDelegate

    func segmentControl(_ segmentControl: ScrollableSegmentControl, didSelectIndex index: Int) {
        // Do custom actions based on selected segment
    }

    // MARK: Model Setup

    func setupCurrencyConverter(localCurrencyCd: String, localCountry: String, nativeCurrencyCd: String, nativeCountry: String) {

        currencyConverter = CurrencyConverter(localCurrencyCd: localCurrencyCd, localCountry: localCountry, nativeCurrencyCd: nativeCurrencyCd, nativeCountry: nativeCountry)
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

        // When UI is updated as response to interactive user edits, do not reset the field thats edited...
        if isInteractive {
            switch currencyConverter.conversionMode {
            case .localToNative:
                nativeAmountField.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
            case .nativeToLocal:
                localAmountField.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
            }
        } else {
            localAmountField.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
            nativeAmountField.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
        }

        localCurrencySignLabel.text = currencyConverter.localCurrencySign
        localCountryNmLabel.text = currencyConverter.localCountry

        nativeCurrencySignLabel.text = currencyConverter.nativeCurrencySign
        nativeCountryNmLabel.text = currencyConverter.nativeCountry
    }

    // UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField.text?.characters.count == 0 && string == "" {
            textField.text = "1"
        }

        if textField == localAmountField {
            currencyConverter.conversionMode = .localToNative
        } else if textField == nativeAmountField {
            currencyConverter.conversionMode = .nativeToLocal
        } else {
            return false
        }

        currencyConverterTimer.invalidate()
        currencyConverterTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false, block: { (_) in
            if let newAmountStr = textField.text, let amountToConvert = Double(newAmountStr) {
                DispatchQueue.main.async {
                    switch self.currencyConverter.conversionMode {
                    case .localToNative:
                        self.currencyConverter.localCurrencyAmount = amountToConvert
                    case .nativeToLocal:
                        self.currencyConverter.nativeCurrencyAmount = amountToConvert
                    }
                    self.updateUI(isInteractive: true)
                }
            }
        })

        return true
    }

    // MARK: Navigation

    func createReceipt(_ sender: AnyObject) {
        DispatchQueue.main.async {
            // Track receipt source
            self.receiptSource = .manual
            // Perform segue to create receipt view
            self.performSegue(withIdentifier: "CreateReceiptView", sender: sender)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateReceiptView" {

            let destination = (segue.destination as! UINavigationController).topViewController as! CreateReceiptViewController

            destination.sourceType = receiptSource
            destination.source = currencyConverter
            destination.receiptImageURL = importedReceiptImageURL
        }
    }
}

extension FinancesViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        importedReceiptImageURL = info[UIImagePickerControllerReferenceURL] as? URL
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scale(image: selectedPhoto, maxDimension: 640)

        addActivityIndicator()

        dismiss(animated:true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }

    // Import receipt from camera
    func openCamera(_ sender: AnyObject) {
        // End editing to discard keyboards or input views, if any
        view.endEditing(true)

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker,animated: true,completion: nil)
    }

    func openPhotoLibrary(_ sender: AnyObject) {
        // End editing to discard keyboards or input views, if any
        view.endEditing(true)

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,animated: true,completion: nil)
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

        let importedText = tesseract.recognizedText
        print("Imported Text: \(importedText ?? "No text imported")")
        createReceipt(forImportedLocalAmount: 36.14, localCurrencyCd: "USD", localCountry: "United States", nativeCurrencyCd: "JPY", nativeCountry: "Japan")

        removeActivityIndicator()
    }

    func createReceipt(forImportedLocalAmount localCurrencyAmount: Double, localCurrencyCd: String, localCountry: String, nativeCurrencyCd: String, nativeCountry: String) {

        currencyConverter = CurrencyConverter(localCurrencyCd: localCurrencyCd, localCountry: localCountry, nativeCurrencyCd: nativeCurrencyCd, nativeCountry: nativeCountry, localCurrencyAmount: localCurrencyAmount)
        currencyConverter.updateCurrencyConversionFactors {[weak self] (result) in

            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.updateUI(isInteractive: false)
                    // Track receipt source
                    self?.receiptSource = .camera
                    // Initiate create new receipt segue
                    self?.performSegue(withIdentifier: "CreateReceiptView", sender: self)
                } else {
                    // TODO: Throw UI alert
                    // Display UI alert, if needed...
                    print("error: \(String(describing: result.error?.localizedDescription))")
                }
            }
        }
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
