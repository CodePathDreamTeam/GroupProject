//
//  ChooseLocationViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/24/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class ChooseLocationViewController: UIViewController {
    
    let countryTuple : [(String,String)] = [("AUD", "Australia"), ("BGN","Bulgaria"), ("BRL","Brazil"), ("CAD","Canada"),  ("CHF","Switzerland"), ("CNY","Chinese Yuan"), ("CZK","Czech Republic"), ("DKK","Denmark"), ("EUR","Euro"),  ("GBP","British Pound"), ("HKD","Hong Kong Dollar"), ("HRK","Croatia"), ("HUF","Hungary"), ("IDR","Indonesia"),  ("ILS","Israel"), ("INR","India"), ("JPY","Japan"), ("KRW","South Korea"), ("MXN","Mexico"), ("MYR","Malaysia"),  ("NOK","Norway"), ("NZD","New Zealand"), ("PHP","Philippines"), ("PLN","Poland"), ("RON","Romania"), ("RUB","Russia"),  ("SEK","Sweden"), ("SGD","Singapore"), ("THB","Thailand"), ("TRY","Turkey"), ("USD","United States"), ("ZAR","South Africa")]
    
    var nativeCountry = "Australia"
    var destinationCountry = "Australia"
    
    var nativeCurrency = "AUD"
    var destinationCurrency = "AUD"
    
    @IBOutlet weak var nativeCollectionView: UICollectionView!
    @IBOutlet weak var destinationCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nativeCollectionView?.isPagingEnabled = true
        //destinationCollectionView?.isPagingEnabled = true
        
        let nativeLayout = AnimatedCollectionViewLayout()
        nativeLayout.animator = LinearCardAttributesAnimator()
        nativeLayout.scrollDirection = .horizontal
        nativeCollectionView.collectionViewLayout = nativeLayout
        
        let destinationLayout = AnimatedCollectionViewLayout()
        destinationLayout.animator = LinearCardAttributesAnimator()
        destinationLayout.scrollDirection = .horizontal
        destinationCollectionView.collectionViewLayout = destinationLayout
    }
    
    @IBAction func onStartButton(_ sender: Any) {

        defaults.set(nativeCountry, forKey: "nativeCountry")
        defaults.set(destinationCountry, forKey: "destinationCountry")
        
        defaults.set(nativeCurrency, forKey: "nativeCurrency")
        defaults.set(destinationCurrency, forKey: "destinationCurrency")

        User.sharedInstance.updateUser()
    }
}


extension ChooseLocationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width);

        let randomRed = CGFloat(arc4random_uniform(256))
        let randomGreen = CGFloat(arc4random_uniform(256))
        let randomBlue = CGFloat(arc4random_uniform(256))
        
        if scrollView == self.nativeCollectionView {
            
            (self.view as? GradientView)?.startColor = UIColor(red:  randomRed/255.0, green: randomGreen/255.0, blue: randomBlue/255.0, alpha: 100.0/100.0)
            nativeCurrency = countryTuple[page].0
            nativeCountry = countryTuple[page].1
            print("Native - currency: \(nativeCurrency), country: \(nativeCountry)")
            
        } else if scrollView == self.destinationCollectionView {
            (self.view as? GradientView)?.endColor = UIColor(red:  randomRed/255.0, green: randomGreen/255.0, blue: randomBlue/255.0, alpha: 100.0/100.0)
            destinationCurrency = countryTuple[page].0
            destinationCountry = countryTuple[page].1
            print("Destination - currency: \(destinationCurrency), country: \(destinationCountry)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countryTuple.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCollectionViewCell", for: indexPath) as! MapCollectionViewCell
        cell.bind(country: countryTuple[indexPath.row])
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
