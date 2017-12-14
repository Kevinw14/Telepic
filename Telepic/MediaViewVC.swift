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

class MediaViewVC: UIViewController {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var topBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    //var mediaItem: MediaItem?
    var photo: UIImage?
    var panGestureRecognizer = UIPanGestureRecognizer()
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var playerIsPaused = false
    
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
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
        
        updateViews()
        
        self.edgesForExtendedLayout = []
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        topBarTopConstraint.constant = -120
        bottomBarBottomConstraint.constant = 80
        
        self.mediaImageView.contentMode = .scaleAspectFit
        
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
        
        print("loaded")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.pause()
        player = nil
    }
    
    @objc func playerItemDidReachEnd(_ note: Notification) {
        player?.actionAtItemEnd = .none
        player?.seek(to: kCMTimeZero)
        player?.play()
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
        
        FirebaseController.shared.fetchComments(forMediaItemID: mediaItem.itemID, completion: { (comments) in
            self.numberOfCommentsLabel.isHidden = false
            self.numberOfCommentsLabel.text = "\(comments.count)"
        })
        
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
        self.view.layoutIfNeeded()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func photoTapped() {
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
        
        UIView.animate(withDuration: 0.2) {
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

extension MediaViewVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return mediaImageView
    }
}

//protocol MediaViewDelegate: class {
//    func presentMediaView(withImage image: UIImage)
//}

