//
//  HomeViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class HomeViewController: DashBaseViewController, UIScrollViewDelegate, UITextFieldDelegate {

    // @VIEW OUTLETS
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
 
    
        // widgets:
    @IBOutlet weak var widgetCurrencyConverter: UIView!
    @IBOutlet weak var widgetOCR: UIView!
    @IBOutlet weak var hideKeyboardButton: UIButton!
    
    // @VIEW VARIABLES
    var widgetPage = [UIView]()
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var keyboardConstant: CGFloat?
    
    
    
    // @CURRENCY OUTLETS
    @IBOutlet weak var homeCurrencyTF: UITextField!
    @IBOutlet weak var destinationCurrencyTF: UITextField!
    @IBOutlet weak var homeCurrencyCd: UILabel!
    @IBOutlet weak var destinationCurrencyCd: UILabel!
    
    // @CURRENCY VARIABLES
    var rate: Double?
    var currencyConverter: CurrencyConverter!
    var currencyConverterTimer = Timer()
    
    
    // @WEATHER OUTLET
    @IBOutlet weak var weatherConditionsLabel: UILabel!
    @IBOutlet weak var weatherTemperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!


    
    
    
// @DAFAULT -----------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        /*FixerClient.shared.getCurrencyRate(for: "JPY", relativeTo: "USD") {[weak self] (result) in

            DispatchQueue.main.async {
                if result.isSuccess {
                    self?.rate = result.value
                    self?.homeCurrencyTF.text = "1"
                    self?.destinationCurrencyTF.text = "\(result.value!)"
                } else {
                    // Display UI alert, if needed...
                    print("error: \(String(describing: result.error?.localizedDescription))")
                }
            }
        }*/
        
        var latitude = defaults.string(forKey: "latitude")
        var longitude = defaults.string(forKey: "longitude")
        if latitude == nil || longitude == nil {
            print("Using default SF coordinates")
            latitude = "37.7749"
            longitude = "-122.4194"
        }
        print("coordinates: \(latitude), \(longitude)")
        WeatherClient.sharedInstance.getWeather(latitude: latitude!, longitude: longitude!, completionHandler: {
            response in DispatchQueue.main.async {
                if let error = response as? Error {
                    print("error: \(error)")
                }
                if let weather = response as? WeatherForecast {
                    print("weather.temp: \(weather.tempCurr)")
                    print("weather.conditions: \(weather.conditions)")
                    print("address: \(defaults.string(forKey: "address"))")
                    self.locationLabel.text = defaults.string(forKey: "address") ?? ""
                    self.weatherConditionsLabel.text = weather.conditions!
                    self.weatherTemperatureLabel.text = weather.tempCurr!
                }
            }
        })
        
        // Keyboard Settings
        hideKeyboardButton.alpha = 0
        keyboardConstant = bottomConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // ScrollView Settings
        scrollView.delegate = self
        
        widgetPage.append(widgetCurrencyConverter)
        widgetPage.append(widgetOCR)
        
        pageControl.numberOfPages = widgetPage.count
        
        for index in 0..<widgetPage.count
        {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            let view = UIView(frame: frame)
            view.addSubview(widgetPage[index])
            
            self.scrollView.addSubview(view)
        }
        
        scrollView.contentSize = CGSize(width: (scrollView.frame.size.width * CGFloat(widgetPage.count)), height: scrollView.frame.size.height)
        
        // collectionsview settings
        collectionView.delegate = self
        collectionView.dataSource = self
        

        
    }

    // @VIEW WILL APPEAR -------------------------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        if let nativeCurrency = User.sharedInstance.nativeCurrency, let nativeCountry = User.sharedInstance.nativeCountry, let destinationCurrency = User.sharedInstance.destinationCurrency, let destinationCountry = User.sharedInstance.destinationCountry {
            currencyConverter = CurrencyConverter(localCurrencyCd: destinationCurrency, localCountry: destinationCountry, nativeCurrencyCd: nativeCurrency, nativeCountry: nativeCountry)
            currencyConverter.updateCurrencyConversionFactors {(result) in
                DispatchQueue.main.async {
                    if result.isSuccess {
                        self.updateUI(isInteractive: false)
                    } else {
                        // Display UI alert, if needed...
                        print("error:  \(String(describing: result.error?.localizedDescription))")
                    }
                }
            }
        }
    }
    
    // @PREPARE FOR SEGUE -------------------------------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navigationController = segue.destination as? UINavigationController {
            if let settingsViewController = navigationController.topViewController as? SettingsViewController {
                settingsViewController.delegate = HamburgerViewController.sharedInstance.menuViewController as? SettingsViewControllerDelegate
            }
        }
        
    }
    
   
    
    // @FUNCTIONS -----------------------------------------------------------------------------------------
    
    // CURRENCY CONVERTER
    func updateUI(isInteractive: Bool) {
        
        switch currencyConverter.conversionMode {
            
        case .localToNative:
            
            destinationCurrencyTF.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
            destinationCurrencyCd.text = currencyConverter.localCurrencyCode
            
            homeCurrencyTF.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
            homeCurrencyCd.text = currencyConverter.nativeCurrencyCode
            
        case .nativeToLocal:
            
            destinationCurrencyTF.text = String(format: "%.2f", currencyConverter.nativeCurrencyAmount)
            destinationCurrencyCd.text = currencyConverter.nativeCurrencyCode
            
            homeCurrencyTF.text = String(format: "%.2f", currencyConverter.localCurrencyAmount)
            homeCurrencyCd.text = currencyConverter.localCurrencyCode
        }
    }

    
    // UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.characters.count == 0 && string == "" {
            textField.text = "1"
        }
        
        if textField == homeCurrencyTF {
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
    

    
    // KEYBOARD
    func keyboardWillShow(_ notification : Notification) {
        let value = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let rect = value.cgRectValue
        self.bottomConstraint.constant = rect.size.height
        hideKeyboardButton.alpha = 1
        
    }
    
    func keyboardWillHide(_ notification : Notification) {
        self.bottomConstraint.constant = keyboardConstant!
        hideKeyboardButton.alpha = 0
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
        
    }
    

    
    
    // SCROLLVIEW
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        
        
    }
    
    // PAGECONTROL
    @IBAction func pageChange(_ sender: UIPageControl) {
        
        let x = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.contentOffset = CGPoint(x: x, y: 0)
        
    }
    
    
    
}



extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // COLLECTIONVIEW CONFIG ------------------------------------------------------------------
    
    //Cell size (autolayout)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3.01, height: self.view.frame.size.width / 2)
        return size
        
    }
    
    
    // cell numb
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeLocationsCell", for: indexPath) as! HomeLocationsCell
        cell.locationImages.image = UIImage(named: "AdobeStock_40603639.jpeg")
        // create imageView in cell to show pictures
        //let posterImage = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        //cell.addSubview(posterImage)
        
        // LOAD IMAGES

    return cell
    }
    
}





