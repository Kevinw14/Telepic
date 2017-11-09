//
//  SearchableUser.swift
//  Telepic
//
//  Created by Michael Bart on 10/11/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

class SearchableUser {
    
    var uid: String
    var username: String
    var avatarURL: String
    
    init(uid: String, username: String, avatarURL: String) {
        self.uid = uid
        self.username = username
        self.avatarURL = avatarURL
    }
}
