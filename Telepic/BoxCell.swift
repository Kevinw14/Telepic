////
////  BoxCell.swift
////  Telepic
////
////  Created by Kevin Wood on 11/7/18.
////  Copyright © 2018 Telepic LLC. All rights reserved.
////

import UIKit
import AVKit

class BoxCell: UITableViewCell {
    
    let senderContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let senderAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "avatar3")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let senderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.avenirNextDemiBold, size: 16)
        label.textColor = UIColor(hexString: "505050")
        label.text = "Kevinlw14"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "forwardIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(hexString: "505050")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let daysRemainingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.avenirNextDemiBold, size: 14)
        label.textColor = UIColor(hexString: "999999")
        label.text = "1d"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "avatar3")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var photoReceivedStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [photoReceivedLabel, tapToViewItLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let photoReceivedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.avenirNextMedium, size: 18)
        label.textColor = .white
        label.text = "Photo received!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tapToViewItLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.avenirNextRegular, size: 14)
        label.textColor = .white
        label.text = "Tap to view it."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let numberOfCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexString: "333333")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
    
    let actionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let createdByLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.avenirNextRegular, size: 12)
        label.text = "Created by:"
        label.textColor = UIColor(hexString: "505050")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let creatorAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.avenirNextDemiBold, size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mapButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hexString: "EF8348")
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "mapButton").withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.setTitle("View Comments", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let captionLabel: CaptionLabel = {
        let label = CaptionLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var commentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var inboxItem: InboxItem
    let parentTableView: UITableView
    weak var delegate: InboxItemDelegate?
    var player: AVQueuePlayer?
    var looper: AVPlayerLooper?
    var gif: UIImage?
    
    init(inboxItem: InboxItem, parentTableView: UITableView, reuseIdentifier: String?){
        self.inboxItem = inboxItem
        self.parentTableView = parentTableView
        super .init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        contentView.isUserInteractionEnabled = true
        let tapToViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewPhoto))
        blurView.addGestureRecognizer(tapToViewGesture)
        mapButton.addTarget(self, action: #selector(mapButtonTapped(_:)), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped(_:)), for: .touchUpInside)
        setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        addSubview(senderContainerView)
        senderContainerView.addSubview(senderAvatarImageView)
        senderContainerView.addSubview(senderLabel)
        senderContainerView.addSubview(daysRemainingLabel)
        senderContainerView.addSubview(forwardButton)
        addSubview(photoImageView)
        addSubview(actionContainerView)
        actionContainerView.addSubview(mapButton)
        actionContainerView.addSubview(forwardButton)
        actionContainerView.addSubview(createdByLabel)
        actionContainerView.addSubview(creatorAvatarImageView)
        
        senderContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        senderContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        senderContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        senderContainerView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        senderAvatarImageView.leadingAnchor.constraint(equalTo: senderContainerView.leadingAnchor, constant: 8).isActive = true
        senderAvatarImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        senderAvatarImageView.widthAnchor.constraint(equalTo: senderAvatarImageView.heightAnchor).isActive = true
        senderAvatarImageView.centerYAnchor.constraint(equalTo: senderContainerView.centerYAnchor).isActive = true
        senderAvatarImageView.layer.cornerRadius = 17.5

        senderLabel.leadingAnchor.constraint(equalTo: senderAvatarImageView.trailingAnchor, constant: 6).isActive = true
        senderLabel.centerYAnchor.constraint(equalTo: senderAvatarImageView.centerYAnchor).isActive = true
        senderLabel.trailingAnchor.constraint(lessThanOrEqualTo: daysRemainingLabel.leadingAnchor, constant: -8).isActive = true
        daysRemainingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        daysRemainingLabel.centerYAnchor.constraint(equalTo: senderAvatarImageView.centerYAnchor).isActive = true
        
        photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        photoImageView.topAnchor.constraint(equalTo: senderContainerView.bottomAnchor).isActive = true
        photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
        
        actionContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        actionContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        actionContainerView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor).isActive = true
        actionContainerView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        mapButton.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor, constant: 12).isActive = true
        mapButton.centerYAnchor.constraint(equalTo: actionContainerView.centerYAnchor).isActive = true
        
        forwardButton.leadingAnchor.constraint(equalTo: mapButton.trailingAnchor, constant: 32).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: mapButton.centerYAnchor).isActive = true
        forwardButton.trailingAnchor.constraint(lessThanOrEqualTo: createdByLabel.leadingAnchor, constant: -8).isActive = true
        
        createdByLabel.trailingAnchor.constraint(equalTo: creatorAvatarImageView.leadingAnchor, constant: -8).isActive = true
        createdByLabel.centerYAnchor.constraint(equalTo: creatorAvatarImageView.centerYAnchor).isActive = true
        
        creatorAvatarImageView.centerYAnchor.constraint(equalTo: mapButton.centerYAnchor).isActive = true
        creatorAvatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        creatorAvatarImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        creatorAvatarImageView.widthAnchor.constraint(equalTo: creatorAvatarImageView.heightAnchor).isActive = true
        
        if inboxItem.caption != nil && inboxItem.caption != "" {
            addSubview(captionLabel)
            addSubview(commentButton)
            
            captionLabel.leadingAnchor.constraint(equalTo: mapButton.leadingAnchor).isActive = true
            captionLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionContainerView.trailingAnchor).isActive = true
            captionLabel.topAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: 8).isActive = true
            
            commentButton.leadingAnchor.constraint(equalTo: captionLabel.leadingAnchor).isActive = true
            commentButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8).isActive = true
            commentButton.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 8).isActive = true
            commentButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20).isActive = true
        } else {
            addSubview(commentButton)
            
            commentButton.leadingAnchor.constraint(equalTo: mapButton.leadingAnchor).isActive = true
            commentButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8).isActive = true
            commentButton.topAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: 8).isActive = true
            commentButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
        
        print(inboxItem.commentIDs.count)
        if inboxItem.commentIDs.count == 0 {
            commentButton.setTitle("Be the first to comment", for: .normal)
        } else if inboxItem.commentIDs.count == 1 {
            commentButton.setTitle("View 1 comment", for: .normal)
        } else {
            commentButton.setTitle("View all \(inboxItem.commentIDs.count) comments", for: .normal)
        }
        
        captionLabel.text = inboxItem.caption
    }
    
    private func setUpCell() {
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
        
//        FirebaseController.shared.fetchComments(forMediaItemID: inboxItem.itemID, completion: { (comments) in
//            self.comments = comments
//        })
        
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
        
        senderAvatarImageView.layer.cornerRadius = senderAvatarImageView.frame.width / 2
        let timestampDate = Date(timeIntervalSince1970: inboxItem.timestamp)
        daysRemainingLabel.text = timestampDate.dateString
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
    
    @objc private func reloadComments() {
        commentTableView.reloadData()
    }
    
    @objc func senderTapped(_ sender: Any) {
        print("Sender Tapped")
        delegate?.segueToProfileVC(withUID: inboxItem.senderID, username: inboxItem.senderUsername)
    }
    
    @objc func creatorTapped(_ sender: Any) {
        print("Creator Tapped")
        delegate?.segueToProfileVC(withUID: inboxItem.creatorID, username: inboxItem.creatorUsername)
    }
    
    @objc func viewPhoto() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0
            self.photoReceivedLabel.alpha = 0
            self.forwardButton.isHidden = false
        }
        delegate?.recordUserLocation(cell: self, item: inboxItem)
    }
    
    @objc func mapButtonTapped(_ sender: Any) {
        print("Map Tapped")
        delegate?.segueToMapVC(withItemID: inboxItem.itemID)
    }
    
    @objc func commentsButtonTapped(_ sender: Any) {
        print("CommentButtonTapped")
        delegate?.segueToCommentsVC(withItemID: inboxItem.itemID)
    }
    
    @objc func forwardButtonTapped(_ sender: Any) {
        print("Foward Button tapped")
        delegate?.forwardItem(inboxItem, cell: self)
    }
    
    @objc func photoTapped(_ sender: UITapGestureRecognizer) {

        print("Photo Tapped")
        if inboxItem.type == "video" {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = self.player
            self.delegate?.presentVideoFullScreen(controller: playerViewController)
        } else {
            if let _ = self.photoImageView.image {
                FirebaseController.shared.fetchMediaItem(forItemID: inboxItem.itemID, completion: { (mediaItem) in
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
        
        self.numberOfCommentsLabel.text = ""
        //        self.captionLabel.isHidden = false
    }
}

//extension BoxCell: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if comments.count == 1 {
//            return 2
//        } else if comments.count >= 2 {
//            return 3
//        } else {
//            return 0
//        }
//    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
//        if comments.count == 1 {
//            switch indexPath.row {
//            case 0: return CaptionCell(caption: comments[0].message, creatorAvatarURL: comments[0].senderAvatarURL)
//            case 1:
//                return ViewMoreCommentsCell(numberOfComments: comments.count)
//            default: return UITableViewCell()
//            }
//        }

//        if comments.count >= 2 {
//
//            switch indexPath.row {
//            case 0: return CaptionCell(caption: comments[0].message, creatorAvatarURL: comments[0].senderAvatarURL)
//            case 1: return CaptionCell(caption: comments[1].message, creatorAvatarURL: comments[1].senderAvatarURL)
//            case 2:
//                return ViewMoreCommentsCell(numberOfComments: comments.count)
//            default: return UITableViewCell()
//            }
//        }
    
//        if comments.count > 0 {
//
//            tableView.separatorStyle = .none
//        }
//
//        return UITableViewCell()
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
//        if comments.count == 1 {
//            switch indexPath.row {
//            case 1:
//                delegate?.segueToCommentsVC(withItemID: inboxItem.itemID)
//            default: break
//            }
//        } else if comments.count >= 2 {
//            switch indexPath.row {
//            case 2:
//                delegate?.segueToCommentsVC(withItemID: inboxItem.itemID)
//            default: break
//            }
//        }
//    }
//}

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
