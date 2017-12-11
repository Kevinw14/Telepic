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

class TabBarController: UITabBarController {

    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
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

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //NotificationCenter.default.post(Notification(name: Notifications.stopPlayer))

        if viewController is ImagePickerVC {
            
            let gallery = GalleryController()
            gallery.delegate = self
            Gallery.Config.VideoEditor.maximumDuration = 30
            Gallery.Config.VideoEditor.savesEditedVideoToLibrary = false
            Gallery.Config.Camera.recordLocation = false
            Gallery.Config.VideoEditor.quality = AVAssetExportPresetHighestQuality
            present(gallery, animated: true, completion: nil)
            
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
                    let navController = UINavigationController(rootViewController: captionVC)
                    controller.present(navController, animated: true, completion: nil)
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
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
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

        if let (imageData, uti) = images[0].uiImageData() {
            if UTTypeConformsTo(uti as CFString, kUTTypeGIF) {
                if let gif = UIImage.gif(data: imageData) {
                    selectedImage = gif
                    captionVC.isGif = true
                    captionVC.data = imageData
                    captionVC.image = selectedImage
                    let navController = UINavigationController(rootViewController: captionVC)
                    controller.present(navController, animated: true, completion: nil)
                }
            } else {
                selectedImage = UIImage(data: imageData)!
                let filtersVC = FiltersVC(image: selectedImage!)
                let navController = UINavigationController(rootViewController: filtersVC)
                controller.present(navController, animated: true, completion: nil)
            }
            gallery = nil
        }
    }
    
    
}

extension TabBarController: UIVideoEditorControllerDelegate {
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        print(editedVideoPath)
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        print("cancelled")
    }
}
