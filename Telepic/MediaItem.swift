//
//  MediaItem.swift
//  Telepic
//
//  Created by Michael Bart on 10/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

struct MediaItem {
    var itemID: String
    var timestamp: Double
    var type: String
    var caption: String?
    var creatorUsername: String
    var creatorID: String
    var creatorAvatarURL: String
    var downloadURL: String
    var thumbnailURL: String
    var forwards: Int
    var mapReference: [String:[String:Any]]
    var milesTraveled: Double
    var forwardList: [String:[String:Any]]?
}

extension MediaItem {
    init(itemID: String, dict: [String:Any]) {
        self.itemID = itemID
        self.timestamp = dict["timestamp"] as! Double
        self.type = dict["type"] as! String
        self.caption = dict["caption"] as? String ?? nil
        self.creatorUsername = dict["creatorUsername"] as! String
        self.creatorID = dict ["creatorID"] as! String
        self.creatorAvatarURL = dict["creatorAvatarURL"] as! String
        self.downloadURL = dict["downloadURL"] as! String
        self.thumbnailURL = dict["thumbnailURL"] as! String
        self.forwards = dict["forwards"] as! Int
        self.mapReference = dict["mapReference"] as! [String:[String:Any]]
        self.milesTraveled = dict["milesTraveled"] as! Double
        if let forwardList = dict["forwardList"] as? [String:[String:Any]] {
            self.forwardList = forwardList
        }
    }
}
/*
 Inbox item
 
 opened: Bool
 sender: User
 timestamp: Double
 
 
 */
