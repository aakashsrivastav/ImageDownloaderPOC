//
//  ImageCollectionCell.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: CollectionView Cell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    // MARK: Private Methods
    
    // Method to reset cell to initial state
    private func reset() {
        imageView.image = #imageLiteral(resourceName: "ic_placeholder")
        imageView.contentMode = .center
    }
}
