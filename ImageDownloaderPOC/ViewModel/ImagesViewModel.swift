//
//  ImagesViewModel.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 15/07/20.
//  Copyright © 2020 Aakash Srivastav. All rights reserved.
//

import Foundation

class ImagesViewModel {
    
    enum ApiState {
        case finished
        case ongoing
    }
    
    // MARK: Private Properties
    private var currentPage = 0
    private var totalPages = Int.max
    private var apiState = ApiState.finished
    private var searchString = ""
    
    // MARK: Public Properties
    var images: [FlickrImage] = []
    var itemsPerRow = 3
    var recentSearchTexts = [String]()
    
    var showMessage: ((String, String) -> Void)?
    var setImageAvailablilityIndicator: ((Bool) -> Void)?
    var scrollToTop: (() -> Void)?
    
    // Search images with search text
    func searchImages(with text: String) {
        guard searchString != text else {
            return
        }
        if !text.isEmpty {
            searchString = text
            currentPage = 0
            totalPages = Int.max
            getImages()
        }
    }
    
    // Refresh recent search texts from persistent store
    func refreshRecentSearches() {
        recentSearchTexts = StoreManager.shared.getReceneSearchTexts()
    }
    
    // Fetch images from api
    func getImages() {
        
        guard apiState != .ongoing, !searchString.isEmpty, currentPage < totalPages else {
            return
        }
        apiState = .ongoing
        let nextPage = (currentPage + 1)
        
        WebServices.getImages(using: searchString, page: nextPage) { [weak self] (images, page, totalPages, error) in
            
            guard let weakSelf = self else {
                return
            }
            weakSelf.apiState = .finished
            
            if let err = error {
                weakSelf.apiState = .finished
                weakSelf.showMessage?(K_GENERIC_ERROR.localized, err.localizedDescription)
                return
            }
            let shouldScrollToTop: Bool
            let shouldShowNoImageError: Bool
            
            if weakSelf.currentPage == 0 {
                shouldScrollToTop = true
                weakSelf.images.removeAll()
            } else {
                shouldScrollToTop = false
            }
            
            if let pg = page {
                weakSelf.currentPage = pg
            }
            if let tPages = totalPages {
                weakSelf.totalPages = tPages
            }
            if images.isEmpty {
                shouldShowNoImageError = true
            } else {
                shouldShowNoImageError = false
                weakSelf.images.append(contentsOf: images)
                StoreManager.shared.storeRecentSearch(weakSelf.searchString)
            }
            
            DispatchQueue.main.async {
                if totalPages == page || totalPages == 0 {
                    weakSelf.setImageAvailablilityIndicator?(false)
                } else {
                    weakSelf.setImageAvailablilityIndicator?(true)
                }
                if shouldShowNoImageError {
                    weakSelf.showMessage?(K_ERROR.localized, K_EMPTY_IMAGE_ERROR.localized)
                } else if shouldScrollToTop {
                    weakSelf.scrollToTop?()
                }
            }
        }
    }
    
    // Increase download priority of visible indices
    func increaseDownloadPriority(for indices: [Int]) {
        indices.forEach { index in
            let image = images[index] as FlickrImage
            image.downloadTask?.priority = URLSessionDataTask.highPriority
        }
    }
}
