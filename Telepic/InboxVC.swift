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

class InboxVC: UIViewController {

    var inboxItems = [InboxItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var emptyInboxImageView: UIImageView!
    @IBOutlet weak var emptyInboxLabel: UILabel!

    
    weak var delegate: ControlTabBarDelegate?
    var mediaItem: MediaItem?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
        
        tableView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInbox), name: Notifications.newInboxItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.didLoadInbox, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEmptyInboxView), name: Notifications.inboxIsEmpty, object: nil)

        FirebaseController.shared.loadInboxItems()
        FirebaseController.shared.fetchInboxItems()
        FirebaseController.shared.isInboxEmpty()
        
        tableView.reloadData()
        
        requestAuthorization()
    }
    
    @IBAction func exploreButtonTapped(_ sender: Any) {
        delegate?.moveToExploreTab()
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        let addFriendVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "AddFriendVC") as! AddFriendVC
        self.present(addFriendVC, animated: true, completion: nil)
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
        if !inboxItems.isEmpty {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
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
    
    func forwardItem(_ inboxItem: InboxItem) {
        let sendVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "SendVC") as! SendVC
        sendVC.inboxItemBeingSent = inboxItem
        sendVC.isForwardingItem = true
        present(sendVC, animated: true, completion: nil)
    }
    
    func recordUserLocation(forItemID itemID: String) {
        getUserLocation()
        
        // Add location to Array of coordinates for itemID in global mediaItems
        
        // Set the item in the current user's inbox to "opened"
        if let location = locationManager.location {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            FirebaseController.shared.setItemOpened(forItemID: itemID, latitude: lat, longitude: long)
        }
        
    }
    
    func segueToMapVC(withItemID itemID: String) {
        DispatchQueue.main.async {
            FirebaseController.shared.fetchMediaItem(forItemID: itemID, completion: { (mediaItem) in
                let mapNavVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapNavVC") as! UINavigationController
                let mapVC = mapNavVC.viewControllers.first as! MapVC
                mapVC.mediaItem = mediaItem
                self.present(mapNavVC, animated: true, completion: nil)
            })
        }
        //performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    func segueToProfileVC(withUID uid: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileVC
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                profileVC.userID = uid
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func segueToCommentsVC(withItemID itemID: String) {
        let commentsVC = UIStoryboard(name: "Comments", bundle: nil).instantiateInitialViewController() as! CommentsVC
        commentsVC.mediaItemID = itemID
        commentsVC.isModal = true
        self.present(commentsVC, animated: true, completion: nil)
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
