//
//  ViewController.swift
//  iFunnyTV
//
//  Created by Andrey Mukhametov on 12/02/16.
//  Copyright © 2016 Fun.co. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift
import RxCocoa

class ImageCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var ImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

class ViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var flowCollectionView: UICollectionView!
    
    var contentItems:[Content] = []
    
    let reuseIdentifier = "ImageCollectionCell"
    
    var next: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CHTCollectionViewWaterfallLayout.init()
        
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        layout.columnCount = 3
        
        flowCollectionView.collectionViewLayout = layout
        
        flowCollectionView.backgroundColor  = UIColor.blackColor()
        
        flowCollectionView.panGestureRecognizer.allowedTouchTypes = [1]
        
    }
    
    func requestData(url: URLRequestConvertible) {

    }
    
    func contentForIndexPath(indexPath: NSIndexPath) -> Content {
        return contentItems[indexPath.row]
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let content =  contentForIndexPath(indexPath)
        return content.size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

