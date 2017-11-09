//
//  Upload.swift
//  Telepic
//
//  Created by Michael Bart on 10/20/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

struct Upload {
    var uid: String
    var downloadURL: String
    var timestamp: Double
    var type: String
    var thumbnailURL: String
}

extension Upload {
    init(uid: String, dict: [String:Any]) {
        self.uid = uid
        self.downloadURL = dict["downloadURL"] as! String
        self.timestamp = dict["timestamp"] as! Double
        self.type = dict["type"] as! String
        self.thumbnailURL = dict["thumbnailURL"] as! String
    }
}
