//
//  InboxItem.swift
//  Telepic
//
//  Created by Michael Bart on 9/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

struct InboxItem {
    var itemID: String
    var type: String
    var caption: String?
    var downloadURL: String
    var thumbnailURL: String
    var opened: Bool
    
    var senderID: String // User
    var senderUsername: String
    var senderAvatarURL: String
    
    var creatorID: String // User
    var creatorUsername: String
    var creatorAvatarURL: String
    
    var daysRemaining: String
    var timestamp: Double
//    var videoURL: String
    
    var commentsRef: String
    var mapRef: String
}

extension InboxItem {
    init(itemID: String, dict: [String:Any]) {
        let itemID = itemID
        let type = dict["type"] as! String
        let caption = dict["caption"] as? String ?? nil
        let downloadURL = dict["downloadURL"] as! String
        let thumbnailURL = dict["thumbnailURL"] as! String
        let opened = dict["opened"] as! Bool
        
        let senderID = dict["senderID"] as! String
        let senderUsername = dict["senderUsername"] as! String
        let senderAvatarURL = dict["senderAvatarURL"] as! String
        
        let creatorID = dict["creatorID"] as! String
        let creatorUsername = dict["creatorUsername"] as! String
        let creatorAvatarURL = dict["creatorAvatarURL"] as! String
        
        let timestamp = dict["timestamp"] as! Double
        
        
        self.init(itemID: itemID,
                  type: type,
                  caption: caption,
                  downloadURL: downloadURL,
                  thumbnailURL: thumbnailURL,
                  opened: opened,
                  senderID: senderID,
                  senderUsername: senderUsername,
                  senderAvatarURL: senderAvatarURL,
                  creatorID: creatorID,
                  creatorUsername: creatorUsername,
                  creatorAvatarURL: creatorAvatarURL,
                  daysRemaining: "3d",
                  timestamp: timestamp,
                  commentsRef: "noRef",
                  mapRef: "noRef")
    }
    
//    func dictionaryRepresentation() -> [String:Any] {
//        return [
//            "downloadURL": self.downloadURL,
//            "opened": self.opened, // reset to false
//            "senderID": self.senderID, // update to new sender id
//            "senderUsername": self.senderUsername, // update to new sender username
//            "senderAvatarURL": self.senderAvatarURL, // update to new sender avatar
//            "creatorID": self.creatorID,
//            "creatorUsername": self.creatorUsername,
//            "creatorAvatarURL": self.creatorAvatarURL,
//            "timestamp": self.timestamp // update to new send timestamp
//        ]
//    }
}
