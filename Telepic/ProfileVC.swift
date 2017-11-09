//
//  ProfileVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/22/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Hero
import Kingfisher
import FirebaseAuth
import SVProgressHUD

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var numberOfFriendsLabel: UILabel!
    @IBOutlet weak var forwardsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var uploadsLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imagePicker: UIImagePickerController!
    var thumbnails = [InboxItem]()
    var user: [String:Any]?
    var userID: String?
    var uploads = [Upload]()
    var forwards = 0
    var isCurrentUser = false
   
    let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isCurrentUser {
            SVProgressHUD.show()
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            DispatchQueue.main.async {
                FirebaseController.shared.fetchUser(uid: currentUID, completion: { (user) in
                    self.user = user
                    NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
                })
            }
        }
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    
        self.groupButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUpViews), name: Notifications.didLoadUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUploads), name: Notifications.didUploadMedia, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUserData), name: Notifications.userDataChanged, object: nil)
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "thumbnailCell")
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCurrentUser {
            self.groupButton.isHidden = false
            self.settingsButton.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
            self.groupButton.setImage(#imageLiteral(resourceName: "groupAdd"), for: .normal)
        }
    }
    
    @objc func setUpViews() {
        DispatchQueue.main.async {
            
            guard let userDict = self.user else { return }
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
            let bio = userDict["bio"] as? String ?? "Add a bio."
            
            if let forwards = userDict["forwardCount"] as? Int { self.forwards = forwards }
            if let friends = userDict["friends"] as? [String:Any] {
                self.numberOfFriendsLabel.text = "\(friends.count)"
                if friends[(Auth.auth().currentUser?.uid)!] == nil {
                    self.groupButton.isHidden = false
                }
            }
            
            // Store in user defaults for quicker loading
            
            self.usernameLabel.text = username
            self.bioLabel.text = bio
            self.forwardsLabel.text = "\(self.uploads.count + self.forwards)"
            
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
                
                if let uploadsDict = userDict["uploads"] as? [String:[String:Any]] {
                    var uploads = [Upload]()
                    for (key, value) in uploadsDict {
                        let upload = Upload(uid: key, dict: value)
                        uploads.append(upload)
                    }
                    self.uploads = uploads.sorted { $0.timestamp > $1.timestamp }
                    self.uploadsLabel.text = "\(uploads.count)"
                    self.forwardsLabel.text = "\(uploads.count + self.forwards)"
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    @objc func getUserData() {
        if let uid = Auth.auth().currentUser?.uid {
            
            FirebaseController.shared.fetchUser(uid: uid) { (userDict) in
                self.user = userDict
                
                let username = userDict["username"] as! String
                let avatarURL = userDict["avatarURL"] as? String ?? "n/a"
                let bio = userDict["bio"] as? String ?? "Edit your profile to add a bio."
                
                if let forwards = userDict["forwardCount"] as? Int { self.forwards = forwards }
                if let friends = userDict["friends"] as? [String:Any] { self.numberOfFriendsLabel.text = "\(friends.count)" }
                
                // Store in user defaults for quicker loading
                
                self.usernameLabel.text = username
                self.bioLabel.text = bio
                self.forwardsLabel.text = "\(self.uploads.count + self.forwards)"
                
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
    
    @IBAction func groupButtonTapped(_ sender: Any) {
        if isCurrentUser {
            let groupsVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "GroupsVC") as! GroupsVC
            self.navigationController?.pushViewController(groupsVC, animated: true)
        } else {
            let alertController = UIAlertController(title: "Add Friend", message: "Would you like to send a friend request?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Send", style: .default, handler: { (_) in
                print("Add friend")
                guard let uid = self.userID else { return }
                FirebaseController.shared.sendFriendRequest(toUID: uid)
                self.groupButton.isHidden = true
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
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
        
        cell.thumbnailImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell else { return }
        
        if let image = cell.thumbnailImageView.image {
            FirebaseController.shared.fetchMediaItem(forItemID: uploads[indexPath.row].uid, completion: { (item) in
                FirebaseController.shared.currentMediaItem = item
                FirebaseController.shared.photoToPresent = cell.thumbnailImageView
                
                NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
            })
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
