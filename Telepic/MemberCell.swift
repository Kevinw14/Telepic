//
//  MemberCell.swift
//  Telepic
//
//  Created by Michael Bart on 11/2/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class MemberCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarContainerView: UIView!
    
    var friend: Friend?
    
    func setUpViews() {
        guard let friend = friend else { return }
        let url = URL(string: friend.avatarURL)
        self.avatarImageView.kf.setImage(with: url)
        
        self.usernameLabel.text = friend.username
        
        avatarContainerView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5).cgColor
        avatarContainerView.layer.shadowOpacity = 1
        avatarContainerView.layer.shadowRadius = 4.0
        avatarContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        avatarContainerView.layer.shadowPath = UIBezierPath(roundedRect: avatarContainerView.bounds, cornerRadius: avatarContainerView.frame.width / 2).cgPath
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2
        self.avatarImageView.clipsToBounds = true
    }
}
