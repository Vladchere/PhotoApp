//
//  PhotosCollectionViewController.swift
//  AlamofireApp
//
//  Created by Vladislav on 23.06.2020.
//  Copyright © 2020 Vladislav Cheremisov. All rights reserved.
//

import UIKit
import Alamofire

class PhotosCollectionViewController: UICollectionViewController {
    
    // MARK: - Private propertys
    private var images: [URLS] = []
    private var itemsPerRow: CGFloat = 2
    private let sectionInserts = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    private var timer: Timer?
    private var page = 1
    private var orderBy = OrderBy.latest
    private let rightButton = UIButton()
    
    //MARK: - Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSearchBar()
        setupSegmentController()
        showListPhotos(page: page, orderBy: orderBy)
    }
    
    // MARK: -  UICollectionViewDataSource,  UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        
        let imageUrl = images[indexPath.item].small ?? ""
        
        NetworkManager.shared.fetchDataImage(imageUrl: imageUrl) { (data) in
            cell.imageView.image = UIImage(data: data)
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if indexPath.item == images.count - 1 {
                page += 1
                showListPhotos(page: page, orderBy: orderBy)
            }
    }

    // MARK: - Private methods
    private func showListPhotos(page: Int, orderBy: OrderBy) {
        NetworkManager.shared.fetchListPhotos(page: page, perPage: 20, orderBy: orderBy) { urls in
            self.images.append(contentsOf: urls)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func updateListPhotos(page: Int, orderBy: OrderBy) {
        NetworkManager.shared.fetchListPhotos(page: page, perPage: 20, orderBy: orderBy) { urls in
            self.images = urls
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
    }
    
    private func setupSegmentController() {
        let segmentedControl = UISegmentedControl()
        
        for orderBy in OrderBy.allCases {
            segmentedControl.insertSegment(withTitle: orderBy.rawValue,
                                           at: segmentedControl.numberOfSegments,
                                           animated: false)
        }

        navigationItem.titleView = segmentedControl
        
        segmentedControl.addTarget(self, action: #selector(choiceSegment), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        let titleLable = UILabel()
        titleLable.text = "PHOTOS"
        titleLable.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLable.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLable)
        
        rightButton.setImage(UIImage(systemName: "rectangle.grid.2x2"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
        rightButton.addTarget(self, action: #selector(buttonPressed), for: UIControl.Event.touchUpInside)
    }
    
    // MARK: - Actions
    @objc func buttonPressed(sender: UIButton) {
        if itemsPerRow == 2 {
            itemsPerRow = 1
            rightButton.setImage(UIImage(systemName: "rectangle.grid.1x2"), for: .normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
            self.collectionView.reloadData()
        } else {
            itemsPerRow = 2
            rightButton.setImage(UIImage(systemName: "rectangle.grid.2x2"), for: .normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
            self.collectionView.reloadData()
        }
    }
    
    @objc func choiceSegment(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            orderBy = OrderBy.latest
            updateListPhotos(page: page, orderBy: orderBy)
        case 1:
            orderBy = OrderBy.oldest
            updateListPhotos(page: page, orderBy: orderBy)
        default:
            orderBy = OrderBy.popular
            updateListPhotos(page: page, orderBy: orderBy)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            guard let cell = sender as? UICollectionViewCell else { return }
            guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
            guard let detailVC = segue.destination as? PhotoViewController else { return }
            
            detailVC.urlPhoto = images[indexPath.item].regular
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingWidth = sectionInserts.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem + 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) ->UIEdgeInsets {
        return sectionInserts
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.right
    }
}

// MARK: - UISearchBarDelegate
extension PhotosCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            NetworkManager.shared.fetchSearchPhoto(searchTerm: searchText, page: self.page, perPage: 20) { [weak self] (urls) in
                self?.images = urls

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        })
    }
}
