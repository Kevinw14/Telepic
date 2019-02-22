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
    var newFoward: Bool?
    var downloadURL: String?
    var timestamp: Double?
    var type: String?
    var thumbnailURL: String?
}

extension Upload {
    init(uid: String, dict: [String:Any]) {
        self.uid = uid
        self.timestamp = dict["timestamp"] as? Double
        self.type = dict["type"] as? String
        self.thumbnailURL = dict["thumbnailURL"] as? String
        self.newFoward = dict["newForward"] as? Bool
        self.downloadURL = dict["downloadURL"] as? String
    }
}
