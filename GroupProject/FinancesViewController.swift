//
//  FinancesViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Charts
import CoreData

class FinancesViewController: DashBaseViewController {

    // Currency converter outlets
    @IBOutlet weak var localCurrencySignLabel: UILabel!
    @IBOutlet weak var localCountryNmLabel: UILabel!
    @IBOutlet weak var localAmountField: UITextField!

    @IBOutlet weak var nativeCurrencySignLabel: UILabel!
    @IBOutlet weak var nativeCountryNmLabel: UILabel!
    @IBOutlet weak var nativeAmountField: UITextField!

    // Page view outlets
    @IBOutlet weak var pageControl: ScrollableSegmentControl!
    @IBOutlet weak var pageView: UICollectionView!

    // Receipt Chart, Table view outlets
    let receiptChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let viewReceiptsButton = UIButton(type: .roundedRect)

    // Create receipt
    var receiptSource: ReceiptSource = .manual
    fileprivate var importedReceiptImageURL: URL?
    fileprivate var activityIndicator:UIActivityIndicatorView!

    // Currency converter
    fileprivate var currencyConverterTimer = Timer()
    fileprivate var currencyConverter: CurrencyConverter!

    // Setup action buttons for adding receipts - Quick Import via Camera, Photo library or Manually create receipt
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

    // Receipts model
    var receipts = Array<Receipts>() {
        didSet {

            if receipts.count > 0 {

                var categorizedAmounts = Dictionary<String, Double>()

                receipts.forEach({ (element) in

                    if let category = element.category {
                        var totalAmount = element.nativeCurrencyAmount

                        if let currentAmount = categorizedAmounts[category] {
                            totalAmount =  currentAmount + totalAmount
                        }
                        categorizedAmounts.updateValue(totalAmount, forKey: category)
                    }
                })

                self.categorizedAmounts = categorizedAmounts
            }

            viewReceiptsButton.isHidden = (receipts.count == 0)
        }
    }

    fileprivate var categorizedAmounts = Dictionary<String, Double>() {
        didSet {
            DispatchQueue.main.async {
                // Setup chart data sets
                self.reloadChartData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        let trippinLogo = UIImage(named: "Trippin.png")
        let logoImage = UIImageView(image: trippinLogo)
        logoImage.frame.size.width = 78
        logoImage.frame.size.height = 23
        logoImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImage
        
        // Setup custom page control
        setupPageControl()
        // Setup page view
        setupPageView()
        // Setup currency converter
        setupCurrencyConverter()
        // Setup Chart View
        setupChartView()
        // Fetch saved receipts
        fetchReceipts()
        
        // SET BG GRADIENT
        let background = CAGradientLayer().creymeColor()
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, at: 0)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateReceiptView" {

            let destination = (segue.destination as! UINavigationController).topViewController as! CreateReceiptViewController

            destination.delegate = self
            destination.sourceType = receiptSource
            destination.source = currencyConverter
            destination.receiptImageURL = importedReceiptImageURL

        } else if segue.identifier == "ReceiptsView" {
            let destination = segue.destination as! ReceiptsViewController
            destination.receipts = receipts
        }
    }

    func viewReceipts(_ sender:AnyObject) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ReceiptsView", sender: sender)
        }
    }
}

/* This Extension Manages the following:
 — Sets up Currency Converter Model
 — Updates Currency Converter UI
 — Handles Currency Converter Interactions
 */
extension FinancesViewController: UITextFieldDelegate {

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

    // MARK: Model Setup

    func setupCurrencyConverter() {
        // Based on the user's current and native locations.
        let currentUser = User.sharedInstance

        currencyConverter = CurrencyConverter(localCurrencyCd: currentUser.destinationCurrency ?? "USD", localCountry: currentUser.destinationCountry ?? "United States", nativeCurrencyCd: currentUser.nativeCurrency ?? "USD", nativeCountry: currentUser.nativeCountry ?? "United States")
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
}

/* This Extension Manages the following:
 — Sets up Page view a.k.a Collection view
 — Handles Page scroll based on Segment Control selection
 */
extension FinancesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ScrollableSegmentControlDelegate {

    // MARK: View setup

    func setupPageControl() {
        pageControl.segmentControlDelegate = self
        pageControl.segmentTitles = ["Expense Report","Denomination","Nearby Exchanges"]
    }

