//
//  GridLayout.swift
//  Telepic
//
//  Created by Kevin Wood on 11/20/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit

protocol GridLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
    func collectionView(_ collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

class GridLayout: UICollectionViewLayout {

    weak var delegate: GridLayoutDelegate!

    fileprivate var numberOfRows = 2
    var cellPadding: CGFloat = 8

    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        
        return collectionView.frame.height - (insets.top + insets.bottom)
    }

    private var contentWidth: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else { return }
        
        // Gets rows height. Row's height is calulated by getting the collections views height and dividing by rows
//        let rowHeight = contentHeight / CGFloat(numberOfRows)
        // Create an array to hold the x-coordinate
//        var yOffset = [CGFloat](repeating: 0, count: numberOfRows)
        // Loop through how many rows there is an and set the y array to row height * row number Ex. Row height = 44, row = 3, [0, 44, 88]
//        for row in 0 ..< numberOfRows {
//            yOffset.append(CGFloat(row) * rowHeight)
//        }
        
        var row = 0
        var yOffset: [CGFloat] = [CGFloat](repeating: 0, count: numberOfRows)
        var xOffset: [CGFloat] = [CGFloat](repeating: 0, count: numberOfRows)
        
        for index in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: index, section: 0)
            
            let photoWidth = delegate.collectionView(collectionView, widthForPhotoAtIndexPath: indexPath)
            let width = cellPadding * 2 + photoWidth
            let height = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: height)
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            print("Frame Max X: \(frame.maxX), ContentWidth: \(contentWidth)")
            contentWidth = max(frame.maxX, contentWidth)
            
            xOffset[row] = xOffset[row] + width
            yOffset[row] = yOffset[row] + height
            
            row = row < (numberOfRows - 1) ? (row + 1) : 0
        }
        
        print("Content Width", contentWidth, "Content Height", contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributeList = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                attributeList.append(attributes)
            }
        }
        
        return attributeList
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
