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
import Kingfisher

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
    var comments: [Comment] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BoxCell.self, forCellReuseIdentifier: "inboxCell")
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications { FirebaseController.shared.saveToken() }
        
        SVProgressHUD.show()
        
        tableView.isHidden = true
        emptyInboxLabel.isHidden = true
        emptyInboxImageView.isHidden = true
        exploreButton.isHidden = true

        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInbox), name: Notifications.newInboxItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEmptyInboxView), name: Notifications.inboxIsEmpty, object: nil)

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
        
        FirebaseController.shared.isInboxEmpty()
        self.inboxItems = FirebaseController.shared.inboxItems
        
        if self.inboxItems.isEmpty {
            self.tableView.isHidden = true
            showEmptyInboxView()
        }
        
        tableView.reloadData()
        
//        let titleAttrs = [
//            NSAttributedStringKey.foregroundColor: UIColor(hexString: "10BB6C"),
//            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: 24)
//        ]
        
        let titleAttrs = [
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "2DAAFC"),
            NSAttributedString.Key.font: UIFont(name: "ProximaNova-Bold", size: 32)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        self.navigationItem.title = "telepic"
        self.edgesForExtendedLayout = []
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(Notification(name: Notifications.stopPlayer))
    }
    
    @IBAction func exploreButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func updateInbox() {
        self.tableView.isHidden = false
        emptyInboxLabel.isHidden = true
        emptyInboxImageView.isHidden = true
        exploreButton.isHidden = true
        
        SVProgressHUD.dismiss()
        inboxItems = FirebaseController.shared.inboxItems
        self.tableView.reloadData()
    }
    
    @objc func showEmptyInboxView() {
        SVProgressHUD.dismiss()
        emptyInboxLabel.isHidden = false
        emptyInboxImageView.isHidden = false
        exploreButton.isHidden = false
    }
}

extension InboxVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let inboxItem = inboxItems[indexPath.row]
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as? BoxCell else { return UITableViewCell() }

        let inboxItem = inboxItems[indexPath.row]
        let cell = BoxCell(inboxItem: inboxItem,parentTableView: self.tableView, reuseIdentifier: "inboxCell")
        cell.photoImageView.kf.indicatorType = .activity
//        cell.inboxItem = inboxItem
//        cell.setUpCell()
//        cell.sizeToFit()
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! BoxCell).photoImageView.kf.cancelDownloadTask()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BoxCell else { return }
        let inboxItem = cell.inboxItem 
        
//        if inboxItem.caption == nil || inboxItem.caption == "" {
//            cell.captionLabel.isHidden = true
//        }
        
        if inboxItem.type == "photo" {
//            guard let inboxItem = inboxItem else { return }
            let photoURL = URL(string: inboxItem.downloadURL)
            cell.photoImageView.kf.setImage(with: photoURL,
                                            placeholder: nil,
                                            options: [.transition(ImageTransition.fade(1))],
                                            progressBlock: nil,
                                            completionHandler: { (image, error, cacheType, imageURL) in
                                                print("\(indexPath.row + 1): Finished")
            })
            cell.playButton.isHidden = true
        } else if inboxItem.type == "gif" {
//            guard let inboxItem = inboxItem else { return }
            let url = URL(string: inboxItem.downloadURL)
            cell.photoImageView.kf.setImage(with: url)
            cell.playButton.isHidden = true
        } else {
//            let thumbnailURL = URL(string: inboxItem.thumbnailURL)
//            cell.photoImageView.kf.setImage(with: thumbnailURL)
//            cell.messageLabel.text = "Video Received!"
//            cell.playButton.isHidden = false
//            cell.photoImageView.addSubview(activityIndicatorView)
//
//            activityIndicatorView.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
//            activityIndicatorView.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
//            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//            activityIndicatorView.stopAnimating()
            
            cell.photoImageView.addSubview(cell.playButton)
            cell.playButton.isUserInteractionEnabled = false
            cell.playButton.centerXAnchor.constraint(equalTo: cell.photoImageView.centerXAnchor).isActive = true
            cell.playButton.centerYAnchor.constraint(equalTo: cell.photoImageView.centerYAnchor).isActive = true
            cell.playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            cell.playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let inboxItem = inboxItems[indexPath.row]
        
        if inboxItem.caption != nil && inboxItem.caption != "" {
            return 610
        } else {
            return 580
        }
    }
}

extension InboxVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let indexes = indexPaths.compactMap { $0.row }
        
        let urls = indexes.map { URL(string: self.inboxItems[$0].downloadURL)! }
        
        ImagePrefetcher(urls: urls).start()
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
        let sendVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "SendVC") as! SendVC
        sendVC.inboxItemBeingSent = inboxItem
        sendVC.isForwardingItem = true
        sendVC.isModal = true
        present(sendVC, animated: true, completion: nil)
    }
    
    func recordUserLocation(cell: UITableViewCell, item: InboxItem) {
        getUserLocation()
        
        // Add location to Array of coordinates for itemID in global mediaItems
        
        // Set the item in the current user's inbox to "opened"
        if let location = locationManager.location {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            FirebaseController.shared.setItemOpened(inboxItem: item, latitude: lat, longitude: long)
            let index = tableView.indexPath(for: cell)?.row
            
            FirebaseController.shared.inboxItems[index!].opened = true
            tableView.reloadData()
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
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()?.children[0] as! ProfileVC
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
        } else {
            requestAuthorization()
            getUserLocation()
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
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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

extension InboxVC: CaptionLabelDelegate {
    func didTapURL(captionLabel: CaptionLabel, url: URL) {
       let webViewController = WebViewController(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    func didTapCustom(captionLabel: CaptionLabel) {
        tableView.beginUpdates()
        captionLabel.text = captionLabel.pretext
        tableView.endUpdates()
    }
}

extension InboxVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return FirebaseController.shared.photoToPresent ?? nil
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