    func setupPageView() {
        if let flowLayout = pageView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        pageView.isPagingEnabled = true
        pageView.isScrollEnabled = false
        pageView.allowsSelection = false
    }

    // MARK: ScrollableSegmentControlDelegate

    func segmentControl(_ segmentControl: ScrollableSegmentControl, didSelectIndex index: Int) {
        // Figure out the new page to display based on selected index
        let labelWidthWithPadding: CGFloat = pageView.frame.width
        let xPosition = CGFloat(index) * labelWidthWithPadding
        let rectToDisplay = CGRect(x: xPosition, y: 0, width: labelWidthWithPadding, height: pageView.frame.height)

        // Scroll to new rect
        pageView.scrollRectToVisible(rectToDisplay, animated: true)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        let colors: [UIColor] = [.white,.blue,.yellow]
        cellView.backgroundColor = colors[indexPath.row]

        if indexPath.row == 0 {
            // Add Chart as subview
            let chartViewDimension = min(collectionView.frame.width, collectionView.frame.height)
            receiptChartView.translatesAutoresizingMaskIntoConstraints = false
            cellView.addSubview(receiptChartView)
            // Add View Receipts button as subview
            viewReceiptsButton.setTitle("View Receipts", for: .normal)
            viewReceiptsButton.addTarget(self, action: #selector(viewReceipts(_:)), for: .touchUpInside)
            viewReceiptsButton.sizeToFit()
            viewReceiptsButton.translatesAutoresizingMaskIntoConstraints = false
            viewReceiptsButton.isHidden = (receipts.count == 0)
            cellView.addSubview(viewReceiptsButton)

            // Setup Constraints for chart view and view receipts button
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[chartView(width)]|", options: [], metrics: ["width":chartViewDimension], views: ["chartView":receiptChartView])
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[chartView(height)]-[viewReceiptsButton]", options: .alignAllCenterX, metrics: ["height":chartViewDimension], views: ["chartView":receiptChartView,"viewReceiptsButton":viewReceiptsButton]))

            cellView.addConstraints(constraints)
        }

        return cellView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

/* This Extension Manages the following:
 — Sets up Receipt Chart and Table View
 — Fetches Receipts from CoreData
 — Manages Chart and Table View Display
 */
extension FinancesViewController: ChartViewDelegate {

    // MARK: Fetch Receipts

    func fetchReceipts() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Receipts")
        let result = Globals.fetch(request)

        if result.isSuccess {
            receipts = result.value! as! Array<Receipts>
        } else {
            print("Error fetching receipts: \(String(describing: result.error?.localizedDescription))")
        }
    }

    // MARK: Chart View Stack

    func setupChartView() {
        receiptChartView.delegate = self

        let legend = receiptChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = false
        legend.xEntrySpace = 7.0
        legend.yEntrySpace = 0.0
        legend.yOffset = 0.0

        receiptChartView.entryLabelColor = .white
        receiptChartView.entryLabelFont = UIFont.systemFont(ofSize: 12.0)
        receiptChartView.chartDescription?.text = ""

        receiptChartView.noDataTextColor = UIColor(colorLiteralRed: 145/255.0, green: 145/255.0, blue: 145/255.0, alpha: 1.0)
        receiptChartView.noDataFont = UIFont.italicSystemFont(ofSize: 17.0)
        receiptChartView.noDataText = "You are yet to log expense receipts."
    }

    func reloadChartData() {

        var values = Array<PieChartDataEntry>()

        for key in categorizedAmounts.keys {
            values.append(PieChartDataEntry(value: categorizedAmounts[key]!, label: key))
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
        percentFormatter.percentSymbol = ""
        percentFormatter.positivePrefix = "\(currencyConverter.nativeCurrencySign)"

        data.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter))
        data.setValueFont(UIFont.systemFont(ofSize: 11.0))
        data.setValueTextColor(.black)

        receiptChartView.data = data
        receiptChartView.highlightValues(nil)

        // Animate and render chart
        receiptChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutCirc)
    }
}

/* This Extension Manages the following:
    — Receipt Imports from Camera/Photo Library
    — Parse the receipt text
    — Setup Currency Converter
    — Import the Receipt from Currency Converter model
 */
extension FinancesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        importedReceiptImageURL = info[UIImagePickerControllerReferenceURL] as? URL
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scale(image: selectedPhoto, maxDimension: 640)

