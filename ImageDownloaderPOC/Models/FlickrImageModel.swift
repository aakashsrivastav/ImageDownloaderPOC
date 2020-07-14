//
//  FlickrImageModel.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import Foundation

final class FlickrImage {
    
    let url: URL
    let title: String
    var isDownloading: Bool
    var downloadTask: URLSessionDataTask?
    
    init?(with dictionary: JSONDictionary) {
        
        guard let urlString = dictionary[WebServices.Keys.imgUrl.rawValue] as? String,
            let imgUrl = URL(string: urlString) else {
                return nil
        }
        
        url = imgUrl
        title = (dictionary[WebServices.Keys.title.rawValue] as? String) ?? ""
        isDownloading = false
        downloadTask = nil
    }
    
    static func models(from array: JSONDictionaryArray) -> [FlickrImage] {
        
        let images: [FlickrImage] = array.map { dictionary -> FlickrImage? in
            
            if let image = FlickrImage(with: dictionary) {
                return image
            }
            return nil
            
            }.filter { (image) -> Bool in
                return (image != nil)
            }.map { (image) -> FlickrImage in
                return image!
        }
        return images
    }
}
