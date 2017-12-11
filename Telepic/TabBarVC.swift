//
//  TabBarVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/14/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth

class TabBarVC: UIViewController, ControlTabBarDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var notificationsBadge: UIView!
    
    var inboxVC: InboxVC!
    var exploreVC: UIViewController!
//    var notificationsVC: UIViewController!
    var profileVC: UIViewController!
    var inboxNavController: UIViewController!
    
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    let animator = ImageAnimator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseController.shared.fetchFriendRequests()
        updateBadge()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: Notifications.newEventNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentMediaViewVC), name: Notifications.presentMedia, object: nil)
        
        notificationsBadge.layer.cornerRadius = notificationsBadge.frame.width / 2
        
        inboxVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "inboxVC") as! InboxVC
        inboxVC.delegate = self
        let inboxNavController = UINavigationController(rootViewController: inboxVC)
        inboxNavController.setNavigationBarHidden(true, animated: false)
        
        exploreVC = UIStoryboard(name: "Explore", bundle: nil).instantiateViewController(withIdentifier: "exploreVC")
        
        //notificationsVC = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "notificationsVC")
        //let tabVC = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "TabVC") as! TabVC
        let tabNavVC = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "TabNavVC") as! UINavigationController
        
        profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileVC")
        let profileNavController = UINavigationController(rootViewController: profileVC)
        profileNavController.setNavigationBarHidden(true, animated: false)
        
        viewControllers = [inboxNavController, exploreVC, tabNavVC, profileNavController]
        
        tabButtons[selectedIndex].isSelected = true
        tabButtonPressed(tabButtons[selectedIndex])
        
        //FirebaseController.shared.fetchNotifications()
        //FirebaseController.shared.fetchFriends()
        
        animator.dismissCompletion = {
            FirebaseController.shared.photoToPresent?.isHidden = false
        }
    }
    
    @IBAction func tabButtonPressed(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        tabButtons[previousIndex].isSelected = false
        
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        sender.isSelected = true
        
        if let vc = viewControllers[selectedIndex] as? UINavigationController {
            if let profileVC = vc.viewControllers[0] as? ProfileVC {
                profileVC.isCurrentUser = true
            }
            addChildViewController(vc)
            vc.view.frame = contentView.bounds
            contentView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        } else {
            let vc = viewControllers[selectedIndex]
            addChildViewController(vc)
            vc.view.frame = contentView.bounds
            contentView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (_) in
            self.checkPermission()
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = ["public.image", "public.movie"]
            
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            let cameraVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "cameraVC")
            self.present(cameraVC, animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func updateBadge() {
        if FirebaseController.shared.eventNotifications.isEmpty {
            self.notificationsBadge.isHidden = true
        } else {
            self.notificationsBadge.isHidden = false
        }
    }
    
    func moveToExploreTab() {
        let previousIndex = 0
        selectedIndex = 1
        
        tabButtons[previousIndex].isSelected = false
        
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        tabButtons[selectedIndex].isSelected = true
        
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
}

extension TabBarVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL = info["UIImagePickerControllerReferenceURL"] as? URL {
            self.dismiss(animated: true, completion: {
                let newVC = VideoVC(videoURL: videoURL)
                self.present(newVC, animated: true, completion: nil)
            })
        }
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.dismiss(animated: true, completion: {
                let newVC = PhotoVC(image: image)
                self.present(newVC, animated: true, completion: nil)
            })
        }
    }
}


extension TabBarVC: UIViewControllerTransitioningDelegate {
    @objc func presentMediaViewVC() {
        guard let image = FirebaseController.shared.photoToPresent?.image else { return }
        
        let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: "MediaViewVC") as! MediaViewVC
        mediaViewVC.photo = image
        mediaViewVC.transitioningDelegate = self
        
        present(mediaViewVC, animated: false, completion: nil)
        
    }
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //animator.originFrame = FirebaseController.shared.photoToPresent!.superview!.convert(FirebaseController.shared.photoToPresent!.frame, to: nil)
        animator.presenting = true
//        FirebaseController.shared.photoToPresent!.isHidden = true
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
}
