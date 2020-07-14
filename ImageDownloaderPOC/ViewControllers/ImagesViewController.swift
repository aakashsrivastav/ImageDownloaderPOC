//
//  ImagesViewController.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import UIKit

class ImagesViewController: BaseViewController {

    enum ApiState {
        case finished
        case ongoing
    }
    
    // MARK: Private Properties
    private let viewModel = ImagesViewModel()
    private lazy var imageSearchBar = UISearchBar()
    private let sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.style = .whiteLarge
        indicatorView.color = .black
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    private var selectedImageCell: ImageCollectionCell? {
        if let selectedIndices = imageCollectionView.indexPathsForSelectedItems,
            let selectedIndex = selectedIndices.first,
            let cell = imageCollectionView.cellForItem(at: selectedIndex) as? ImageCollectionCell {
            return cell
        }
        return nil
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var recentSearchTableView: UITableView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    // MARK: View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.refreshRecentSearches()
        
        setupNavBar()
        setupViews()
        setupBindings()
    }
    
    // MARK: Private Methods
    private func setupViews() {
        recentSearchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentSearchTableCell")
        recentSearchTableView.dataSource = self
        recentSearchTableView.delegate = self
        recentSearchTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: ImageCollectionCell.defaultReuseIdentifier, bundle: nil)
        imageCollectionView.register(nib, forCellWithReuseIdentifier: ImageCollectionCell.defaultReuseIdentifier)
        imageCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerView")
        
        imageCollectionView.allowsMultipleSelection = false
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
    }
    
    private func setupNavBar() {
        
        imageSearchBar.delegate = self
        imageSearchBar.placeholder = K_SEARCH_PLACEHOLDER.localized
        
        navigationItem.titleView = imageSearchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: K_GRID_SIZE.localized, style: .plain, target: self, action: #selector(rightNavBarBtnTapped))
    }
    
    @objc private func rightNavBarBtnTapped(_ sender: UIBarButtonItem) {
        showAlertToChooseGridSize()
    }
    
    private func setupBindings() {
        
        viewModel.showMessage = { [weak self] (title, description) in
            if let weakSelf = self {
                weakSelf.showAlert(with: title, message: description)
            }
        }
        
        viewModel.setImageAvailablilityIndicator = { [weak self] (animate) in
            if let weakSelf = self {
                if animate {
                    weakSelf.activityIndicatorView.startAnimating()
                } else {
                    weakSelf.activityIndicatorView.stopAnimating()
                }
                weakSelf.imageCollectionView.reloadData()
            }
        }
        
        viewModel.scrollToTop = { [weak self] in
            if let weakSelf = self {
                weakSelf.imageCollectionView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    private func showAlertToChooseGridSize() {
        
        let actionSheetAlertController = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
        
        let twoItemsPerRowAction = UIAlertAction(title: K_TWO_ITEMS_PER_ROW.localized, style: .default) { _ in
            self.changeItemsPerRow(to: 2)
        }
        
        let threeItemsPerRowAction = UIAlertAction(title: K_THREE_ITEMS_PER_ROW.localized, style: .default) { _ in
            self.changeItemsPerRow(to: 3)
        }
        
        let fourItemsPerRowAction = UIAlertAction(title: K_FOUR_ITEMS_PER_ROW.localized, style: .default) { _ in
            self.changeItemsPerRow(to: 4)
        }
        
        let cancelAction = UIAlertAction(title: K_CANCEL.localized, style: .cancel, handler: nil)
        
        if viewModel.itemsPerRow != 2 {
            actionSheetAlertController.addAction(twoItemsPerRowAction)
        }
        if viewModel.itemsPerRow != 3 {
            actionSheetAlertController.addAction(threeItemsPerRowAction)
        }
        if viewModel.itemsPerRow != 4 {
            actionSheetAlertController.addAction(fourItemsPerRowAction)
        }
        actionSheetAlertController.addAction(cancelAction)
        
        present(actionSheetAlertController, animated: true, completion: nil)
    }
    
    private func changeItemsPerRow(to value: Int) {
        viewModel.itemsPerRow = value
        imageCollectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: SearchBar Delegate Methods
extension ImagesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.refreshRecentSearches()
        recentSearchTableView.isHidden = false
        recentSearchTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchedText = searchBar.text {
            let trimmedText = searchedText.trimmingCharacters(in: .whitespacesAndNewlines)
            searchImages(with: trimmedText)
        }
    }
    
    // Search images with search text
    private func searchImages(with text: String) {
        imageSearchBar.resignFirstResponder()
        imageSearchBar.text = ""
        recentSearchTableView.isHidden = true
        viewModel.searchImages(with: text)
    }
}

// MARK: Table View FlowLayout Delegate Methods
extension ImagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recentSearchTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchTableCell", for: indexPath)
        cell.textLabel?.text = viewModel.recentSearchTexts[indexPath.row]
        return cell
    }
}

// MARK: Table View FlowLayout Delegate Methods
extension ImagesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchImages(with: viewModel.recentSearchTexts[indexPath.row])
    }
}

// MARK: Collection View DataSource Methods
extension ImagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.defaultReuseIdentifier, for: indexPath) as? ImageCollectionCell else {
            fatalError("Unable to initialize ImageCollectionCell")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath)
        
        //reusableView.frame = CGRect(origin: .zero, size: CGSize(width: collectionView.frame.width, height: 40))
        reusableView.addSubview(activityIndicatorView)
        activityIndicatorView.frame = reusableView.bounds

        return reusableView
    }
}

// MARK: Collection View Delegate Methods
extension ImagesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        moveToImageDetail(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let image = viewModel.images[indexPath.row]
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
                        cell.imageView.contentMode = .scaleAspectFill
                        
                    } else {
                        cell.imageView.image = #imageLiteral(resourceName: "PlaceHolderImage")
                        cell.imageView.contentMode = .center
                    }
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.images.count {
            viewModel.images[indexPath.row].downloadTask?.priority = URLSessionDataTask.lowPriority
        }
    }
    
    private func moveToImageDetail(at indexPath: IndexPath) {
        guard let navCont = navigationController else {
            return
        }
        let imageDetailScene = ImageDetailViewController.instantiate(fromAppStoryboard: .main)
        imageDetailScene.images = viewModel.images
        imageDetailScene.selectedIndexPath = indexPath
        navCont.pushViewController(imageDetailScene, animated: true)
    }
}

// MARK: Collection View FlowLayout Delegate Methods
extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let floatItemsPerRow = CGFloat(viewModel.itemsPerRow)
        let minimumInterItemSpacing: CGFloat = 10
        let side = (collectionView.frame.width - sectionInset.left - sectionInset.right - ((floatItemsPerRow - 1) * minimumInterItemSpacing)) / floatItemsPerRow
        let adjustedSide = (side - 0.002)
        return CGSize(width: adjustedSide, height: adjustedSide)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}

// MARK: Scroll View Delegate Methods
extension ImagesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.height) > scrollView.contentSize.height {
            viewModel.getImages()
        }
    }
    
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
        
        let indices = imageCollectionView.visibleCells.compactMap { cell -> Int? in
            if let indexPath = imageCollectionView.indexPath(for: cell) {
                return indexPath.item
            }
            return nil
        }
        viewModel.increaseDownloadPriority(for: indices)
    }
}
