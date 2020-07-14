//
//  ImageDetailViewController.swift
//  ImageDownloaderPOC
//
//  Created by apple on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import UIKit

class ImageDetailViewController: BaseViewController {
    
    // MARK: Public Properties
    var images: [FlickrImage]!
    var selectedIndexPath: IndexPath!
    
    // MARK: Private Properties
    private var visibleImageCell: ImageCollectionCell? {
        if let cell = imageCollectionView.visibleCells.first as? ImageCollectionCell {
            return cell
        }
        return nil
    }
    private var onceOnly = false
    
    // MARK: IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    // MARK: View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: ImageCollectionCell.defaultReuseIdentifier, bundle: nil)
        imageCollectionView.register(nib, forCellWithReuseIdentifier: ImageCollectionCell.defaultReuseIdentifier)
        
        let image = images[selectedIndexPath.item]
        title = image.title
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.allowsSelection = false
    }
}

extension ImageDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.defaultReuseIdentifier, for: indexPath) as? ImageCollectionCell else {
            fatalError("Unable to initialize ImageCollectionCell")
        }
        return cell
    }
}

extension ImageDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if !onceOnly {
            imageCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            onceOnly = true
        }
        
        let image = images[indexPath.row]
        title = image.title
        if image.isDownloading {
            return
        }
        
        ImageDownloader.shared.downloadImage(at: indexPath, image: image, completion: { [weak self] (indexPath, image, error) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                if let idxPath = indexPath,
                    let cell = strongSelf.imageCollectionView.cellForItem(at: idxPath) as? ImageCollectionCell {
                    
                    if (error == nil) {
                        cell.imageView.image = image
                        cell.imageView.contentMode = .scaleAspectFit
                        
                    } else {
                        cell.imageView.image = #imageLiteral(resourceName: "PlaceHolderImage")
                        cell.imageView.contentMode = .center
                    }
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         images[indexPath.row].downloadTask?.priority = URLSessionDataTask.lowPriority
    }
}

extension ImageDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

// MARK: Scroll View Delegate Methods
extension ImageDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        increaseDownloadPriorityOfVisibleCells()
    }
    
    // Increase priority of download task for visible cells
    private func increaseDownloadPriorityOfVisibleCells() {
        
        imageCollectionView.visibleCells.forEach { cell in
            if let indexPath = imageCollectionView.indexPath(for: cell) {
                let image = images[indexPath.item] as FlickrImage
                image.downloadTask?.priority = URLSessionDataTask.highPriority
            }
        }
    }
}
