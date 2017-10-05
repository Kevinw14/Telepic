//
//  NotificationsVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/26/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users = ["michaelbart"]
    var notifications = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notifications = ["\(users[0]) forwarded one of your photos.", "\(users[0]) sent you a photo!", "\(users[0]) sent you a photo!", "\(users[0]) forwarded one of your photos."]
        
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
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationCell else { return UITableViewCell() }
        
        cell.notification = notifications[indexPath.row]
        cell.user = users[0]
        if indexPath.row % 2 == 0 {
            cell.photoImageView.image = #imageLiteral(resourceName: "photo2")
        }
        
        cell.setLabel()
        
        return cell
    }
}
