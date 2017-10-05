//
//  NotificationCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/26/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var notification: String?
    var user: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLabel() {
        if let notification = notification, let user = user {
            
            let userStringRange = (notification as NSString).range(of: user)
            
            let attributedString = NSMutableAttributedString(string: notification, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)])
            
            attributedString.setAttributes([NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName : UIColor.black], range: userStringRange)
            
            messageLabel.attributedText = attributedString
        }
    }

}
