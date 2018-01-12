//
//  EventNotification.swift
//  Telepic
//
//  Created by Michael Bart on 10/25/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

struct EventNotification {
    let uid: String
    
    let username: String
    let avatarURL: String
    let userID: String
    let message: String
    
    var mediaURL: String?
    var mediaID: String?
    
    var unread: Bool
    
    let type: NotificationType
    let timestamp: Double
    
    func dictionaryRepresentation() -> [String:Any] {
        
        return [
            "uid": self.uid,
            "username": self.username,
            "avatarURL": self.avatarURL,
            "userID": self.userID,
            "message": self.message,
            "mediaURL": self.mediaURL ?? "n/a",
            "mediaID": self.mediaID ?? "n/a",
            "unread": self.unread,
            "type": self.type.rawValue,
            "timestamp": self.timestamp
        ]
    }
}

extension EventNotification {
    init(dict: [String:Any]) {
        let uid = dict["uid"] as! String
        let username = dict["username"] as! String
        let avatarURL = dict["avatarURL"] as! String
        let userID = dict["userID"] as! String
        let message = dict["message"] as! String
        
        let mediaURL = dict["mediaURL"] as! String
        let mediaID = dict["mediaID"] as! String
        
        let unread = dict["unread"] as! Bool
        
        let type = dict["type"] as! String
        let timestamp = dict["timestamp"] as! Double
        
        self.init(uid: uid,
                  username: username,
                  avatarURL: avatarURL,
                  userID: userID,
                  message: message,
                  mediaURL: mediaURL,
                  mediaID: mediaID,
                  unread: unread,
                  type: NotificationType(rawValue: type)!,
                  timestamp: timestamp)
    }
}

enum NotificationType: String {
    case newfriendRequest
    case friendAcceptedRequest
    case forward
    case newInboxItem
    case newComment
}
