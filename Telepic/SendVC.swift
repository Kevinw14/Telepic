//
//  SendVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/17/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import CoreLocation

class SendVC: UIViewController {


    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var groupsButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var inboxItemBeingSent: InboxItem?
    var data: Data?
    var videoURL: URL?
    var isForwardingItem = false
    var isFromMapVC = false
    
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

        setNeedsStatusBarAppearanceUpdate()
        
        if isForwardingItem { doneButton.setTitle("Forward", for: .normal) }
        
//        if let itemID = inboxItemBeingSent?.itemID {
//            FirebaseController.shared.fetchReceivableFriendIDs(forItemID: itemID)
//        }
        
        FirebaseController.shared.fetchFriends()
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
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
        if isFromMapVC {
            performSegue(withIdentifier: "unwindToMapVCFromSendVC", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        var selectedFriendIDs: [String]?
        
        if isSelectingGroups {
            selectedFriendIDs = selectGroupsVC?.getSelectedFriendIDs()
            // loop through group members to get friend ids to send to
        } else {
            selectedFriendIDs = selectFriendsVC?.getSelectedFriendIDs()
        }
        
        guard selectedFriendIDs != nil else { return }
        
        if isForwardingItem {
            
            guard let item = inboxItemBeingSent else { return }
            
            FirebaseController.shared.forwardInboxItem(item, toFriendIDs: selectedFriendIDs!)
            
        } else {
            getUserLocation()
            
            // Set the item in the current user's inbox to "opened"
            if let location = locationManager.location, let data = data {
                let lat = location.coordinate.latitude
                let long = location.coordinate.longitude
                
                if videoURL != nil {
                    FirebaseController.shared.sendVideo(videoURL: videoURL!, thumbnailData: data, toUserIDs: selectedFriendIDs!, currentLocation: ["latitude": lat, "longitude": long])
                } else {
                    FirebaseController.shared.sendPhoto(data: data, toUserIDs: selectedFriendIDs!, currentLocation: ["latitude": lat, "longitude": long])
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
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

protocol SendVCDelegate: class {
    func getSelectedFriendIDs() -> [String]?
}
