//
//  NotificationsVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/26/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import FirebaseAuth

class NotificationsVC: TabChildVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyNotificationsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !FirebaseController.shared.eventNotifications.isEmpty {
            emptyNotificationsView.isHidden = true
        }
        
        // Fetch data from Firebase
        FirebaseController.shared.fetchFriendRequests()
        
        if let uid = Auth.auth().currentUser?.uid { FirebaseController.shared.fetchFriends(uid: uid)}
        
        NotificationCenter.default.addObserver(self, selector: #selector(emptyNotifications), name: Notifications.emptyNotifications, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notifications.newEventNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notifications.didLoadFriendRequests, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.reloadNotifications, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseController.shared.tabBadge = 0
        
        FirebaseController.shared.markNotificationsAsRead()
        //FirebaseController.shared.fetchNotifications()
//        self.navigationController?.navigationBar.isHidden = true
//        self.edgesForExtendedLayout = []
    }
    
    @objc func updateData() {
        //FirebaseController.shared.markNotificationsAsRead()
        emptyNotificationsView.isHidden = true
        tableView.reloadData()
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }

    @objc func emptyNotifications() {
        emptyNotificationsView.isHidden = false
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

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.eventNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationCell else { return UITableViewCell() }
        
        cell.notification = FirebaseController.shared.eventNotifications[indexPath.row]
        cell.setUp()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = FirebaseController.shared.eventNotifications[indexPath.row]
        switch notification.type {
        case .forward:
            print("Forward Notification")
            guard let cell = tableView.cellForRow(at: indexPath) as? NotificationCell else { return }
            
            if let image = cell.photoImageView {
                FirebaseController.shared.photoToPresent = image
                FirebaseController.shared.fetchMediaItem(forItemID: notification.mediaID!, completion: { (mediaItem) in
                    FirebaseController.shared.currentMediaItem = mediaItem
                    
                    NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
                })
                guard let photoToPresent = FirebaseController.shared.photoToPresent?.image else { return }
                let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mediaViewVC) as! MediaViewVC
                mediaViewVC.photo = photoToPresent
                mediaViewVC.isFromNotification = true
                let navController = UINavigationController(rootViewController: mediaViewVC)
                self.present(navController, animated: true, completion: nil)
            }
            
        case .friendAcceptedRequest:
            print("Friend has accepted friend request")
            segueToProfileVC(withUID: notification.userID, username: notification.username)
        case .newfriendRequest:
            print("Received a new friend request")
            segueToProfileVC(withUID: notification.userID, username: notification.username)
        case .newInboxItem:
            print("Received a new inbox item")
            self.tabBarController?.selectedIndex = 0
        case .newComment:
            print("new comment")
            guard let cell = tableView.cellForRow(at: indexPath) as? NotificationCell else { return }
            
            if let image = cell.photoImageView {
                FirebaseController.shared.photoToPresent = image
                FirebaseController.shared.fetchMediaItem(forItemID: notification.mediaID!, completion: { (mediaItem) in
                    FirebaseController.shared.currentMediaItem = mediaItem
                    
                    NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
                })
                guard let photoToPresent = FirebaseController.shared.photoToPresent?.image else { return }
                let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mediaViewVC) as! MediaViewVC
                mediaViewVC.photo = photoToPresent
                mediaViewVC.isFromNotification = true
                let navController = UINavigationController(rootViewController: mediaViewVC)
                self.present(navController, animated: true, completion: {
                    mediaViewVC.toCommentsVC()
                })
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func segueToProfileVC(withUID uid: String, username: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()?.childViewControllers[0] as! ProfileVC
        profileVC.userID = uid
        profileVC.isCurrentUser = false
        profileVC.username = username
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
