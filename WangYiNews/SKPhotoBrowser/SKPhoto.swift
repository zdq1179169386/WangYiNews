//
//  SKPhoto.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

@objc public protocol SKPhotoProtocol: NSObjectProtocol {
    var underlyingImage: UIImage! { get }
    var caption: String! { get }
    var index: Int { get set}
    func loadUnderlyingImageAndNotify()
    func checkCache()
}

// MARK: - SKPhoto
public class SKPhoto: NSObject, SKPhotoProtocol {
    
    public var underlyingImage: UIImage!
    public var photoURL: String!
    public var shouldCachePhotoURLImage: Bool = false
    public var caption: String!
    public var index: Int = 0

    override init() {
        super.init()
    }
    
    convenience init(image: UIImage) {
        self.init()
        underlyingImage = image
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    public func checkCache() {
        if photoURL != nil && shouldCachePhotoURLImage {
            if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
                let request = NSURLRequest(URL: NSURL(string: photoURL)!)
                if let img = SKCache.sharedCache.imageForRequest(request) {
                    underlyingImage = img
                }
            } else {
                if let img = SKCache.sharedCache.imageForKey(photoURL) {
                    underlyingImage = img
                }
            }
        }
    }
    
    public func loadUnderlyingImageAndNotify() {
        
        if underlyingImage != nil && photoURL == nil {
            loadUnderlyingImageComplete()
        }
        
        if photoURL != nil {
            // Fetch Image
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            if let nsURL = NSURL(string: photoURL) {
                var task: NSURLSessionDataTask!
                task = session.dataTaskWithURL(nsURL, completionHandler: { [weak self](response: NSData?, data: NSURLResponse?, error: NSError?) in
                    if let _self = self {
                        
                        if error != nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                _self.loadUnderlyingImageComplete()
                            }
                        }
                        
                        if let res = response, let image = UIImage(data: res) {
                            if _self.shouldCachePhotoURLImage {
                                if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
                                    SKCache.sharedCache.setImageData(response!, response: data!, request: task.originalRequest!)
                                } else {
                                    SKCache.sharedCache.setImage(image, forKey: _self.photoURL)
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                _self.underlyingImage = image
                                _self.loadUnderlyingImageComplete()
                            }
                        }
                        session.finishTasksAndInvalidate()
                    }
                })
                task.resume()
            }
        }
    }

    public func loadUnderlyingImageComplete() {
        NSNotificationCenter.defaultCenter().postNotificationName(SKPHOTO_LOADING_DID_END_NOTIFICATION, object: self)
    }
    
}

// MARK: - Static Function

extension SKPhoto {
    public static func photoWithImage(image: UIImage) -> SKPhoto {
        return SKPhoto(image: image)
    }
    
    public static func photoWithImageURL(url: String) -> SKPhoto {
        return SKPhoto(url: url)
    }
    
    public static func photoWithImageURL(url: String, holder: UIImage?) -> SKPhoto {
        return SKPhoto(url: url, holder: holder)
    }
}
