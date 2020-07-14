//
//  StoreManager.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 15/07/20.
//  Copyright © 2020 Aakash Srivastav. All rights reserved.
//

import Foundation

final class StoreManager {
    
    private let kRecentSearch = "RecentSearch"
    
    static let shared = StoreManager()
    
    private init() {
        
    }
    
    func storeRecentSearch(_ text: String) {
        var recentSearchText = getReceneSearchTexts()
        recentSearchText.removeAll { searchText -> Bool in
            return (searchText == text)
        }
        recentSearchText.insert(text, at: 0)
        UserDefaults.standard.set(recentSearchText, forKey: kRecentSearch)
        UserDefaults.standard.synchronize()
    }
    
    func getReceneSearchTexts() -> [String] {
        if let searchTexts = UserDefaults.standard.array(forKey: kRecentSearch) as? [String] {
            return searchTexts
        }
        return []
    }
}
