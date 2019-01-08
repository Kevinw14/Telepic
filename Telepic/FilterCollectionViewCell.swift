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
                name.textColor = isSelected ? UIColor.black : UIColor.gray
        
                name.font = .systemFont(ofSize: 11, weight: isSelected ? UIFont.Weight.medium : UIFont.Weight.regular)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        name.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(name)
        
        name.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -10).isActive = true
        
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        name.font = .systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        name.textColor = .gray
        name.textAlignment = .center
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.shadowColor = UIColor(red: 46, green: 43, blue: 37, alpha: 1.0).cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width:0, height:10)
        imageView.layer.shadowRadius = 20
        imageView.clipsToBounds = true
    }
}

