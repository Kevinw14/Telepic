//
//  FiltersView.swift
//  Telepic
//
//  Created by Michael Bart on 12/8/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Stevia

class FiltersView: UIView {
    
    let imageView = UIImageView()
    var collectionView: UICollectionView!
    let filterButton = UIButton()
    let editButton = UIButton()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        addSubview(imageView)
        addSubview(filterButton)
        addSubview(editButton)
        
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.60).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: filterButton.topAnchor, constant: -10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        filterButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        filterButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60).isActive = true
        
        editButton.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor).isActive = true
        editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60).isActive = true
        
        backgroundColor = UIColor(red: 247, green: 247, blue: 247, alpha: 1.0)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        filterButton.setTitleColor(.black, for: .normal)
        filterButton.setTitle("Filter", for: .normal)
        editButton.setTitleColor(.black, for: .normal)
        editButton.setTitle("Edit", for: .normal)
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return layout
    }
}
