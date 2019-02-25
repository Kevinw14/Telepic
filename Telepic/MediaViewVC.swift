//
//  MediaViewVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/27/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import FirebaseAuth
import SVProgressHUD

class MediaViewVC: UIViewController {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var topBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var photo: UIImage?
    var panGestureRecognizer = UIPanGestureRecognizer()
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    var looper: AVPlayerLooper?
    var player: AVQueuePlayer?
    
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
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
        
        return button
    }()
    
    var notificationMediaID: String?
    var isFromNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let photo = photo {
            self.mediaImageView.image = photo
        }
        
        self.playButton.isHidden = true
        
        self.edgesForExtendedLayout = []
        
        topBarTopConstraint.constant = -120
        bottomBarBottomConstraint.constant = 80
        
        self.mediaImageView.contentMode = .scaleAspectFit
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        updateViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: Notifications.didLoadMediaItem, object: nil)
        
        
        panGestureRecognizer.addTarget(self, action: #selector(pan(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        self.view.addGestureRecognizer(tapGesture)
        
        print("loaded")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.hidesBottomBarWhenPushed = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func creatorTapped(_ sender: Any) {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        let creatorID = mediaItem.creatorID
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: Identifiers.profileVC) as! ProfileVC
        profileVC.isCurrentUser = false
        profileVC.username = mediaItem.creatorUsername
        profileVC.userID = creatorID
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: creatorID, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        FirebaseController.shared.isZooming = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(profileVC, animated: true)
        FirebaseController.shared.isZooming = true
    }
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        let mapVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mapVC) as! MapVC
        mapVC.mediaItem = mediaItem
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func commentsButtonTapped(_ sender: Any) {
        toCommentsVC()
    }
    
    func toCommentsVC() {
        guard let mediaItemID = FirebaseController.shared.currentMediaItem?.itemID else { return }
        let commentsVC = UIStoryboard(name: "Comments", bundle: nil).instantiateViewController(withIdentifier: Identifiers.commentsVC) as! CommentsVC
        commentsVC.mediaItemID = mediaItemID
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(commentsVC, animated: true)
        
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        
        let sendVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "SendVC") as! SendVC
        sendVC.isForwardingItem = true
        sendVC.mediaItemBeingSent = mediaItem
        self.navigationController?.pushViewController(sendVC, animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        close()
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if currentUID == mediaItem.creatorID {
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                print("delete item")
                FirebaseController.shared.removeMediaItem(withID: mediaItem.itemID)
//                NotificationCenter.default.post(Notification(name: Notifications.didUploadMedia))
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func updateViews() {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        
        if mediaItem.type == "video" {
            let videoURL = mediaItem.downloadURL
            mediaImageView.addSubview(playButton)
            playButton.isHidden = false
            playButton.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            if let url = URL(string: videoURL) {
                let asset = AVAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                self.player = AVQueuePlayer(playerItem: item)
                self.looper = AVPlayerLooper(player: self.player!, templateItem: item)
            }
        } else {
            playButton.isHidden = true
        }
        
        self.numberOfCommentsLabel.text = ""
        self.avatarImageView.image = #imageLiteral(resourceName: "avatar-1")
        
        FirebaseController.shared.fetchComments(forMediaItemID: mediaItem.itemID, completion: { (comments) in
            self.numberOfCommentsLabel.isHidden = false
            self.numberOfCommentsLabel.text = "\(comments.count)"
        })
        
        self.usernameLabel.text = mediaItem.creatorUsername
        FirebaseController.shared.fetchAvatarImage(forUID: mediaItem.creatorID, completion: { (avatarURL) in
            self.avatarImageView.kf.setImage(with: URL(string: avatarURL))
        })
        
    }
    
    @objc func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        self.mediaImageView.frame.origin = translation
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            
            if velocity.y >= 1500 {
                // dismiss
                close()
                UIView.animate(withDuration: 0.3, animations: {
                    self.mediaImageView.frame.origin.y = 1000.0
                })
            } else {
                // return to the original position
                UIView.animate(withDuration: 0.3, animations: {
                    self.mediaImageView.frame.origin = CGPoint(x: 0, y: 0)
                })
            }
        }
    }
    
    func close() {
        if isFromNotification {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.topBarTopConstraint.constant = -120
            self.bottomBarBottomConstraint.constant = 80
            self.view.layoutIfNeeded()
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func photoTapped() {
        if FirebaseController.shared.currentMediaItem?.type == "video" {
            if player != nil {
                let playerViewController = AVPlayerViewController()
                playerViewController.player = self.player
                
                self.present(playerViewController, animated: false, completion: {
                    playerViewController.player?.play()
                })
            }
        } else {
            if topBar.alpha == 1 {
                UIView.animate(withDuration: 0.3) {
                    self.topBar.alpha = 0
                    self.bottomBar.alpha = 0
                    self.numberOfCommentsLabel.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.topBar.alpha = 1
                    self.bottomBar.alpha = 1
                    self.numberOfCommentsLabel.alpha = 1
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topBarTopConstraint.constant = 0
        bottomBarBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.modalPresentationCapturesStatusBarAppearance = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension MediaViewVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return mediaImageView
    }
}
