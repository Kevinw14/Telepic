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
    @IBOutlet weak var fullscreenButton: UIButton!
    
    var inboxItem: InboxItem?
    weak var delegate: InboxItemDelegate?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var playerIsPaused = false
    
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
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
        
        let tapToViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewPhoto))
        blurView.addGestureRecognizer(tapToViewGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReachItemEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayer), name: Notifications.stopPlayer, object: nil)
    }

    func setUpCell() {
        guard let inboxItem = inboxItem else { return }
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchMediaItem(forItemID: inboxItem.itemID) { (mediaItem) in
                FirebaseController.shared.fetchComments(forMediaItemID: mediaItem.itemID, completion: { (comments) in
                    self.numberOfCommentsLabel.isHidden = false
                    self.numberOfCommentsLabel.text = "\(comments.count)"
                })
            }
        }
        
        if inboxItem.type == "photo" {
            let photoURL = URL(string: inboxItem.downloadURL)
            photoImageView.kf.setImage(with: photoURL)
            playButton.isHidden = true
            fullscreenButton.isHidden = true
        } else {
            let thumbnailURL = URL(string: inboxItem.thumbnailURL)
            photoImageView.kf.setImage(with: thumbnailURL)
            messageLabel.text = "Video Received!"
            playButton.isHidden = false
            fullscreenButton.isHidden = false
            photoImageView.addSubview(activityIndicatorView)
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            activityIndicatorView.stopAnimating()
            
            photoImageView.addSubview(playButton)
            playButton.isUserInteractionEnabled = false
            playButton.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
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
    
    @IBAction func fullscreenButtonTapped(_ sender: Any) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.player
        print("tapped fullscreen button")
        delegate?.presentVideoFullScreen(controller: playerViewController)
    }
    
    @objc func handlePlay() {
        print("tapped")
        if let videoURL = inboxItem?.downloadURL, let url = URL(string: videoURL) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.backgroundColor = UIColor.clear.cgColor
            playerLayer?.frame = photoImageView.bounds
            photoImageView.layer.addSublayer(playerLayer!)
            
            photoImageView.addSubview(playButton)
            playButton.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            player?.play()
            playButton.isHidden = true
            activityIndicatorView.startAnimating()
            print("Attempting to play video...")
        }
    }
    
    @objc func stopPlayer() {
        player?.pause()
        player = nil
    }
    
    @objc func didReachItemEnd() {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        } else {
            print("couldn't repeat")
        }
    }
    
    @objc func photoTapped(_ sender: UITapGestureRecognizer) {
        if inboxItem?.type == "video" {
            if player == nil {
                handlePlay()
            } else if self.playerIsPaused {
                player?.play()
                playButton.isHidden = true
                self.playerIsPaused = false
            } else {
                player?.pause()
                playButton.isHidden = false
                self.playerIsPaused = true
            }
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
        
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        player = nil
        activityIndicatorView.stopAnimating()
    }
    
    @objc func viewPhoto() {
        guard let inboxItem = inboxItem else { return }
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0
            //self.blurView.isHidden = true
            self.photoReceivedLabel.alpha = 0
            //self.photoReceivedLabel.isHidden = true
            self.forwardButton.isHidden = false
            //self.daysRemainingLabel.isHidden = true
        }
        
        // Record location and set inboxItem `opened` to true
        delegate?.recordUserLocation(item: inboxItem)

        
        // record the location the photo was viewed
        // add photo to array of viewed photos
        // remove photo from array of
    }
}

protocol InboxItemDelegate: class {
    func goFullscreen(_ imageView: UIImageView)
    func dismissFullscreen(_ sender: UITapGestureRecognizer)
    func recordUserLocation(item: InboxItem)
    func forwardItem(_ inboxItem: InboxItem, cell: UITableViewCell)
    func segueToMapVC(withItemID itemID: String)
    func segueToProfileVC(withUID uid: String, username: String)
    func segueToCommentsVC(withItemID itemID: String)
    func presentVideoFullScreen(controller: AVPlayerViewController)
    func presentMediaViewVC()
}

