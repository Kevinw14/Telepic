
//
//  Group.swift
//  Telepic
//
//  Created by Michael Bart on 11/2/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

struct Group {
    
    var groupName: String
    var members: [Friend]
    var timestamp: Double
//    func dictionaryRepresentation() -> [String:Any] {
//
//        return [
//            "groupName": self.groupName,
//            "members": self.members
//        ]
//    }
}

extension Group {
    init(dict: [String:Any]) {
        let groupName = dict["groupName"] as! String
        let membersDict = dict["members"] as! [String:[String:String]]
        let timestamp = dict["timestamp"] as! Double
        self.members = membersDict.map { (key, value) in
            let uid = key
            let avatarURL = value["avatarURL"]
            let username = value["username"]
            return Friend(uid: uid, avatarURL: avatarURL!, username: username!)
        }
        self.groupName = groupName
        self.timestamp = timestamp
    }
}
