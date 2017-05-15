//
//  FullImageCollectionViewController.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 5/13/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import Photos
import AnimatedCollectionViewLayout

class FullImageCollectionViewController: UICollectionViewController {
    
    var imageArray = [PhotoAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = AnimatedCollectionViewLayout()
        layout.animator = CubeAttributesAnimator()
        layout.scrollDirection = .horizontal
        collectionView?.collectionViewLayout = layout
    }
    
    @IBAction func onDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FullImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullImageCollectionViewCell", for: indexPath) as! FullImageCollectionViewCell
        
        let assetURL = imageArray[indexPath.row].photoURL as URL
        
        if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: cell.imageview.frame.maxX,
                                                                     height: cell.imageview.frame.maxY),
                                                  contentMode: .aspectFill,
                                                  options: nil,
                                                  resultHandler: { (result, info) ->Void in
                                                    cell.imageview.image = result!
            })
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height)
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
