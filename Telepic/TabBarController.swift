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
import Gallery
import MobileCoreServices
import FBSDKShareKit
import FBSDKCoreKit
import YPImagePicker

class TabBarController: UITabBarController, FBSDKAppInviteDialogDelegate {

    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
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
            config.showsCrop = .rectangle(ratio: (16/9))
            config.wordings.libraryTitle = "Gallery"
            config.hidesStatusBar = false
            
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
            }
            present(picker, animated: true, completion: nil)

            return false
        }
        return true
    }
}

extension TabBarController: GalleryControllerDelegate {
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
//        controller.dismiss(animated: true) {
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.show(withStatus: "Loading video")
//        }
        let captionVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: Identifiers.captionVC) as! CaptionVC
        
        gallery = nil
        
        editor.edit(video: video) { (video, url) in
            DispatchQueue.main.async {
                if let tempPath = url {
                    captionVC.videoURL = tempPath
                    let thumbnail = self.getThumbnail(forURL: tempPath)
                    captionVC.thumbnail = thumbnail
                    controller.dismiss(animated: false, completion: nil)
                    let navController = UINavigationController(rootViewController: captionVC)
                    self.present(navController, animated: true, completion: nil)
//                    let controller = AVPlayerViewController()
//                    controller.player = AVPlayer(url: tempPath)
//                    let videoEditorController = UIVideoEditorController()
//                    videoEditorController.videoMaximumDuration = 30
//                    videoEditorController.videoPath = tempPath.absoluteString
//                    videoEditorController.navigationItem.rightBarButtonItem?.title = "Forward"
//                    self.present(videoEditorController, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.setBackgroundColor(.clear)
                }
            }
        }
    }

    func getThumbnail(forURL videoURL: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: videoURL)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        print("no lightbox")
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        //        controller.dismiss(animated: true, completion: nil)
        let captionVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: Identifiers.captionVC) as! CaptionVC
        var selectedImage: UIImage?
        
        let imageAsset = images[0].asset
        let image = imageAsset.image
//        let options = PHContentEditingInputRequestOptions()
        guard let imageData = image.pngData() else {return}
        
       if let imageType = imageAsset.value(forKey: "uniformTypeIdentifier") as? String  {
                
                if imageType == (kUTTypeGIF as String) {
                    debugPrint("This asset is a GIF👍")
                    if let gif = UIImage.gif(data: imageData) {
                        selectedImage = gif
                        captionVC.isGif = true
                        captionVC.data = imageData
                        captionVC.image = selectedImage
                        controller.dismiss(animated: false, completion: nil)
                        let navController = UINavigationController(rootViewController: captionVC)
                        self.present(navController, animated: true, completion: nil)
                    }
                } else {
                    selectedImage = UIImage(data: imageData)!
                    let filtersVC = FiltersVC(image: selectedImage!)
                    filtersVC.editButtonItem.isEnabled = true
                    
                
                    
                    controller.dismiss(animated: false, completion: nil)
                    let navController = UINavigationController(rootViewController: filtersVC)
                    self.present(navController, animated: true, completion: nil)
                }
                self.gallery = nil

                }
                
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

