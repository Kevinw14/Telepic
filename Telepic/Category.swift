//
//  Category.swift
//  Telepic
//
//  Created by Kevin Wood on 11/26/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import Foundation

struct Category {
    let name: String
    let imageURL: URL
    let uid: String
    
    private init(name: String, imageURL: URL, uid: String) {
        self.name = name
        self.imageURL = imageURL
        self.uid = uid
    }
    
    init(dictionary: [String:Any]) {
        let name = dictionary["name"] as! String
        let imageURL = dictionary["imageURL"] as! String
        let uid = dictionary["uid"] as! String
        
        self.name = name
        self.uid = uid
        self.imageURL = URL(string: imageURL)!
    }
}
