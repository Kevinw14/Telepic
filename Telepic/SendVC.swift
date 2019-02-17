//
//  SendVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/17/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import SVProgressHUD

class SendVC: UIViewController {


    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var groupsButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var inboxItemBeingSent: InboxItem?
    var mediaItemBeingSent: MediaItem?
    var data: Data?
    var videoURL: URL?
    var caption: String?
    var isForwardingItem = false
    var isFromMapVC = false
    var currentType: String?
    var isModal = false
    var fromCaption = false
    
    var isSelectingGroups = false {
        didSet {
            setUpButtons()
        }
    }
    
    weak var selectFriendsVC: SendVCDelegate?
    weak var selectGroupsVC: SendVCDelegate?
    weak var pagingDelegate: PagingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        doneButton.setTitle("Foward", for: .normal)
        
        if let item = inboxItemBeingSent {
            FirebaseController.shared.fetchValidForwardTargets(itemID: item.itemID, creatorID: item.creatorID)
        }
        if let item = mediaItemBeingSent {
            FirebaseController.shared.fetchValidForwardTargets(itemID: item.itemID, creatorID: item.creatorID)
        }
        
        if !isForwardingItem {
            FirebaseController.shared.fetchFriends(uid: Auth.auth().currentUser!.uid)
            NotificationCenter.default.addObserver(self, selector: #selector(notifySelectFriendsVC), name: Notifications.didLoadFriends, object: nil)
        }
        
        if isModal {
            self.backButton.isHidden = true
        } else {
            self.closeButton.isHidden = true
        }
    }
    
    @objc func notifySelectFriendsVC() {
        FirebaseController.shared.validForwardTargets = FirebaseController.shared.friends
        NotificationCenter.default.post(name: Notifications.didLoadValidTargets, object: self)
    }
    
    @IBAction func friendsButtonTapped(_ sender: Any) {
        if isSelectingGroups {
            pagingDelegate?.previousPage()
            isSelectingGroups = false
        }
    }
    
    @IBAction func groupsButtonTapped(_ sender: Any) {
        if !isSelectingGroups {
            pagingDelegate?.nextPage()
            isSelectingGroups = true
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        var selectedFriendIDs: [String]?
        
        if isSelectingGroups {
            selectedFriendIDs = selectGroupsVC?.getSelectedFriendIDs()
            // loop through group members to get friend ids to send to
        } else {
            selectedFriendIDs = selectFriendsVC?.getSelectedFriendIDs()
        }
        
        if selectedFriendIDs != nil {
            
            if isForwardingItem {
                
                if inboxItemBeingSent == nil {
                    if let item = mediaItemBeingSent {
                        FirebaseController.shared.forwardMediaItem(item, toFriendIDs: selectedFriendIDs!)
                    }
                } else {
                    FirebaseController.shared.forwardInboxItem(inboxItemBeingSent!, toFriendIDs: selectedFriendIDs!)
                }
                
            } else {
                getUserLocation()
                
                // Set the item in the current user's inbox to "opened"
                if let location = locationManager.location {
                    let lat = location.coordinate.latitude
                    let long = location.coordinate.longitude
                    
                    if videoURL != nil, let data = data {
                        FirebaseController.shared.sendVideo(caption: caption ?? nil, videoURL: videoURL!, thumbnailData: data, toUserIDs: selectedFriendIDs!, currentLocation: ["latitude": lat, "longitude": long])
                    } else if let data = data {
                        guard let type = currentType else { return }
                        FirebaseController.shared.sendPhoto(caption: caption ?? nil, data: data, type: type, toUserIDs: selectedFriendIDs!, currentLocation: ["latitude": lat, "longitude": long])
                    }
                }
            }
        } else {
            getUserLocation()
            
            // Set the item in the current user's inbox to "opened"
            if let location = locationManager.location {
                let lat = location.coordinate.latitude
                let long = location.coordinate.longitude
                if videoURL != nil, let data = data {
                    FirebaseController.shared.postVideo(caption: caption ?? nil, videoURL: videoURL!, thumbnailData: data, currentLocation: ["latitude": lat, "longitude": long])
                } else if let data = data {
                    guard let type = currentType else { return }
                    FirebaseController.shared.postPhoto(caption: caption ?? nil, data: data, type: type, currentLocation: ["latitude": lat, "longitude": long])
                }
            }
        }

        if isModal || fromCaption {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func setUpButtons() {
        switch isSelectingGroups {
        case true:
            self.friendsButton.setTitleColor(.lightGray, for: .normal)
            self.groupsButton.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        case false:
            self.friendsButton.setTitleColor(UIColor(hexString: "333333"), for: .normal)
            self.groupsButton.setTitleColor(.lightGray, for: .normal)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSendPageVC" {
            if let pageVC = segue.destination as? SendPageVC {
                pagingDelegate = pageVC
                guard let selectFriendsVC = pageVC.orderedViewControllers.first as? SelectFriendsVC else { return }
                self.selectFriendsVC = selectFriendsVC
                guard let selectGroupsVC = pageVC.orderedViewControllers.last as? SelectGroupsVC else { return }
                self.selectGroupsVC = selectGroupsVC
            }
        }
    }

}

extension SendVC: CLLocationManagerDelegate {
    
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

protocol SendVCDelegate: class {
    func getSelectedFriendIDs() -> [String]?
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
