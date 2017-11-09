//
//  FriendCell.swift
//  Telepic
//
//  Created by Michael Bart on 10/17/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class FriendCell: UITableViewCell {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    var friend: Friend?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkmark.isHidden = true
        
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.width / 2
        userAvatarImageView.clipsToBounds = true
    }
    
    func setUpCell() {
        guard let friend = friend else { return }
        
        let avatarURL = URL(string: friend.avatarURL)
        userAvatarImageView.kf.setImage(with: avatarURL, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        usernameLabel.text = friend.username
    }

}
