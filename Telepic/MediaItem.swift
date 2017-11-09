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
    var type: String
    var creatorUsername: String
    var creatorID: String
    var downloadURL: String
    var thumbnailURL: String
    var forwards: Int
    var mapReference: [String:[String:Any]]
    var milesTraveled: Int
}
/*
 Inbox item
 
 opened: Bool
 sender: User
 timestamp: Double
 
 
 */
