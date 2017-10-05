//
//  AddFBFriendsVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/6/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class AddFBFriendsVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    
    var tempFriends = ["Michael Bart", "Stephanie Joyce", "Steve Jobs", "Donald Trump"]
    var avatars = [#imageLiteral(resourceName: "avatar"),#imageLiteral(resourceName: "avatar2"),#imageLiteral(resourceName: "avatar3"),#imageLiteral(resourceName: "avatar4")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
    }
    @IBAction func doneButtonTapped(_ sender: Any) {
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

extension AddFBFriendsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FBFriendCell") as? FBFriendCell else { return UITableViewCell() }
        
        let avatar = avatars[indexPath.row]
        let friendName = tempFriends[indexPath.row]
        
        cell.avatarImageView.image = avatar
        cell.nameLabel.text = friendName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FBFriendCell else { return }
        cell.checkmarkImageView.isHidden = !cell.checkmarkImageView.isHidden

        if !cell.checkmarkImageView.isHidden {
            cell.avatarImageView.alpha = 0.5
            cell.nameLabel.alpha = 0.5
        } else {
            cell.avatarImageView.alpha = 1
            cell.nameLabel.alpha = 1
        }
        
    }
}
