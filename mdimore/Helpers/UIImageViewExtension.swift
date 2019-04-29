//
//  UIImageView+URL.swift
//  GenericKit
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import UIKit

private var downloadingTaskHandle: UInt8 = 0

extension UIImageView {
    // Allows access to the DataTask inside the UIImageView extension so that cancel/suspend can be called later
    private var downloadingTask: URLSessionDownloadTask? {
        get {
            guard let task = objc_getAssociatedObject(self, &downloadingTaskHandle) as? URLSessionDownloadTask else { return nil }
            return task
        }
        
        set(value) {
            objc_setAssociatedObject(self,&downloadingTaskHandle, value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    struct ImageCache {
        static private var cache = NSCache<AnyObject, AnyObject>()
        static func image(forURL url: String) -> UIImage? {
            return cache.object(forKey: url as AnyObject) as? UIImage ?? nil
        }
        
        static func cacheImage(_ image: UIImage, forURL url: String) {
            cache.setObject(image, forKey: url as AnyObject)
        }
        static func clear() { cache.removeAllObjects() }
    }
    
    func loadFrom(url urlString: String, animated: Bool = true) {
        guard let url = URL(string: urlString) else { return }
        
        // fetch from cache...
        if let cachedImage = ImageCache.image(forURL: urlString) {
            setImage(cachedImage, animated: false)
            return
        }
        
        downloadingTask = ImageDownloader.downloadImage(with: url) { [weak self] (downloadedImage, error) in
            DispatchQueue.main.async {
                self?.downloadingTask = nil
                guard error == nil, let imageToCache = downloadedImage else {
                    self?.image = UIImage(named: "default-thumb")
                    print("error downloading Image... \(error!)")
                    return
                }
                
                ImageCache.cacheImage(imageToCache, forURL: urlString)
                self?.setImage(imageToCache, animated: animated)
            }
        }
    }
    
    func setImage(_ image: UIImage, animated: Bool = true) {
        self.alpha = animated ? 0.0 : 1.0
        UIView.animate(withDuration: animated ? 0.7 : 0.0) {
            self.image = image
            self.alpha = 1.0
        }
    }
    
    func cancelDownload() {
        guard let downloadingTask = self.downloadingTask else { return }
        self.downloadingTask = nil
        guard (downloadingTask.originalRequest?.url) != nil else { return }
        downloadingTask.suspend()
    }
}

