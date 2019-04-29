//
//  ImageDownloader.swift
//  mdimore
//
//  Created by Michael Dimore on 4/30/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import UIKit

class ImageDownloader {
    static func downloadImage(with url: URL, completion: @escaping (UIImage?, Error?)->Void) -> URLSessionDownloadTask? {
        let task = URLSession.shared.downloadTask(with: url) { (path, response, error) in
            guard error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            guard let url = path, let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async { completion(nil, nil) }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async { completion(image, nil) }
        }
        task.resume()
        return task
    }
}
