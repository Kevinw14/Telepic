//
//  Notifications.swift
//  Telepic
//
//  Created by Michael Bart on 10/10/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

struct Notifications {
    
    static let didLoadInbox = Notification.Name("DidLoadInbox")
    static let newInboxItem = Notification.Name("NewInboxItem")
    static let inboxIsEmpty = Notification.Name("InboxIsEmpty")
    static let didLoadUsers = Notification.Name("DidLoadUsers")
    static let didLoadFriendRequests = Notification.Name("DidLoadFriendRequests")
    static let didLoadFriends = Notification.Name("DidLoadFriends")
    static let didUploadMedia = Notification.Name("DidUploadMedia")
    static let userDataChanged = Notification.Name("UserDataChanged")
    static let didLoadMediaItem = Notification.Name("DidLoadMediaItem")
    static let newEventNotification = Notification.Name("NewEventNotification")
    static let didForwardMedia = Notification.Name("DidForwardMedia")
    static let presentMedia = Notification.Name("PresentMedia")
    static let didLoadUser = Notification.Name("DidLoadUser")
    static let didLoadComments = Notification.Name("DidLoadComments")
    static let isSelectingMembers = Notification.Name("IsSelectingMembers")
}
