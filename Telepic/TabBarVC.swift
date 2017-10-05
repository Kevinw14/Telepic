//
//  TabBarVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/14/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Fusuma

class TabBarVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabButtons: [UIButton]!
    
    var inboxVC: UIViewController!
    var exploreVC: UIViewController!
    var notificationsVC: UIViewController!
    var profileVC: UIViewController!
    
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inboxVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "inboxVC")
        exploreVC = UIStoryboard(name: "Explore", bundle: nil).instantiateViewController(withIdentifier: "exploreVC")
        notificationsVC = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "notificationsVC")
        profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileVC")
        
        viewControllers = [inboxVC, exploreVC, notificationsVC, profileVC]
        
        tabButtons[selectedIndex].isSelected = true
        tabButtonPressed(tabButtons[selectedIndex])
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
        
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
//        fusuma.availableModes = [.library, .camera, .video]
        fusuma.cropHeightRatio = 1.3
//        fusuma.allowMultipleSelection = false
        fusuma.hasVideo = true
        
        self.present(fusuma, animated: true, completion: nil)
        
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

extension TabBarVC: FusumaDelegate {
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        print("image selected")
        // present post preview vc
       
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        print("dismissed with image")
        let photoPreviewVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "photoPreviewVC") as! PhotoPreviewVC
        photoPreviewVC.selectedImage = image
        self.present(photoPreviewVC, animated: true, completion: nil)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        print("video completed")
    }
    
    func fusumaCameraRollUnauthorized() {
        print("camera roll unauthorized")
    }
}
