//
//  InboxCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {

    @IBOutlet weak var senderAvatarImageView: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var daysRemainingLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var photoReceivedLabel: UIStackView!
    
    @IBOutlet weak var creatorAvatarImageView: UIImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    
    var inboxItem: InboxItem?
    weak var delegate: FullscreenViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
        
        let tapToViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewPhoto))
        blurView.addGestureRecognizer(tapToViewGesture)
    }

    func setUpCell() {
        guard let inboxItem = inboxItem else { return }
        
        senderAvatarImageView.image = inboxItem.senderAvatar
        senderAvatarImageView.layer.cornerRadius = senderAvatarImageView.frame.width / 2
        senderLabel.text = inboxItem.sender
        daysRemainingLabel.text = "\(inboxItem.daysRemaining)d"
        photoImageView.image = inboxItem.photo
        creatorAvatarImageView.image = inboxItem.creatorAvatar
        creatorAvatarImageView.layer.cornerRadius = creatorAvatarImageView.frame.width / 2
        creatorLabel.text = inboxItem.creator
    }
    
    func photoTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        delegate?.goFullscreen(imageView)
        
        delegate?.goFullscreen(imageView)
    }
    
    func viewPhoto() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0
            //self.blurView.isHidden = true
            self.photoReceivedLabel.alpha = 0
            //self.photoReceivedLabel.isHidden = true
            self.forwardButton.isHidden = false
            self.daysRemainingLabel.isHidden = true
        }
        
        // record the location the photo was viewed
        // add photo to array of viewed photos
        // remove photo from array of
    }
}

protocol FullscreenViewDelegate: class {
    func goFullscreen(_ imageView: UIImageView)
    func dismissFullscreen(_ sender: UITapGestureRecognizer)
}

