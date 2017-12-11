//
//  FriendListVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/16/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Stevia

class FriendListVC: UITableViewController {
    
    lazy var backBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    var user: [String:Any]?
    var friends = [Friend]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.navigationItem.title = "Friends"
        self.navigationItem.leftBarButtonItem = backBarButton
        
        let titleAttrs = [
            NSAttributedStringKey.foregroundColor: UIColor(hexString: "333333"),
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.didLoadFriends, object: nil)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadData() {
        self.friends = FirebaseController.shared.friends
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? FriendCell else { return UITableViewCell() }
        
        cell.friend = friends[indexPath.row]
        cell.setUpCell()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: Identifiers.profileVC) as! ProfileVC
        profileVC.userID = friend.uid
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: friend.uid) { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            }
        }
        profileVC.username = friend.username
        profileVC.isCurrentUser = false
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
