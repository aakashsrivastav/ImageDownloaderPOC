//
//  ImageDownloader.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import UIKit

final class ImageDownloader {
    
    static let shared = ImageDownloader()
    let imageCache = NSCache<NSString, UIImage>()
    
    // Check and return if image already exists in cache and if not download it and return the downloaded image
    func downloadImage(at indexPath: IndexPath? = nil, image: FlickrImage, completion: @escaping (IndexPath?, UIImage?, Error?) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: image.url.absoluteString as NSString) {
            completion(indexPath, cachedImage, nil)
            
        } else {
            downloadDataForImage(image, completion: { (image, error) in
                completion(indexPath, image, error)
            })
        }
    }
    
    // Download image and return the downloaded image
    private func downloadDataForImage(_ image: FlickrImage, completion: @escaping ((UIImage, Error?) -> ())) {
        
        image.isDownloading = true
        
        let downloadTask = URLSession.shared.dataTask(with: image.url, completionHandler: { (data, response, error) in
            
            image.isDownloading = false
            image.downloadTask = nil
            
            if let error = error {
                print_debug(error)
                return
            }
            
            if data != nil {
                
                if let downloadedImage = UIImage(data: data!) {
                    self.imageCache.setObject(downloadedImage, forKey: image.url.absoluteString as NSString)
                    completion(downloadedImage, nil)
                    
                }
            }
        })
        
        downloadTask.priority = URLSessionDataTask.lowPriority
        image.downloadTask = downloadTask
        downloadTask.resume()
    }
}
