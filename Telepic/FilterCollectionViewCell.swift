//
//  FilterCollectionViewCell.swift
//  Telepic
//
//  Created by Michael Bart on 12/8/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Stevia

class FilterCollectionViewCell: UICollectionViewCell {
    let name = UILabel()
    let imageView = UIImageView()
    override var isHighlighted: Bool { didSet {
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                : CGAffineTransform.identity
        }
        }
    }
    override var isSelected: Bool { didSet {
        //        name.textColor = isSelected
        //            ? UIColor(red: 38, green: 38, blue: 38, alpha: 1.0)
        //            : UIColor(red: 154, green: 154, blue: 154, alpha: 1.0)
        //
        //        name.font = .systemFont(ofSize: 11, weight: isSelected
        //            ? UIFont.Weight.medium
        //            : UIFont.Weight.regular)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sv(
            imageView,
            name
        )
        
        |imageView|.top(0).heightEqualsWidth()
        |name|.bottom(0)
        
        name.font = .systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        name.textColor = UIColor.black
        name.textAlignment = .center
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.shadowColor = UIColor(red: 46, green: 43, blue: 37, alpha: 1.0).cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width:0, height:10)
        imageView.layer.shadowRadius = 20
        imageView.clipsToBounds = true
    }
}

