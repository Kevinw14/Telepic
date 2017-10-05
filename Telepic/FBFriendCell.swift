//
//  FBFriendCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/6/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class FBFriendCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        checkmarkImageView.isHidden = true
    }

}
