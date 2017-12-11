//
//  Forwarder.swift
//  Telepic
//
//  Created by Michael Bart on 11/21/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

struct Forwarder {
    var uid: String
    var username: String
    var avatarURL: String
    var timestamp: Double
    var count: Int
}

extension Forwarder {
    init(uid: String, dict: [String:Any]) {
        self.uid = uid
        self.username = dict["username"] as! String
        self.timestamp = dict["timestamp"] as! Double
        self.avatarURL = dict["avatarURL"] as! String
        self.count = dict["count"] as! Int
    }
}
