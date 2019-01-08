//
//  CommentCell.swift
//  Telepic
//
//  Created by Michael Bart on 10/30/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher
import ActiveLabel

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageLabel: ActiveLabel!
    
    var comment: Comment?
    weak var delegate: CommentDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2
        self.avatarImageView.clipsToBounds = true
    }
    
    func setUpViews() {
        guard let comment = comment else { return }
        self.avatarImageView.kf.setImage(with: URL(string: comment.senderAvatarURL))
        self.usernameLabel.text = comment.username
        
        messageLabel.customize { (label) in
            label.numberOfLines = 0
            label.enabledTypes = [.mention, .url]
            label.text = comment.message
            label.handleURLTap { (url) in
                self.delegate?.openUrl(url: url)
            }
            
            label.handleMentionTap { (mention) in
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol CommentDelegate: class {
    func openUrl(url: URL)
}
