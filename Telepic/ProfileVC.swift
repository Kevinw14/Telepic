//
//  ProfileVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/22/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth
import SVProgressHUD

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var numberOfFriendsLabel: UILabel!
    @IBOutlet weak var forwardsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var uploadsLabel: UILabel!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Constants
    let itemsPerRow: CGFloat = 3
    
    // Variables
    var imagePicker: UIImagePickerController!
    var thumbnails = [InboxItem]()
    var user: [String:Any]?
    var username: String?
    var userID: String?
    var uploads = [Upload]()
    var forwards = 0
    var isCurrentUser = true
    var fromMediaView = false
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    // Set up left and right nav bar buttons for viewing another user's profile.
    lazy var backBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    lazy var addFriendBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "addFriend"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        btn.addTarget(self, action: #selector(showAddFriendAlert), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    // Set up left and right nav bar buttons for viewing current user's profile.
    lazy var settingsBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goToSettingsVC), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    lazy var groupBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "groupAdd"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        btn.addTarget(self, action: #selector(goToGroupsVC), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.scrollView.contentInsetAdjustmentBehavior = .never

        self.addBioButton.isHidden = true
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(setUpViews), name: Notifications.didLoadUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUploads), name: Notifications.didUploadMedia, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUserData), name: Notifications.userDataChanged, object: nil)
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "thumbnailCell")
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if user is currently viewing their own profile.
        if !fromMediaView {
            if isCurrentUser {
                guard let currentUID = Auth.auth().currentUser?.uid else { return }
                self.userID = currentUID
                self.username = Auth.auth().currentUser?.displayName!
                DispatchQueue.main.async {
                    FirebaseController.shared.fetchUser(uid: currentUID, completion: { (user) in
                        self.user = user
                        NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
                    })
                }
            }
        } else {
            fromMediaView = false
        }
        
        self.edgesForExtendedLayout = []
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        let titleAttrs = [
            NSAttributedStringKey.foregroundColor: UIColor(hexString: "333333"),
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        
        self.tabBarController?.tabBar.isHidden = false
        
        setUpBarButtons()
    }
    
    @objc func goBack() {
        if let navCount = navigationController?.viewControllers.count {
            if navCount >= 2 {
                let previousVC = self.navigationController?.viewControllers[navCount - 2]
                if previousVC is MediaViewVC || previousVC is InboxVC {
                    FirebaseController.shared.isZooming = false
                }
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
        FirebaseController.shared.isZooming = true
    }
    
    @objc func goToGroupsVC() {
        let groupsVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: Identifiers.groupsVC) as! GroupsVC
        self.navigationController?.pushViewController(groupsVC, animated: true)
    }
    
    @objc func showAddFriendAlert() {
        let alertController = UIAlertController(title: "Add Friend", message: "Would you like to send a friend request?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler: { (_) in
            print("Add friend")
            guard let uid = self.userID else { return }
            FirebaseController.shared.sendFriendRequest(toUID: uid)
            self.navigationItem.rightBarButtonItem = nil
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showSuccess(withStatus: "Friend request sent!")
            SVProgressHUD.dismiss(withDelay: 1.5)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addBioButtonTapped(_ sender: Any) {
        let editProfileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        
        editProfileVC.username = self.username
        editProfileVC.bio = self.bioLabel.text
        
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @IBAction func friendsButtonTapped(_ sender: Any) {
        let friendListVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: Identifiers.friendListVC) as! FriendListVC
        guard let id = userID else { return }
        FirebaseController.shared.fetchFriends(uid: id)
        
        self.navigationController?.pushViewController(friendListVC, animated: true)
    }
    
    @objc func goToSettingsVC() {
        let settingsVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: Identifiers.settingsVC) as! SettingsVC
        settingsVC.user = user
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func setUpBarButtons() {
        if self.isCurrentUser {
            self.navigationItem.leftBarButtonItem = settingsBarButton
            self.navigationItem.rightBarButtonItem = groupBarButton
        } else {
            self.navigationItem.leftBarButtonItem = backBarButton
            if self.userID == Auth.auth().currentUser?.uid {
                self.navigationItem.rightBarButtonItem = nil
            }
            //self.navigationItem.rightBarButtonItem = addFriendBarButton
        }
    }
    
    @objc func setUpViews() {
        self.coverView.isHidden = false
        SVProgressHUD.show()
        self.setUpBarButtons()
        if self.username != nil && self.navigationItem.title != self.username!{ self.navigationItem.title = self.username! }
        
        // Firebase loaded the current user
        if let userDict = self.user {
            
            if let uploadsDict = userDict["uploads"] as? [String:[String:Any]] {
                var uploads = [Upload]()
                for (key, value) in uploadsDict {
                    let upload = Upload(uid: key, dict: value)
                    uploads.append(upload)
                }
                self.uploads = uploads.sorted { $0.timestamp > $1.timestamp }
                self.uploadsLabel.text = "\(uploads.count)"
                self.collectionView.reloadData()
            }
            
            let username = userDict["username"] as! String
            let avatarURL = userDict["avatarURL"] as? String ?? "n/a"
            
            if let forwards = userDict["forwardCount"] as? Int { self.forwards = forwards }
            if let friends = userDict["friends"] as? [String:Any] {
                self.numberOfFriendsLabel.text = "\(friends.count)"
                if friends[(Auth.auth().currentUser?.uid)!] == nil && !self.isCurrentUser && self.userID != Auth.auth().currentUser?.uid {
                    self.navigationItem.rightBarButtonItem = self.addFriendBarButton
                }
            }
            
            self.navigationItem.title = username
            
            if let bio = userDict["bio"] as? String {
                self.bioLabel.text = bio
                if isCurrentUser { self.addBioButton.isHidden = true }
            } else {
                // Add a button that takes user to their settings page edit bio screen
                if isCurrentUser { self.addBioButton.isHidden = false }
            }
            
            self.forwardsLabel.text = "\(self.forwards)"
            
            let url = URL(string: avatarURL)
            self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            self.coverView.isHidden = true
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func getUploads() {
        if let uid = Auth.auth().currentUser?.uid {
            
            FirebaseController.shared.fetchUser(uid: uid, completion: { (userDict) in
                self.user = userDict
                var uploads = [Upload]()
                if let uploadsDict = userDict["uploads"] as? [String:[String:Any]] {
                    for (key, value) in uploadsDict {
                        let upload = Upload(uid: key, dict: value)
                        uploads.append(upload)
                    }
                }
                if uploads.isEmpty {
                    self.uploads = uploads
                } else {
                    self.uploads = uploads.sorted { $0.timestamp > $1.timestamp }
                }
                
                let forwardCount = userDict["forwardCount"] as? Int ?? 0
                self.uploadsLabel.text = "\(uploads.count)"
                self.forwardsLabel.text = "\(forwardCount)"
                self.collectionView.reloadData()
                
            })
        }
    }
    
    @objc func getUserData() {
        if let uid = Auth.auth().currentUser?.uid {
            
            FirebaseController.shared.fetchUser(uid: uid) { (userDict) in
                self.user = userDict
                
                let username = userDict["username"] as! String
                let avatarURL = userDict["avatarURL"] as? String ?? "n/a"
                
                if let forwards = userDict["forwardCount"] as? Int { self.forwards = forwards }
                if let friends = userDict["friends"] as? [String:Any] { self.numberOfFriendsLabel.text = "\(friends.count)" }
                
                // Store in user defaults for quicker loading
                
                self.navigationItem.title = username
                if let bio = userDict["bio"] as? String {
                    self.bioLabel.text = bio
                    if self.isCurrentUser { self.addBioButton.isHidden = true }
                } else {
                    if self.isCurrentUser { self.addBioButton.isHidden = false }
                }
                self.forwardsLabel.text = "\(self.forwards)"
                
                let url = URL(string: avatarURL)
                self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func avatarButtonTapped(_ sender: Any) {
        if isCurrentUser {
            present(imagePicker, animated: true, completion: nil)
        } else {
            
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        if isCurrentUser {
            // segue to settings view
            let settingsContainerVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SettingsContainerVC") as! SettingsContainerVC
            self.navigationController?.pushViewController(settingsContainerVC, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
}

extension ProfileVC {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var avatarImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            avatarImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            avatarImage = possibleImage
        } else {
            return
        }
        
        picker.dismiss(animated: true) {
            var imageCropVC: RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: avatarImage, cropMode: .circle)
            imageCropVC.delegate = self
            self.present(imageCropVC, animated: true, completion: nil)
        }
    }
}

extension ProfileVC: RSKImageCropViewControllerDelegate {
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.avatarImageView.image = croppedImage
        dismiss(animated: true, completion: nil)
        
        let imageData = UIImagePNGRepresentation(croppedImage)
        FirebaseController.shared.uploadProfilePhoto(data: imageData!)
    }
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }

        let upload = uploads[indexPath.row]
        let urlString = upload.type == "video" ?  upload.thumbnailURL : upload.downloadURL
        
        let url = URL(string: urlString)
        
        if upload.type == "gif" {
            let gifImage = UIImage.gif(url: urlString)
            cell.thumbnailImageView.image = gifImage
        } else {
            
            cell.thumbnailImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if upload.type == "video" {
                    cell.playButton.isHidden = false
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell else { return }
        
        if let image = cell.thumbnailImageView {
            FirebaseController.shared.photoToPresent = image
            FirebaseController.shared.fetchMediaItem(forItemID: uploads[indexPath.row].uid, completion: { (item) in
                FirebaseController.shared.currentMediaItem = item
                
                NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
            })
            self.presentMediaViewVC()
            self.fromMediaView = true
        }
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace: CGFloat = 2.0
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension ProfileVC: PresentMediaDelegate {
    @objc func presentMediaViewVC() {
        guard let image = FirebaseController.shared.photoToPresent?.image else { return }
        self.navigationController?.navigationBar.isHidden = true
        let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mediaViewVC) as! MediaViewVC
        mediaViewVC.hidesBottomBarWhenPushed = true
        self.hidesBottomBarWhenPushed = true
        mediaViewVC.photo = image
        self.navigationController?.pushViewController(mediaViewVC, animated: true)
    }
}

extension ProfileVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return FirebaseController.shared.photoToPresent ?? nil
    }
}
