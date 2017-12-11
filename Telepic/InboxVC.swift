//
//  InboxVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import SVProgressHUD
import FirebaseAuth
import Stevia

class InboxVC: UIViewController {

    var inboxItems = [InboxItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var emptyInboxImageView: UIImageView!
    @IBOutlet weak var emptyInboxLabel: UILabel!
    
    weak var delegate: ControlTabBarDelegate?
    var mediaItem: MediaItem?
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications { FirebaseController.shared.saveToken() }
                
        SVProgressHUD.show()
        
        tableView.isHidden = true
        emptyInboxLabel.isHidden = true
        emptyInboxImageView.isHidden = true
        exploreButton.isHidden = true
//        tableView.estimatedRowHeight = 509
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInbox), name: Notifications.newInboxItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.didLoadInbox, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEmptyInboxView), name: Notifications.inboxIsEmpty, object: nil)

        FirebaseController.shared.loadInboxItems()
        FirebaseController.shared.fetchInboxItems()
        
        requestAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseController.shared.loadInboxItems()
        FirebaseController.shared.isInboxEmpty()
        self.inboxItems = FirebaseController.shared.inboxItems
        tableView.estimatedRowHeight = 530
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.reloadData()
        
        let titleAttrs = [
            NSAttributedStringKey.foregroundColor: UIColor(hexString: "10BB6C"),
            NSAttributedStringKey.font: UIFont(name: "Nunito-Bold", size: 24)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        self.navigationItem.title = "telepic"
        self.edgesForExtendedLayout = []
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
//        let btn = UIButton(type: .system)
//        btn.setImage(#imageLiteral(resourceName: "addFriend"), for: .normal)
//        //btn.sizeToFit()
//        btn.height(40)
//        btn.width(40)
//        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
//        btn.addTarget(self, action: #selector(addFriendVCSegue), for: .touchUpInside)
//        let barBtn = UIBarButtonItem(customView: btn)
//
//        self.navigationItem.rightBarButtonItem = barBtn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(Notification(name: Notifications.stopPlayer))
    }
    
    @IBAction func exploreButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    
    @objc func addFriendVCSegue() {
        let addFriendVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.addFriendVC)
        self.navigationController?.pushViewController(addFriendVC, animated: true)
    }
    
    @objc func updateInbox() {
        self.tableView.isHidden = false
        emptyInboxLabel.isHidden = true
        emptyInboxImageView.isHidden = true
        exploreButton.isHidden = true
        
        SVProgressHUD.dismiss()
        inboxItems = FirebaseController.shared.inboxItems
        //self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.tableView.reloadData()
    }
    
    @objc func reloadData() {
        inboxItems = FirebaseController.shared.inboxItems
        if self.inboxItems.isEmpty { self.showEmptyInboxView(); self.tableView.isHidden = true }
        if !inboxItems.isEmpty {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        SVProgressHUD.dismiss()
    }
    
    @objc func showEmptyInboxView() {
        SVProgressHUD.dismiss()
        emptyInboxLabel.isHidden = false
        emptyInboxImageView.isHidden = false
        exploreButton.isHidden = false
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}

extension InboxVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as? InboxCell else { return UITableViewCell() }
        
        cell.inboxItem = inboxItems[indexPath.row]
        
        cell.setUpCell()
        
        cell.delegate = self
        
        return cell
    }
}

extension InboxVC: InboxItemDelegate {
    
    func goFullscreen(_ imageView: UIImageView) {
        let fullscreenView = UIImageView(image: imageView.image)
        fullscreenView.frame = UIScreen.main.bounds
        fullscreenView.backgroundColor = .black
        fullscreenView.contentMode = .scaleAspectFit
        fullscreenView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreen))
        fullscreenView.addGestureRecognizer(tapGesture)
        self.view.addSubview(fullscreenView)
    }
    
    @objc func dismissFullscreen(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    func presentVideoFullScreen(controller: AVPlayerViewController) {
        self.present(controller, animated: true) {
            controller.player?.play()
        }
    }
    
    func forwardItem(_ inboxItem: InboxItem, cell: UITableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        FirebaseController.shared.inboxItems.remove(at: index!)
        let sendVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "SendVC") as! SendVC
        sendVC.inboxItemBeingSent = inboxItem
        sendVC.isForwardingItem = true
        present(sendVC, animated: true, completion: nil)
    }
    
    func recordUserLocation(item: InboxItem) {
        getUserLocation()
        
        // Add location to Array of coordinates for itemID in global mediaItems
        
        // Set the item in the current user's inbox to "opened"
        if let location = locationManager.location {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            FirebaseController.shared.setItemOpened(inboxItem: item, latitude: lat, longitude: long)
        }
        
    }
    
    func segueToMapVC(withItemID itemID: String) {
        let mapVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mapVC) as! MapVC
        FirebaseController.shared.fetchMediaItem(forItemID: itemID, completion: { (mediaItem) in
            mapVC.mediaItem = mediaItem
        })
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func segueToProfileVC(withUID uid: String, username: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()?.childViewControllers[0] as! ProfileVC
        profileVC.userID = uid
        if Auth.auth().currentUser!.uid != uid {
            profileVC.isCurrentUser = false
            profileVC.username = username
        }
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        FirebaseController.shared.isZooming = false
        self.navigationController?.pushViewController(profileVC, animated: true)
        FirebaseController.shared.isZooming = true
    }
    
    func segueToCommentsVC(withItemID itemID: String) {
        let commentsVC = UIStoryboard(name: "Comments", bundle: nil).instantiateViewController(withIdentifier: Identifiers.commentsVC) as! CommentsVC
        commentsVC.mediaItemID = itemID
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
}

protocol ControlTabBarDelegate: class {
    func moveToExploreTab()
}

extension InboxVC: CLLocationManagerDelegate {
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            
            // We only want to request a one-time delivery of the user's location
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled", message: "We need your location to record where items in your inbox are opened.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension InboxVC: PresentMediaDelegate {
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

extension InboxVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return FirebaseController.shared.photoToPresent!
    }
}

