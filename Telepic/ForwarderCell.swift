//
//  ForwarderCell.swift
//  Telepic
//
//  Created by Michael Bart on 11/21/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class ForwarderCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var count: UILabel!
    
    var forwarder: Forwarder?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
    }
    
    func setUpCell() {
        guard let forwarder = forwarder else { return }
        
        let avatarURL = URL(string: forwarder.avatarURL)
        avatarImageView.kf.setImage(with: avatarURL)
        usernameLabel.text = forwarder.username
        count.text = "\(forwarder.count)"
    }
}
