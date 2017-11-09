//
//  AddFriendCell.swift
//  Telepic
//
//  Created by Michael Bart on 10/10/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    var uid: String!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    @IBAction func sendRequestButtonTapped(_ sender: Any) {
        FirebaseController.shared.sendFriendRequest(toUID: uid)
        print("testing")
    }

}
