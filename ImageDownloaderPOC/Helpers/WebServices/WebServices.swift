//
//  WebServices.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]
typealias JSONDictionaryArray = [JSONDictionary]
typealias FlickrApiResponse = (([FlickrImage], Int?, Int?, Error?) -> Void)

enum WebServices {
    
    enum WebServiceUrls: String {
        case baseUrl = "https://api.flickr.com/services/rest/"
    }
    
    enum Keys: String {
        case apiKey = "api_key"
        case method
        case searchText = "text"
        case extras
        case format
        case noJsonCallBack = "nojsoncallback"
        case photo
        case photos
        case page
        case pages
        case perPage = "perpage"
        case total
        case imgUrl = "url_m"
        case title
    }
    
    // Fetch images from flickr api
    static func getImages(using searchText: String, page: Int, _ completion: @escaping FlickrApiResponse) {
        
        let parameters: JSONDictionary = [
            Keys.method.rawValue: "flickr.photos.search",
            Keys.apiKey.rawValue: AppConstants.APIKeys.flickrApiKey.rawValue,
            Keys.searchText.rawValue: searchText,
            Keys.extras.rawValue: Keys.imgUrl.rawValue,
            Keys.format.rawValue: "json",
            Keys.noJsonCallBack.rawValue: 1,
            Keys.page.rawValue: page,
            ]
        
        guard let requestURL = getUrl(using: parameters, baseUrlString: WebServiceUrls.baseUrl.rawValue) else {
            
            let error = NSError(domain: K_GENERIC_ERROR_MSG.localized, code: 0, userInfo: nil)
            completion([], nil, nil, error)
            return
        }
        
        let session = URLSession.shared
        let request = URLRequest(url: requestURL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let err = error {
                completion([], nil, nil, err)
                return
            }
            
            let json: JSONDictionary?
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
            } catch let error  {
                print_debug(error.localizedDescription)
                json = nil
            }
            
            guard let imagesDict = json?[Keys.photos.rawValue] as? JSONDictionary,
                let imageJsonArray = imagesDict[Keys.photo.rawValue] as? JSONDictionaryArray else {
                    
                    completion([], nil, nil, nil)
                    return
            }
            
            let currentPage = (imagesDict[Keys.page.rawValue] as? Int) ?? page
            let noOfPages = (imagesDict[Keys.pages.rawValue] as? Int)
            let images = FlickrImage.models(from: imageJsonArray)
            completion(images, currentPage, noOfPages, nil)
        }
        
        task.resume()
    }
    
    // Creates request url using dictionary
    private static func getUrl(using dictionary: JSONDictionary, baseUrlString: String) -> URL? {
        
        guard let url = URL(string: baseUrlString),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
        }
        
        let queryItems = dictionary.map {
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
        
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