        addActivityIndicator()

        dismiss(animated:true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }

    // MARK: Action Methods

    // Import receipt from camera
    func openCamera(_ sender: AnyObject) {
        // End editing to discard keyboards or input views, if any
        view.endEditing(true)

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker,animated: true,completion: nil)
    }

    // Import receipt from photo library
    func openPhotoLibrary(_ sender: AnyObject) {
        // End editing to discard keyboards or input views, if any
        view.endEditing(true)

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,animated: true,completion: nil)
    }

    // MARK: Tesseract Stack

    // Tesseract conversion of image to text
    func performImageRecognition(_ image: UIImage) {

        let tesseract = G8Tesseract()

        tesseract.language = "eng+fra"
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()

        tesseract.recognize()

        if let importedText = tesseract.recognizedText {
            print("Imported Text: \(importedText)")
            if let local = extractCurrencyDetails(from: importedText) {
                createReceipt(forImportedLocalAmount: local.amount, localCurrencyCd: local.currency, localCountry: local.country, nativeCurrencyCd: User.sharedInstance.nativeCurrency!, nativeCountry: User.sharedInstance.nativeCountry!)
            }
        }

        removeActivityIndicator()
    }

    // MARK: Helpers

    // Parse imported text and extract the local currency and amount
    func extractCurrencyDetails(from importText: String) -> (currency: String, country: String, amount: Double)? {

//        // Locate the range of first currency sign or code.
//        var rangeOfCurrencyIdentifier: Range<String.Index>? = nil
//        var currencyCode: String? = nil
//        var currencySign: String? = nil
//
//        for aCurrencyCode in [User.sharedInstance.destinationCurrency ?? "USD", User.sharedInstance.destinationCurrency ?? "USD"] {
//
//            let aCurrencySign = currencyCodeBasedTuple[aCurrencyCode]?.sign ?? "$"
//            rangeOfCurrencyIdentifier = importText.range(of: aCurrencySign, options: .caseInsensitive, range: nil, locale: nil)
//            if rangeOfCurrencyIdentifier == nil {
//                rangeOfCurrencyIdentifier = importText.range(of: aCurrencyCode, options: .caseInsensitive, range: nil, locale: nil)
//            }
//
//            if rangeOfCurrencyIdentifier != nil {
//                currencyCode = aCurrencyCode
//                currencySign = aCurrencySign
//                break
//            }
//        }
//
//        // If range is still empty, then imported text doesn't have any detectable local currency amounts
//        if rangeOfCurrencyIdentifier == nil || rangeOfCurrencyIdentifier?.isEmpty == true || currencyCode == nil || currencySign == nil {
//            return nil
//        } else {
//
//            // Extract the string following this range unless limited by characters other than numbers or dot (decimals)
//            var validCharacters = CharacterSet.decimalDigits
//            validCharacters.formUnion(.whitespaces)
//            let rangeOfAmount = importText.rangeOfCharacter(from: validCharacters, options: .literal, range: rangeOfCurrencyIdentifier)
//            print("rangeOfAmount: \(String(describing: rangeOfAmount))")
//
//            // Note: Dots aren't always the decimal separator, it depends on the currency locale but assuming for now.
//
//            // Extract Sign, Code, Country name from the extracted currency sign or code.
//
//            // Create a tuple to return. If any of required values are missing, return empty tuple.
//
//        }

        return ("USD", "United States", 12.35)
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

/* This Extension Manages the following:
    — Create Receipt Helper APIs
    — Refresh Receipts data post creation
 */
extension FinancesViewController: ReceiptDataSourceRefreshing {

    // MARK: ReceiptDataSourceRefreshing

    func receiptDidCreate(info: Receipts) {
        // Refresh View
        fetchReceipts()
    }

    // MARK: Receipt Creation

    func createReceipt(_ sender: AnyObject) {
        DispatchQueue.main.async {
            // Track receipt source
            self.receiptSource = .manual
            // Perform segue to create receipt view
            self.performSegue(withIdentifier: "CreateReceiptView", sender: sender)
        }
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
}
