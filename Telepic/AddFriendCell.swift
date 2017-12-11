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
    weak var delegate: AddFriendDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    @IBAction func sendRequestButtonTapped(_ sender: Any) {

        delegate?.sendRequest(uid: uid, cell: self)
    }

}

protocol AddFriendDelegate: class {
    func sendRequest(uid: String, cell: UITableViewCell)
}
