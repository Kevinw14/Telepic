//
//  ThumbCell.swift
//  Telepic
//
//  Created by Kevin Wood on 11/13/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit

class ThumbCell: UICollectionViewCell {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.playButton.isHidden = true
    }
    
    override func prepareForReuse() {
        self.playButton.isHidden = true
    }
    
}
