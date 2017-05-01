//
//  FullImageViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/30/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Photos
import AFNetworking

class FullImageViewController: UIViewController {
    
    var url = NSURL() // url = "assets-library://asset/asset.JPG?id=46811D66-DBB4-46D9-BBA2-0CF0D58FC7AD&ext=JPG" got it from another scene
    var asset = PHPhotoLibrary()
    var tempImage = UIImage()
    
    @IBOutlet weak var imgView: UIImageView!
    var imgURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  /*  func getUIImagefromAsseturl (url: NSURL) {
        
        asset. (url, resultBlock: { asset in
            if let ast = asset {
                let assetRep = ast.defaultRepresentation()
                let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                let image = UIImage(CGImage: iref)
                dispatch_async(dispatch_get_main_queue(), {
                    // ...Update UI with image here
                })
            }
        }, failureBlock: { error in
            print("Error: \(error)")
        })
    }*/
}
