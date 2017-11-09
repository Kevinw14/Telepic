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

class MediaViewVC: UIViewController {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var topBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var mediaItem: MediaItem?
    var photo: UIImage?
    var panGestureRecognizer = UIPanGestureRecognizer()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarTopConstraint.constant = -120
        bottomBarBottomConstraint.constant = 80
        
        playButton.isHidden = true
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: Notifications.didLoadMediaItem, object: nil)
        
        if let photo = photo {
            self.mediaImageView.image = photo
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(pan(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        self.view.addGestureRecognizer(tapGesture)
        
        
    }
    
    @objc func handlePlay() {
        if let videoURL = FirebaseController.shared.currentMediaItem?.downloadURL, let url = URL(string: videoURL) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.backgroundColor = UIColor.clear.cgColor
            playerLayer?.frame = mediaImageView.bounds
            mediaImageView.layer.addSublayer(playerLayer!)
            
            mediaImageView.addSubview(playButton)
            playButton.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            player?.play()
            playButton.isHidden = true
            activityIndicatorView.startAnimating()
            print("Attempting to play video...")
        }
    }
    
    @IBAction func creatorTapped(_ sender: Any) {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        let creatorID = mediaItem.creatorID
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileVC
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: creatorID, completion: { (user) in
                profileVC.user = user
                profileVC.userID = creatorID
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        
        guard let tabBarVC = self.presentingViewController as? TabBarVC else { return }
        guard let vc = tabBarVC.viewControllers[tabBarVC.selectedIndex] as? UINavigationController else { return }
        dismiss(animated: false) {

            vc.pushViewController(profileVC, animated: true)
        }
        
    }
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        let mapNavVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapNavVC") as! UINavigationController
        let mapVC = mapNavVC.viewControllers.first as! MapVC
        mapVC.mediaItem = mediaItem
        self.present(mapNavVC, animated: true, completion: nil)
    }
    
    @IBAction func commentsButtonTapped(_ sender: Any) {
        guard let mediaItemID = FirebaseController.shared.currentMediaItem?.itemID else { return }
        let commentsVC = UIStoryboard(name: "Comments", bundle: nil).instantiateInitialViewController() as! CommentsVC
        commentsVC.mediaItemID = mediaItemID
        commentsVC.isModal = true
        self.present(commentsVC, animated: true, completion: nil)
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        
        let sendVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "SendVC") as! SendVC
        let inboxItem = FirebaseController.shared.inboxItems.filter { $0.itemID == mediaItem.itemID }
        sendVC.isForwardingItem = true
        sendVC.inboxItemBeingSent = inboxItem[0]
        present(sendVC, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        close()
    }
    
    @objc func updateViews() {
        guard let mediaItem = FirebaseController.shared.currentMediaItem else { return }
        self.usernameLabel.text = mediaItem.creatorUsername
        FirebaseController.shared.fetchAvatarImage(forUID: mediaItem.creatorID, completion: { (avatarURL) in
            self.avatarImageView.kf.setImage(with: URL(string: avatarURL))
        })
        
        if mediaItem.type == "video" {
            playButton.isHidden = false
            
            mediaImageView.addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor).isActive = true
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            activityIndicatorView.stopAnimating()
            
            mediaImageView.addSubview(playButton)
            playButton.isUserInteractionEnabled = false
            playButton.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
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
        self.topBarTopConstraint.constant = -120
        self.bottomBarBottomConstraint.constant = 80
        UIView.animate(withDuration: 0.3, animations: {
            self.mediaImageView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.mediaImageView.isHidden = true
            FirebaseController.shared.photoToPresent?.isHidden = true
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func photoTapped() {
        if topBar.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.topBar.alpha = 0
                self.bottomBar.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.topBar.alpha = 1
                self.bottomBar.alpha = 1
            })
        }
        
        if FirebaseController.shared.currentMediaItem?.type == "video" {
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
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topBarTopConstraint.constant = 0
        bottomBarBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.modalPresentationCapturesStatusBarAppearance = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol MediaViewDelegate: class {
    func presentMediaView(withImage image: UIImage)
}
