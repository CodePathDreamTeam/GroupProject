//
//  FullImageViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/30/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Photos

class FullImageViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    var imgURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assetURL = imgURL as URL
        
        if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: imgView.frame.maxX, height: imgView.frame.maxY), contentMode: .aspectFill, options: nil, resultHandler: { (result, info) ->Void in
                self.imgView.image = result!
            })
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
