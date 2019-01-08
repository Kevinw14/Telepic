//
//  ExploreNavigationTitleView.swift
//  Telepic
//
//  Created by Kevin Wood on 11/23/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit

class ExploreNavigationTitleView: UIView {
    
    let mapButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "mapButton"), for: .normal)
        button.tintColor = UIColor(hexString: "505050")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.barTintColor = .lightGray
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        addSubview(searchBar)
        addSubview(mapButton)
        
        searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: mapButton.leadingAnchor, constant: 16).isActive = true
        searchBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        mapButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        mapButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        
        activateOffset()
    }
    
    private func activateOffset() {
        let searchBarWidth = searchBar.frame.width
        let placeHolderWidth: CGFloat = 100
        let offset = UIOffset(horizontal: (searchBarWidth - placeHolderWidth) / 2, vertical: 0)
        searchBar.setPositionAdjustment(offset, for: .search)
    }
    
    private func deactivateOffset() {
        let offset = UIOffset(horizontal: 0, vertical: 0)
        searchBar.setPositionAdjustment(offset, for: .search)
    }
}

extension ExploreNavigationTitleView: UISearchBarDelegate {
    
    func searchBarTextShouldEndEditing(_ searchBar: UISearchBar) {
        activateOffset()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        deactivateOffset()
        return true
    }
}
