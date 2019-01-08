//
//  ProfileThumbnailCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/26/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ProfileThumbnailCell: UICollectionViewCell {

    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var newFowardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.playButton.isHidden = true
    }

}
