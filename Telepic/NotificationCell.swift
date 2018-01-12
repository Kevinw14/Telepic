//
//  NotificationCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/26/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var notification: EventNotification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
    }

    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let uid = notification?.userID else { return }
        FirebaseController.shared.addFriend(withUID: uid)
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp() {
        guard let notification = notification else { return }
        
        switch notification.type {
        case .newfriendRequest:
            self.acceptButton.isHidden = false
            self.declineButton.isHidden = false
            self.photoImageView.alpha = 0
        case .newInboxItem:
            self.photoImageView.isHidden = true
            self.acceptButton.isHidden = true
            self.declineButton.isHidden = true
        default:
            self.acceptButton.isHidden = true
            self.declineButton.isHidden = true
            self.photoImageView.alpha = 1
        }
        
        if notification.type == .newComment {
            FirebaseController.shared.fetchMediaItem(forItemID: notification.mediaID!, completion: { (mediaItem) in
                let url = URL(string: mediaItem.downloadURL)
                self.photoImageView.kf.setImage(with: url)
            })
        }

        let userStringRange = (notification.message as NSString).range(of: notification.username)
        
        let attributedString = NSMutableAttributedString(string: notification.message, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)])
        
        attributedString.setAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : UIColor.black], range: userStringRange)
        
        messageLabel.attributedText = attributedString
        
        let avatarURL = URL(string: notification.avatarURL)
        avatarImageView.kf.setImage(with: avatarURL, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cache, url) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        if let mediaURL = notification.mediaURL {
            let url = URL(string: mediaURL)
            photoImageView.kf.setImage(with: url)
        }
    }

}
