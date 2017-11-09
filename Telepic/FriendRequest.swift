//
//  FriendRequest.swift
//  Telepic
//
//  Created by Michael Bart on 10/13/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

struct FriendRequest {
    var uid: String
    var username: String
    var avatarURL: String
    var accepted: Bool
}

extension FriendRequest {
    init(uid: String, dict: [String:Any]) {
        let username = dict["username"] as! String
        let avatarURL = dict["avatarURL"] as! String
        self.init(uid: uid, username: username, avatarURL: avatarURL, accepted: false)
    }
}
