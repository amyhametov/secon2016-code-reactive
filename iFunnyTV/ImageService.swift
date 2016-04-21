//
//  ImageService.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif 

protocol ImageService {
    func imageFromURL(URL: NSURL) -> Observable<DownloadableImage>
}

let MB = 1024 * 1024

func apiError(error: String) -> NSError {
    return NSError(domain: "iFunnyAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
}

class DefaultImageService: ImageService {

    static let sharedImageService = DefaultImageService() // Singleton

    // 1st level cache
    private let _imageCache = NSCache()

    // 2nd level cache
    private let _imageDataCache = NSCache()

    var backgroundWorkScheduler:OperationQueueScheduler
    
    let URLSession = NSURLSession.sharedSession()
    
    private init() {
        
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        // cost is approx memory usage
        _imageDataCache.totalCostLimit = 50 * MB
        
        _imageCache.countLimit = 40
    }
    
    private func decodeImage(imageData: NSData) -> Observable<UIImage> {
        return Observable.just(imageData)
            .observeOn(backgroundWorkScheduler)
            .map { data in
                guard let image = UIImage(data: data) else {
                    // some error
                    throw apiError("Decoding image error")
                }
                return image
            }
    }
    
    private func _imageFromURL(URL: NSURL) -> Observable<UIImage> {
        return Observable.deferred {
                let maybeImage = self._imageCache.objectForKey(URL) as? UIImage

                let decodedImage: Observable<UIImage>
                
                // best case scenario, it's already decoded an in memory
                if let image = maybeImage {
                    decodedImage = Observable.just(image)
                }
                else {
                    let cachedData = self._imageDataCache.objectForKey(URL) as? NSData
                    
                    // does image data cache contain anything
                    if let cachedData = cachedData {
                        decodedImage = self.decodeImage(cachedData)
                    }
                    else {
                        // fetch from network
                        decodedImage = self.URLSession.rx_data(NSURLRequest(URL: URL))
                            .doOnNext { data in
                                self._imageDataCache.setObject(data, forKey: URL)
                            }
                            .flatMap(self.decodeImage)
                    }
                }
                
                return decodedImage.doOnNext { image in
                    self._imageCache.setObject(image, forKey: URL)
                }
            }
    }

    /**
    Service that tries to download image from URL.
     
    In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
    available.
     
    After image is sucessfully downloaded, sequence is completed.
    */
    func imageFromURL(URL: NSURL) -> Observable<DownloadableImage> {
        return _imageFromURL(URL)
                .map { DownloadableImage.Content(image: $0) }
                .startWith(.Content(image: UIImage()))
    }
}
