//
//  CategoryTableViewCell.swift
//  Telepic
//
//  Created by Kevin Wood on 11/23/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var categories: [Category] = []
    
    override func awakeFromNib() {
        super .awakeFromNib()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "PostCategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        FirebaseController.shared.fetchCategories { (categories) in
            if let categories = categories {
                self.categories = categories
                self.collectionView.reloadData()
            }
        }
    }
}

extension CategoryTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! PostCategoryCell
        
        let category = categories[indexPath.item]
        
        cell.backgroundImageView.kf.setImage(with: category.imageURL)
        cell.categoryLabel.text = category.name
        cell.backgroundImageView.layer.cornerRadius = 10
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 90)
    }
}
