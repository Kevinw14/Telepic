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
    
    convenience init() {
        self.init(frame: CGRect.zero)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        
        sv(
            imageView,
            collectionView
        )
        
        layout(
            |imageView|,
            0,
            |collectionView.bottom(0).height(144)|
        )
        
        imageView.top(0)
        backgroundColor = UIColor(red: 247, green: 247, blue: 247, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        layout.itemSize = CGSize(width: 100, height: 120)
        return layout
    }
}
