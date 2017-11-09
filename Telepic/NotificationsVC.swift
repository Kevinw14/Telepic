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

class NotificationsVC: TabChildVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notifications.newEventNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notifications.didLoadFriendRequests, object: nil)
    }
    
    @objc func updateData() {
        tableView.reloadData()
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
        case .friendAcceptedRequest:
            print("Friend has accepted friend request")
        case .newfriendRequest:
            print("Received a new friend request")
        case .newInboxItem:
            print("Received a new inbox item")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
