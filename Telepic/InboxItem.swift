//
//  InboxItem.swift
//  Telepic
//
//  Created by Michael Bart on 9/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

struct InboxItem {
    var photo: UIImage?
    var sender: String // User
    var senderAvatar: UIImage
    var creator: String // User
    var creatorAvatar: UIImage
    var daysRemaining: Int
    
    var commentsRef: String
    var mapRef: String
}
