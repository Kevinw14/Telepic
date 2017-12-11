//
//  ThumbnailCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/26/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {

    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.playButton.isHidden = true
    }

}
