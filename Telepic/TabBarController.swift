//
//  TabBarController.swift
//  Telepic
//
//  Created by Michael Bart on 11/9/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import AVKit
import SVProgressHUD
import FirebaseAuth
import MobileCoreServices
import FBSDKShareKit
import FBSDKCoreKit
import YPImagePicker

class TabBarController: UITabBarController, FBSDKAppInviteDialogDelegate {

    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    var inviteFriendsAlert = false
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = zoomTransitioningDelegate
        delegate = self
        
        // Fetch data from Firebase
        FirebaseController.shared.fetchFriendRequests()
        //FirebaseController.shared.fetchNotifications()
        if let uid = Auth.auth().currentUser?.uid { FirebaseController.shared.fetchFriends(uid: uid)}
        
        // Notifications
        //NotificationCenter.default.addObserver(self, selector: #selector(presentMediaViewVC), name: Notifications.presentMedia, object: nil)
        
        FirebaseController.shared.fetchNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: Notifications.updateBadge, object: nil)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        FirebaseController.shared.fetchAvatarImage(forUID: currentUser.uid) { (avatarURL) in
        let url = URL(string: avatarURL)!
            FirebaseController.shared.fetchAvatarImage(creatorAvatarURL: url, completion: { (image) in
                
            })
            
        }
    }
    

    
    @objc func updateBadge() {
        if FirebaseController.shared.tabBadge > 0 {
            tabBar.items?[3].badgeValue = "\(FirebaseController.shared.tabBadge)"
        } else {
            tabBar.items?[3].badgeValue = nil
        }
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print(results)
        SVProgressHUD.showSuccess(withStatus: "Invites sent!")
        SVProgressHUD.dismiss(withDelay: 0.4)
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Did fail with error")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if self.inviteFriendsAlert {
            self.inviteFriendsAlert = false
            let ac = UIAlertController(title: "Invite Friends", message: "Send an app invite to your friends on Facebook.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                
                let inviteDialog = FBSDKAppInviteDialog()
                
                if inviteDialog.canShow {
                    let appLinkURL = URL(string: "https://itunes.apple.com/app/id1279816444")
                    let previewImageURL = URL(string: "")
                    
                    let inviteContent = FBSDKAppInviteContent()
                    inviteContent.appLinkURL = appLinkURL
                    inviteContent.appInvitePreviewImageURL = previewImageURL
                    
                    inviteDialog.content = inviteContent
                    inviteDialog.delegate = self
                    inviteDialog.show()
                }
            }))
            ac.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //NotificationCenter.default.post(Notification(name: Notifications.stopPlayer))

//        if let navigationController = viewControllers?[selectedIndex] as? UINavigationController {
//            for myController in navigationController.viewControllers.flatMap({ $0 as? ExploreVC }) {
//                myController.dismissSearch()
//            }
//        }
        
        if viewController is ImagePickerVC {
            var config = YPImagePickerConfiguration()
            config.library.onlySquare = false
            config.onlySquareImagesFromCamera = true
            config.targetImageSize = .original
            config.usesFrontCamera = true
            config.showsFilters = true
            config.shouldSaveNewPicturesToAlbum = true
            config.video.compression = AVAssetExportPresetHighestQuality
            config.albumName = "MyGreatAppName"
            config.screens = [.library, .photo, .video]
            config.startOnScreen = .photo
            config.video.recordingTimeLimit = 10
            config.video.libraryTimeLimit = 20
            config.showsCrop = .rectangle(ratio: (16/16))
            config.wordings.libraryTitle = "Gallery"
            config.hidesStatusBar = false
            config.bottomMenuItemUnSelectedColour = UIColor.gray
            config.bottomMenuItemSelectedColour = UIColor.black
            config.colors.tintColor = UIColor.blue
            
            
           let pickerOne = YPImagePicker(configuration: config)

            
            let picker = YPImagePicker()
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    print(photo.fromCamera) // Image source (camera or library)
                    print(photo.image) // Final image selected by the user
                    print(photo.originalImage) // original image selected by the user, unfiltered
                    print(photo.modifiedImage) // Transformed image, can be nil
                    print(photo.exifMeta) // Print exif meta data of original image.
                    
                   
                    picker.dismiss(animated: true, completion: {
                        let captionVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: Identifiers.captionVC) as! CaptionVC
                        captionVC.image = photo.image
                        let navController = UINavigationController(rootViewController: captionVC)
                        self.present(navController, animated: true, completion: nil)
                    })
                }
                if let video = items.singleVideo {
                    print(video.fromCamera)
                    print(video.thumbnail)
                    print(video.url)
                    
                    picker.dismiss(animated: true, completion: {
                        let captionVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: Identifiers.captionVC) as! CaptionVC
                        captionVC.videoURL = video.url
                        captionVC.thumbnail = video.thumbnail
                        let navController = UINavigationController(rootViewController: captionVC)
                        self.present(navController, animated: true, completion: nil)
                    })
                }

                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)

            return false
        }
        return true
    }
}

extension PHAsset {
    
    var image : UIImage {
        var thumbnail: UIImage? = nil
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        
//        options.progressHandler = {  (progress, error, stop, info) in
//            print("progress: \(progress)")
//        }
//        
        PHImageManager.default().requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: options) { (image, info) in
            print("dict: \(String(describing: info))")
            print("image size: \(String(describing: image?.size))")
            thumbnail = image!
        }
        return thumbnail!
    }
}

