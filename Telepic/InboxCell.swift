//
//  InboxCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import AVKit

class InboxCell: UITableViewCell {

    @IBOutlet weak var senderAvatarImageView: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var daysRemainingLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var photoReceivedLabel: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var creatorAvatarImageView: UIImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    
    var inboxItem: InboxItem?
    weak var delegate: InboxItemDelegate?
    var player: AVQueuePlayer?
    var looper: AVPlayerLooper?
    var gif: UIImage?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        aiv.startAnimating()
        return aiv
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "playButton")
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
        
        let tapToViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewPhoto))
        blurView.addGestureRecognizer(tapToViewGesture)
    }
    
    

    func setUpCell() {
        guard let inboxItem = inboxItem else { return }
        
        if inboxItem.type == "video" {
            self.photoImageView.addSubview(playButton)
            self.playButton.centerXAnchor.constraint(equalTo: self.photoImageView.centerXAnchor).isActive = true
            self.playButton.centerYAnchor.constraint(equalTo: self.photoImageView.centerYAnchor).isActive = true
            self.playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            self.playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            let videoURL = inboxItem.downloadURL
            if let url = URL(string: videoURL) {
                let asset = AVAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                self.player = AVQueuePlayer(playerItem: item)
                self.looper = AVPlayerLooper(player: self.player!, templateItem: item)
            }
        }
        
        FirebaseController.shared.fetchComments(forMediaItemID: inboxItem.itemID, completion: { (comments) in
            if inboxItem.caption != nil && comments.count == 1 {
                self.numberOfCommentsLabel.isHidden = true
            } else {
                self.numberOfCommentsLabel.isHidden = false
                self.numberOfCommentsLabel.text = "\(comments.count)"
            }
        })
        
        let senderAvatarURL = URL(string:inboxItem.senderAvatarURL)
        senderAvatarImageView.kf.setImage(with: senderAvatarURL, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let creatorAvatarURL = URL(string:inboxItem.creatorAvatarURL)
        creatorAvatarImageView.kf.setImage(with: creatorAvatarURL, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        senderLabel.text = inboxItem.senderUsername
        creatorLabel.text = inboxItem.creatorUsername
        
        if let caption = inboxItem.caption {
            captionLabel.text = caption
        } else {
            captionLabel.isHidden = true
        }
        
        senderAvatarImageView.layer.cornerRadius = senderAvatarImageView.frame.width / 2
        daysRemainingLabel.text = inboxItem.daysRemaining
        creatorAvatarImageView.layer.cornerRadius = creatorAvatarImageView.frame.width / 2
        
        // set up cell properly for inboxItem open state
        if inboxItem.opened {
            self.blurView.alpha = 0
            self.photoReceivedLabel.alpha = 0
            self.forwardButton.isHidden = false
            self.daysRemainingLabel.isHidden = false
        } else {
            self.blurView.alpha = 1
            self.photoReceivedLabel.alpha = 1
            self.forwardButton.isHidden = true
            self.daysRemainingLabel.isHidden = false
        }
    }
    
    @IBAction func senderTapped(_ sender: Any) {
        guard let senderID = inboxItem?.senderID, let username = inboxItem?.senderUsername else { return }
        delegate?.segueToProfileVC(withUID: senderID, username: username)
    }
    
    @IBAction func creatorTapped(_ sender: Any) {
        guard let creatorID = inboxItem?.creatorID, let username = inboxItem?.creatorUsername else { return }
        delegate?.segueToProfileVC(withUID: creatorID, username: username)
    }
    
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        guard let inboxItem = inboxItem else { return }
        delegate?.segueToMapVC(withItemID: inboxItem.itemID)
    }
    
    @IBAction func commentsButtonTapped(_ sender: Any) {
        guard let inboxItem = inboxItem else { return }
        delegate?.segueToCommentsVC(withItemID: inboxItem.itemID)
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let inboxItem = inboxItem else { return }
        delegate?.forwardItem(inboxItem, cell: self)
    }
    
    @objc func photoTapped(_ sender: UITapGestureRecognizer) {
        
        if inboxItem?.type == "video" {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = self.player
            self.delegate?.presentVideoFullScreen(controller: playerViewController)
        } else {
            if let _ = self.photoImageView.image, let item = self.inboxItem {
                FirebaseController.shared.fetchMediaItem(forItemID: item.itemID, completion: { (mediaItem) in
                    FirebaseController.shared.currentMediaItem = mediaItem
                    
                    NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
                })
                FirebaseController.shared.photoToPresent = self.photoImageView
                self.delegate?.presentMediaViewVC()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.inboxItem = nil
        self.numberOfCommentsLabel.text = ""
        self.captionLabel.isHidden = false
    }
    
    @objc func viewPhoto() {
        guard let inboxItem = inboxItem else { return }
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0
            self.photoReceivedLabel.alpha = 0
            self.forwardButton.isHidden = false
        }
        delegate?.recordUserLocation(cell: self, item: inboxItem)
    }
}

protocol InboxItemDelegate: class {
    func goFullscreen(_ imageView: UIImageView)
    func dismissFullscreen(_ sender: UITapGestureRecognizer)
    func recordUserLocation(cell: UITableViewCell, item: InboxItem)
    func forwardItem(_ inboxItem: InboxItem, cell: UITableViewCell)
    func segueToMapVC(withItemID itemID: String)
    func segueToProfileVC(withUID uid: String, username: String)
    func segueToCommentsVC(withItemID itemID: String)
    func presentVideoFullScreen(controller: AVPlayerViewController)
    func presentMediaViewVC()
}

