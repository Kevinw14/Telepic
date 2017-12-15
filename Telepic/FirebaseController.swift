//
//  FirebaseController.swift
//  Telepic
//
//  Created by Michael Bart on 10/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
//import NotificationBannerSwift
import MapKit
import SVProgressHUD

class FirebaseController {
    
    static var shared = FirebaseController()
    
    static var remoteConfig = RemoteConfig.remoteConfig()
    
    private var ref = Database.database().reference()
    
    let storageRef = Storage.storage().reference()
    
    var inboxItems = [InboxItem]()
    
    var badgeCount = 0
    
    var photoToPresent: UIImageView? {
        didSet {
            NotificationCenter.default.post(name: Notifications.presentMedia, object: self)
        }
    }
    
    var startAMovement = true
    var contest = false
    
    var currentMediaItem: MediaItem?
    
    var filteredUsers = [SearchableUser]()
    
    var selectedGroupMembers = [Friend]()
    
    var groupName = ""
    
    var isZooming = true
    
    var friendRequests = [FriendRequest]()
    
    var eventNotifications = [EventNotification]() {
        didSet {
            NotificationCenter.default.post(name: Notifications.newEventNotification, object: self)
            if eventNotifications.isEmpty { NotificationCenter.default.post(name: Notifications.emptyNotifications, object: self) }
        }
    }
    
    var friends = [Friend]()
    
    var validForwardTargets = [Friend]()
    
    func updateBadgeCount() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        badgeCount += 1
        self.ref.child("users").child(uid).child("badgeCount").setValue(badgeCount)
    }
    
    func resetBadgeCount() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        badgeCount = 0
        self.ref.child("users").child(uid).child("badgeCount").setValue(badgeCount)
    }
    
    // MARK: - User
    
    func saveToken() {
        guard let uid = Auth.auth().currentUser?.uid, let token = Messaging.messaging().fcmToken else { return }
        
        self.ref.child("users").child(uid).child("notificationToken").child(token).setValue(true)
    }
    
    func storeUsername(_ username: String, uid: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.ref.child("users").child(uid).setValue(["username": username, "searchableUsername": username.lowercased()])
                self.ref.child("usernames").child(username.lowercased()).setValue(true)
            }
        }
        
    }
    
    func storeBio(uid: String, text: String) {
        self.ref.child("users").child(uid).child("bio").setValue(text)
    }
    
    func verifyUniqueUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        let usernamesRef = self.ref.child("usernames")
        usernamesRef.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else { completion(true); return }
            guard let usernames = snapshot.value as? [String:Any] else { return }
            let isUnique = usernames.contains(where: { (key, value) -> Bool in
                key != username.lowercased()
            })
            completion(isUnique)
        }
    }
    
    func isUsernameStored(uid: String, completion: @escaping (Bool) -> Void) {
        
        ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            // Get value
            let value = snapshot.value as? NSDictionary
            completion(value?["username"] != nil)
        }
    }
    
    func updateUsername(_ username: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.ref.child("users").child(currentUser.uid).updateChildValues(["username": username, "searchableUsername": username.lowercased()])
                self.ref.child("usernames").child(username.lowercased()).setValue(true)
            }
        }
    }
    
    func signOut() {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func checkUserExists(uid: String, completion: @escaping(Bool) -> Void) {
        self.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func fetchUser(uid: String, completion: @escaping ([String:Any]) -> Void) {
        self.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? [String:Any] else { return }
            completion(user)
        }
    }
    
    func fetchAvatarImage(forUID uid: String, completion: @escaping (String) -> Void) {
        
        self.ref.child("users").child(uid).child("avatarURL").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let avatarURL = snapshot.value as? String else { return }
                completion(avatarURL)
            }
        }
    }
    
    func searchUsers(text: String) {
        var users = [SearchableUser]()
        self.filteredUsers = users
        
        if text != "" {
            ref.child("users").queryOrdered(byChild: "searchableUsername").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let usersDict = snapshot.value as? [String:[String:Any]] else { return }
                for (key, value) in usersDict {
                    let username = value["username"] as! String
                    let avatarURL = value["avatarURL"] as? String ?? "n/a"
                    if key != Auth.auth().currentUser?.uid {
                        if FirebaseController.shared.friends.isEmpty {
                            users.append(SearchableUser(uid: key, username: username, avatarURL: avatarURL))
                            self.filteredUsers = users
                            NotificationCenter.default.post(Notification(name: Notifications.didLoadUsers))
                        } else {
                            
                            self.ref.child("users").child(Auth.auth().currentUser!.uid).child("friends").observeSingleEvent(of: .value, with: { (friendsSnapshot) in
                                if friendsSnapshot.hasChild(key) {
                                    print("user is already a friend")
                                } else {
                                    users.append(SearchableUser(uid: key, username: username, avatarURL: avatarURL))
                                }
                                print(self.filteredUsers)
                                self.filteredUsers = users
                                NotificationCenter.default.post(Notification(name: Notifications.didLoadUsers))
                            })
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - Inbox
    
    func fetchInboxItems() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let inboxRef = ref.child("users").child(currentUser.uid).child("inbox")
        inboxRef.observe(.childAdded) { (snapshot) in
            guard let inboxItemDict = snapshot.value as? [String:Any] else { return }
            let inboxItem = InboxItem(itemID: snapshot.key, dict: inboxItemDict)
            
            
            
            let isUnique = !self.inboxItems.contains(where: { (item) -> Bool in
                inboxItem.itemID == item.itemID
            })
            
            if isUnique {
                self.inboxItems.append(inboxItem)
                self.inboxItems = self.inboxItems.sorted { $0.timestamp > $1.timestamp }
                
                if inboxItem.opened == false {
                    let notification = EventNotification(username: inboxItem.senderUsername,
                                                     avatarURL: inboxItem.senderAvatarURL,
                                                     userID: inboxItem.senderID,
                                                     message: "\(inboxItem.senderUsername) sent you a \(inboxItem.type)!",
                                                     mediaURL: inboxItem.downloadURL,
                                                     mediaID: inboxItem.itemID,
                                                     type: NotificationType.newInboxItem,
                                                     timestamp: inboxItem.timestamp)
                    self.eventNotifications.append(notification)
                    self.ref.child("users").child(currentUser.uid).child("notifications").childByAutoId().setValue(notification.dictionaryRepresentation())
                
//                    let banner = StatusBarNotificationBanner(title: notification.message, style: .success)
//                    banner.show()
                    
                    self.eventNotifications = self.eventNotifications.sorted { $0.timestamp > $1.timestamp }
                }
                NotificationCenter.default.post(name: Notifications.newInboxItem, object: self)
            }
        }
    }
    
    func loadInboxItems() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let inboxRef = ref.child("users").child(currentUser.uid).child("inbox")
        inboxRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let inboxItemsDict = snapshot.value as? [String:[String:Any]] else { return }
            var inboxItems = [InboxItem]()
            for (key, value) in inboxItemsDict {
                var inboxItem = InboxItem(itemID: key, dict: value)
                
                let originalDate = Date(timeIntervalSinceReferenceDate: inboxItem.timestamp)
                let threeDays = 259200.0
                let deadline = Date(timeInterval: threeDays, since: originalDate)
                let currentTimeInterval = Date().timeIntervalSince1970
                let currentDate = Date(timeIntervalSinceReferenceDate: currentTimeInterval)
                let components = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: deadline)
                var remaining = ""
                if deadline > currentDate {
                    if components.day == 0 {
                        if components.hour == 0 {
                            remaining = "\(components.minute!)m"
                        } else {
                            remaining = "\(components.hour!)h"
                        }
                    } else {
                        remaining = "\(components.day!)d"
                    }
                    inboxItem.daysRemaining = remaining
                    inboxItems.append(inboxItem)
                } else {
                    self.ref.child("users").child(currentUser.uid).child("inbox").child(key).removeValue()
                }
            }
            self.inboxItems = inboxItems.sorted { $0.timestamp > $1.timestamp }
            NotificationCenter.default.post(name: Notifications.didLoadInbox, object: self)
        }
    }
    
    func isInboxEmpty() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let inboxRef = ref.child("users").child(currentUser.uid).child("inbox")
        inboxRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChildren() { NotificationCenter.default.post(name: Notifications.inboxIsEmpty, object: self) }
        })
    }
    
    func removeMediaItem(withID itemID: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        self.ref.child("mediaItems").child(itemID).child("recipients").observeSingleEvent(of: .value) { (snapshot) in
            guard let recipientsDict = snapshot.value as? [String:Any] else { return }
            
            for userID in recipientsDict.keys {
                self.ref.child("users").child(userID).child("inbox").child(itemID).removeValue()
            }
            
            self.ref.child("mediaItems").child(itemID).child("forwards").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let forwards = snapshot.value as? Int else { return }
                
                self.ref.child("users").child(currentUID).child("forwardCount").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let forwardCount = snapshot.value as? Int else { return }
                    
                    let newCount = forwardCount - forwards
                    
                    self.ref.child("users").child(currentUID).child("forwardCount").setValue(newCount)
                })
            })
            
            self.ref.child("contest").child(itemID).removeValue()
            
            self.ref.child("startAMovement").child(itemID).removeValue()
            
            self.ref.child("users").child(currentUID).child("uploads").child(itemID).removeValue()
            
            self.ref.child("mediaItems").child(itemID).child("forwarders").observeSingleEvent(of: .value) { (snapshot) in
                if let forwarders = snapshot.value as? [String:Any] {
                    for userID in forwarders.keys {
                        self.ref.child("users").child(userID).child("forwards").child(itemID).removeValue()
                    }
                }
                
                self.ref.child("mediaItems").child(itemID).removeValue()
                NotificationCenter.default.post(Notification(name: Notifications.didUploadMedia))
            }
        }
    }
    
    func setItemOpened(inboxItem: InboxItem, latitude: Double, longitude: Double) {
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child("users").child(currentUser.uid).child("inbox").child(inboxItem.itemID).updateChildValues(["opened": true])

        let timestamp = Date().timeIntervalSince1970
        let range = -2...2
        let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
        print(randomDistance)
        let adjustedLatitude = latitude + (Double(randomDistance) * 0.01)
        let adjustedLongitude = longitude + (Double(randomDistance) * 0.01)
        
        ref.child("mediaItems").child(inboxItem.itemID).child("mapReference").child(currentUser.uid).setValue(["latitude": adjustedLatitude, "longitude": adjustedLongitude, "timestamp": timestamp])
        
        ref.child("users").child(currentUser.uid).child("notifications").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let notifications = snapshot.value as? [String:[String:Any]] else { return }
                var updatedNotifications = [EventNotification]()
                for (key, value) in notifications {
                    if let id = value["mediaID"] as? String, id == inboxItem.itemID {
                        self.ref.child("users").child(currentUser.uid).child("notifications").child(key).removeValue()
                    } else {
                        updatedNotifications.append(EventNotification(dict: value))
                    }
                }
                self.eventNotifications = updatedNotifications
            }
        }
        
        self.ref.child("mediaItems").child(inboxItem.itemID).child("mapReference").observeSingleEvent(of: .value, with: { (snapshot) in
//            var distance
            if let mapRef = snapshot.value as? [String:[String:Any]], snapshot.exists() {
                var previousLocation: CLLocation?
                var distance = 0.0
                mapRef.values.forEach { (value) in
                    let lat = value["latitude"] as! Double
                    let long = value["longitude"] as! Double
                    
                    let location = CLLocation(latitude: lat, longitude: long)
                    
                    if let previousLocation = previousLocation {
                        distance += location.distance(from: previousLocation)
                    }
                    previousLocation = location
                }
                let milesTraveled = distance * 0.000621371
                self.ref.child("mediaItems").child(inboxItem.itemID).child("milesTraveled").setValue(milesTraveled)
            }
        })
        
        // Increment total forward count for creator
        let creatorID = inboxItem.creatorID
        
        let forwardCountRef = self.ref.child("users").child(creatorID).child("forwardCount")
        
        forwardCountRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let oldCount = snapshot.value as! Int
                let newCount = oldCount + 1
                forwardCountRef.setValue(newCount)
            } else {
                forwardCountRef.setValue(1)
            }
        })
        
        NotificationCenter.default.post(Notification(name: Notifications.userDataChanged))
        
        var mediaItem = [String:Any]()
        
        var forwardList = [String:[String:Any]]()
        self.ref.child("mediaItems").child(inboxItem.itemID).child("forwardList").observeSingleEvent(of: .value, with: { (snapshot) in
            if let list = snapshot.value as? [String:[String:Any]] {
                forwardList = list
            } else {
                print("NO FORWARD LIST")
            }
            
            // Increment forward count for sender
            // Check if the sender has already forwarded this item to someone, if so update forward count.
            if let existingUser = forwardList[inboxItem.senderID] {
                let currentForwardCount = existingUser["count"] as! Int
                let updatedUser: [String:Any] = [
                    "username": inboxItem.senderUsername,
                    "avatarURL": inboxItem.senderAvatarURL,
                    "timestamp": timestamp,
                    "count": currentForwardCount + 1
                ]
                forwardList[inboxItem.senderID] = updatedUser
            } else {
                forwardList[inboxItem.senderID] = [
                    "username": inboxItem.senderUsername,
                    "avatarURL": inboxItem.senderAvatarURL,
                    "timestamp": timestamp,
                    "count": 1
                ]
            }
            
            mediaItem["forwardList"] = forwardList
            self.ref.child("mediaItems").child(inboxItem.itemID).child("forwards").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? Int, snapshot.exists() {
                    mediaItem["forwards"] = value + 1
                    self.ref.child("mediaItems").child(inboxItem.itemID).updateChildValues(mediaItem)
                }
            })
        })
        
        loadInboxItems()
    }
    
    // MARK: - Friends
    
    func sendFriendRequest(toUID: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let displayName = currentUser.displayName else { return }
        let avatarURL = currentUser.photoURL?.absoluteString ?? "n/a"
        
        // Check if user is already in the sent array and disable sending friend request if so
        
        
        ref.child("users").child(toUID).child("requests").child("received").child(currentUser.uid).setValue(["username": displayName, "avatarURL": avatarURL])
        ref.child("users").child(currentUser.uid).child("requests").child("sent").child(toUID).setValue(true)
    }
    
    func fetchFriendRequests() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let friendRequestRef = ref.child("users").child(currentUser.uid).child("requests").child("received")
        friendRequestRef.observe(.childAdded) { (snapshot) in
            guard let friendRequestDict = snapshot.value as? [String:Any] else { return }
            let friendRequest = FriendRequest(uid: snapshot.key, dict: friendRequestDict)
            
            let isUnique = !self.friendRequests.contains(where: { (request) -> Bool in
                friendRequest.uid == request.uid
            })
            
            if isUnique {
                self.friendRequests.append(friendRequest)
                
                
                let notification = EventNotification(username: friendRequest.username,
                                                     avatarURL: friendRequest.avatarURL,
                                                     userID: friendRequest.uid,
                                                     message: "\(friendRequest.username) sent you a friend request!",
                                                     mediaURL: nil,
                                                     mediaID: nil,
                                                     type: NotificationType.newfriendRequest,
                                                     timestamp: Date().timeIntervalSince1970)
                self.eventNotifications.append(notification)
                
                
                
                self.ref.child("users").child(currentUser.uid).child("notifications").childByAutoId().setValue(notification.dictionaryRepresentation())
                
//                let banner = StatusBarNotificationBanner(title: notification.message, style: .success)
//                banner.show()
                
                self.eventNotifications = self.eventNotifications.sorted { $0.timestamp > $1.timestamp }
                
                NotificationCenter.default.post(name: Notifications.didLoadFriendRequests, object: self)
            }
        }
    }
    
    func addFriend(withUID uid: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(currentUID).child("friends").child(uid).setValue(true)
        ref.child("users").child(uid).child("friends").child(currentUID).setValue(true)
        ref.child("users").child(currentUID).child("requests").child("received").child(uid).removeValue()
        ref.child("users").child(uid).child("requests").child("sent").child(currentUID).removeValue()
        
        ref.child("users").child(currentUID).child("notifications").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let notifications = snapshot.value as? [String:[String:Any]] else { return }
                var updatedNotifications = [EventNotification]()
                for (key, value) in notifications {
                    if let type = value["type"] as? String, let userID = value["userID"] as? String, type == NotificationType.newfriendRequest.rawValue, userID == uid {
                        self.ref.child("users").child(currentUID).child("notifications").child(key).removeValue()
                    } else {
                        updatedNotifications.append(EventNotification(dict: value))
                    }
                }
                self.eventNotifications = updatedNotifications
            }
        }
        
        fetchFriendRequests()
        NotificationCenter.default.post(Notification(name: Notifications.reloadNotifications))
    }
    
    func fetchFriends(uid: String) {
        
        ref.child("users").child(uid).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            guard let friendsDict = snapshot.value as? [String:Any] else { return }
            
            var friends = [Friend]() {
                didSet {
                    self.friends = friends
                    NotificationCenter.default.post(name: Notifications.didLoadFriends, object: self)
                    
                }
            }
            var friendsDefaults = [String:Any]()
            
            for friend in friendsDict.keys {
                self.ref.child("users").child(friend).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let user = snapshot.value as? [String:Any] else { return }
                    let username = user["username"] as! String
                    let avatarURL = user["avatarURL"] as? String ?? "n/a"
                    friends.append(Friend(uid: friend, avatarURL: avatarURL, username: username))
                    
                    friendsDefaults[friend] = username
                    let defaults = UserDefaults(suiteName: "group.MichaelBart.Telepic")
                    defaults?.set(friendsDefaults, forKey: "friends")
                    defaults?.synchronize()
                })
            }
        }
    }
    
    func fetchValidForwardTargets(itemID: String, creatorID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(uid).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            guard let friendsDict = snapshot.value as? [String:Any] else { return }
            
            var validForwardTargets = [Friend]() {
                didSet {
                    self.validForwardTargets = validForwardTargets
                    NotificationCenter.default.post(name: Notifications.didLoadValidTargets, object: self)
                }
            }
            
            let targets = Array(friendsDict.keys)
            self.getValidForwardTargets(itemID: itemID, creatorID: creatorID, targets: targets, completion: { (validIDs) in
                for id in validIDs {
                    self.ref.child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let user = snapshot.value as? [String:Any] else { return }
                        let username = user["username"] as! String
                        let avatarURL = user["avatarURL"] as? String ?? "n/a"
                        validForwardTargets.append(Friend(uid: id, avatarURL: avatarURL, username: username))
                    })
                }
            })
        }
    }
    
    func fetchMediaItem(forItemID itemID: String, completion: @escaping (MediaItem) -> Void) {
        
        self.ref.child("mediaItems").child(itemID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let mediaItemDict = snapshot.value as? [String:Any] else { return }
                let timestamp = mediaItemDict["timestamp"] as! Double
                let creatorID = mediaItemDict["creatorID"] as! String
                let caption = mediaItemDict["caption"] as? String ?? nil
                let downloadURL = mediaItemDict["downloadURL"] as! String
                let thumbnailURL = mediaItemDict["thumbnailURL"] as! String
                let type = mediaItemDict["type"] as! String
                let forwards = mediaItemDict["forwards"] as! Int
                let mapReference = mediaItemDict["mapReference"] as! [String:[String:Any]]
                let milesTraveled = mediaItemDict["milesTraveled"] as! Double
                let forwardList = mediaItemDict["forwardList"] as? [String:[String:Any]] ?? nil
                
                FirebaseController.shared.fetchUser(uid: creatorID, completion: { (user) in
                    let creatorUsername = user["username"] as! String
                    let creatorAvatarURL = user["avatarURL"] as? String ?? "n/a"
                    
                    let mediaItem = MediaItem(itemID: itemID, timestamp: timestamp, type: type, caption: caption, creatorUsername: creatorUsername, creatorID: creatorID, creatorAvatarURL: creatorAvatarURL, downloadURL: downloadURL, thumbnailURL: thumbnailURL, forwards: forwards, mapReference: mapReference, milesTraveled: milesTraveled, forwardList: forwardList)
                    completion(mediaItem)
                })
                
            }
        }
    }
    
    func getValidForwardTargets(itemID: String, creatorID: String, targets: [String], completion: @escaping ([String]) -> Void) {
        var validIDs = [String]()
        
        for uid in targets {
            self.ref.child("users").child(uid).child("inbox").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(itemID) {
                    print("User already has inbox item.")
                } else if uid == creatorID {
                    print("User is the creator.")
                } else {
                    validIDs.append(uid)
                }
                if uid == targets.last { completion(validIDs) }
            })
        }
    }
    
//    func fetchForwardList(forMediaItemID mediaItemID: String, completion: @escaping ([String:[String:Any]]) -> Void) {
//        self.ref.child("mediaItems").child(mediaItemID).child("forwardList").observeSingleEvent(of: .value) { (snapshot) in
//            if let forwardList = snapshot.value as? [String:[String:Any]] {
//                completion(forwardList)
//            }
//        }
//    }
    
    func forwardMediaItem(_ item: MediaItem, toFriendIDs friendIDs: [String]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if let currentUID = Auth.auth().currentUser?.uid {
            
            let dateSent = Date().timeIntervalSince1970
            
            let inboxItem: [String:Any] = [
                "type": item.type,
                "caption": item.caption ?? nil,
                "downloadURL": item.downloadURL,
                "thumbnailURL": item.thumbnailURL,
                "opened": false,
                "senderID": currentUID,
                "senderUsername": currentUser.displayName!,
                "senderAvatarURL": currentUser.photoURL?.absoluteString ?? "n/a",
                "creatorID": item.creatorID,
                "creatorUsername": item.creatorUsername,
                "creatorAvatarURL": item.creatorAvatarURL,
                "timestamp": dateSent
            ]
            let itemObject = InboxItem(itemID: item.itemID, dict: inboxItem)
            
                
            for uid in friendIDs {
                self.ref.child("users").child(uid).child("inbox").child(item.itemID).setValue(inboxItem)
            }
            
            self.ref.child("mediaItems").child(item.itemID).child("forwarders").child(currentUID).setValue(true)
            
            friendIDs.forEach { userID in
                self.ref.child("mediaItems").child(item.itemID).child("recipients").child(userID).setValue(true)
            }
            
            self.ref.child("users").child(currentUID).child("forwards").child(item.itemID).setValue(true)
            
            self.ref.child("users").child(currentUID).child("inbox").child(item.itemID).removeValue()
            self.loadInboxItems()
            
            NotificationCenter.default.post(Notification(name: Notifications.didForwardMedia))
        }
    }
    
    func forwardInboxItem(_ item: InboxItem, toFriendIDs friendIDs: [String]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if let currentUID = Auth.auth().currentUser?.uid {
            
            let dateSent = Date().timeIntervalSince1970
            let inboxItem: [String:Any] = [
                "type": item.type,
                "caption": item.caption ?? nil,
                "downloadURL": item.downloadURL,
                "thumbnailURL": item.thumbnailURL,
                "opened": false,
                "senderID": currentUID,
                "senderUsername": currentUser.displayName!,
                "senderAvatarURL": currentUser.photoURL?.absoluteString ?? "n/a",
                "creatorID": item.creatorID,
                "creatorUsername": item.creatorUsername,
                "creatorAvatarURL": item.creatorAvatarURL,
                "timestamp": dateSent
            ]
                
            for uid in friendIDs {
                self.ref.child("users").child(uid).child("inbox").child(item.itemID).setValue(inboxItem)
            }
            
            self.ref.child("mediaItems").child(item.itemID).child("forwarders").child(currentUID).setValue(true)
            
            self.ref.child("users").child(currentUID).child("forwards").child(item.itemID).setValue(true)
            
            friendIDs.forEach { userID in
                self.ref.child("mediaItems").child(item.itemID).child("recipients").child(userID).setValue(true)
            }
            
            self.ref.child("users").child(currentUID).child("inbox").child(item.itemID).removeValue()
            self.loadInboxItems()
            
            NotificationCenter.default.post(Notification(name: Notifications.didForwardMedia))
        }
    }
    
    func postComment(text: String, toMediaItem mediaItemID: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let photoURL = currentUser.photoURL?.absoluteString ?? "n/a"
        let comment = Comment(senderID: currentUser.uid, username: currentUser.displayName!, message: text, timestamp: Date().timeIntervalSince1970, senderAvatarURL: photoURL)
        ref.child("mediaItems").child(mediaItemID).child("comments").childByAutoId().setValue(comment.dictionaryRepresentation())
    }
    
    func fetchComments(forMediaItemID mediaItemID: String, completion: @escaping ([Comment]) -> Void) {
        self.ref.child("mediaItems").child(mediaItemID).child("comments").observe(.value) { (snapshot) in
            if snapshot.exists() {
                guard let commentsDict = snapshot.value as? [String:[String:Any]] else { return }
                let comments = commentsDict.values.map { value in
                    Comment(dict: value)
                }
                completion(comments.sorted { $0.timestamp < $1.timestamp })
            } else {
                print("comments don't exist")
                NotificationCenter.default.post(Notification(name: Notifications.emptyComments))
            }
        }
    }
    
    func createGroup(withName name: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let groupRef = ref.child("users").child(currentUser.uid).child("groups").childByAutoId()
        groupRef.setValue(["groupName": name, "timestamp": Date().timeIntervalSince1970])
        
        //var count = selectedGroupMembers.count
        for friend in selectedGroupMembers {
            groupRef.child("members").child(friend.uid).setValue(["username": friend.username, "avatarURL": friend.avatarURL])
            //count -= 1
            //if count == 0 { completion(true) }
        }
    }
    
    func fetchGroups(completion: @escaping ([Group]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        self.ref.child("users").child(currentUser.uid).child("groups").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let groupsDict = snapshot.value as? [String:[String:Any]] else { return }
                let groups = groupsDict.values.map { Group(dict: $0) }
                completion(groups.sorted { $0.timestamp < $1.timestamp })
            }
        }
    }
    
    func fetchMostForwarded(completion: @escaping ([MediaItem]) -> Void) {
        self.ref.child("mediaItems").queryOrdered(byChild: "forwards").queryLimited(toLast: 50).queryStarting(atValue: 1).observeSingleEvent(of: .value) { (snapshot) in
            if let mediaItemDict = snapshot.value as? [String:[String:Any]] {
                var mediaItems = [MediaItem]()
                mediaItems = mediaItemDict.map { (key, value) in
                    MediaItem(itemID: key, dict: value)
                }
                completion(mediaItems.sorted { $0.forwards > $1.forwards })
            }
        }
    }
    
    func fetchContestOfTheWeek(completion: @escaping ([MediaItem]) -> Void) {
        self.ref.child("contest").observeSingleEvent(of: .value) { (snapshot) in
            if let mediaIDsDict = snapshot.value as? [String:Any] {
                var mediaItems = [MediaItem]()
                let mediaIDs = Array(mediaIDsDict.keys)
                mediaIDs.forEach { (mediaID) in
                    self.ref.child("mediaItems").child(mediaID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let mediaItemDict = snapshot.value as? [String:Any] {
                            mediaItems.append(MediaItem(itemID: mediaID, dict: mediaItemDict))
                        }
                        
                        if mediaID == mediaIDs.last {
                            completion(mediaItems.sorted { $0.forwards > $1.forwards})
                        }
                    })
                }
            }
        }
    }
    
    func fetchStartAMovement(completion: @escaping ([MediaItem]) -> Void) {
        self.ref.child("startAMovement").observeSingleEvent(of: .value) { (snapshot) in
            if let mediaIDsDict = snapshot.value as? [String:Any] {
                var mediaItems = [MediaItem]()
                let mediaIDs = Array(mediaIDsDict.keys)
                mediaIDs.forEach { (mediaID) in
                    self.ref.child("mediaItems").child(mediaID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let mediaItemDict = snapshot.value as? [String:Any] {
                            let forwards = mediaItemDict["forwards"] as? Int ?? 0
                            if forwards == 0 {
                                mediaItems.append(MediaItem(itemID: mediaID, dict: mediaItemDict))
                            }
                        }
                        
                        if mediaID == mediaIDs.last {
                            completion(mediaItems.sorted { $0.timestamp > $1.timestamp})
                        }
                    })
                }
            }
        }
    }
    
    func uploadProfilePhoto(data: Data) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let localData = data
        let identifier = currentUser.uid
        let fileRef = storageRef.child("avatars/\(identifier)")
        
        let uploadTask = fileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            guard let downloadURL = metadata.downloadURL()?.absoluteString else { print("No Download URL"); return }
            
            // store downloadURL at database
            self.ref.child("users").child(currentUser.uid).child("avatarURL").setValue(downloadURL)
            
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.photoURL = URL(string: downloadURL)
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { (snapshot) in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { (snapshot) in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
        }
        
        uploadTask.observe(.success) { (snapshot) in
            // Upload completed successfully
            // store downloadURL
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadVideo(withIdentifier identifier: String, toFile file: URL, progressEsc: @escaping(Progress) -> Void, completion: @escaping(URL) -> Void) {

        let videoRef = storageRef.child("videos/\(identifier)")
        
        let downloadTask = videoRef.write(toFile: file)
        
        downloadTask.observe(.resume) { (snapshot) in
            print("Download started")
        }
        
        downloadTask.observe(.pause) { (snapshot) in
            print("Download paused")
        }
        
        downloadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                progressEsc(progress)
            }
        }
        
        downloadTask.observe(.success) { (snapshot) in
            print("Download successful")
            completion(file)
        }
    }
    
    func sendVideo(caption: String?, videoURL: URL, thumbnailData: Data, toUserIDs: [String], currentLocation: [String:Double]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let localFile = videoURL
        let identifier = UUID().uuidString
        let fileRef = storageRef.child("videos/\(identifier)")
        
        let uploadTask = fileRef.putFile(from: localFile)
        
        uploadTask.observe(.success) { (snapshot) in
            guard let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString else { return }
            
            let data = thumbnailData
            let thumbnailRef = self.storageRef.child("thumbnails/\(identifier)")
            let _ = thumbnailRef.putData(data, metadata: nil) { thumbnailMetadata, thumbnailError in
                guard let thumbnailMetadata = thumbnailMetadata else {
                    return
                }
                
                guard let thumbnailURL = thumbnailMetadata.downloadURL()?.absoluteString else { print("Missing thumbnail"); return }
                
                // store downloadURL at database
                if let currentUID = Auth.auth().currentUser?.uid {
                    let childID = UUID().uuidString
                    let dateSent = Date().timeIntervalSince1970
                    self.ref.child("users").child(currentUID).child("uploads").child(childID).setValue(["downloadURL": identifier, "thumbnailURL": thumbnailURL, "timestamp": dateSent, "type": "video"])
                    
                    NotificationCenter.default.post(Notification(name: Notifications.didUploadMedia))
                    
                    // add file to the inboxes of selected users
                    for uid in toUserIDs {
                        
                        var inboxItem: [String:Any] = [
                            "type": "video",
                            "downloadURL": downloadURL,
                            "thumbnailURL": thumbnailURL,
                            "opened": false,
                            "senderID": currentUID,
                            "senderUsername": currentUser.displayName!,
                            "senderAvatarURL": currentUser.photoURL?.absoluteString ?? "n/a",
                            "creatorID": currentUID,
                            "creatorUsername": currentUser.displayName!,
                            "creatorAvatarURL": currentUser.photoURL?.absoluteString ?? "n/a",
                            "timestamp": dateSent
                        ]
                        
                        if let caption = caption {
                            inboxItem["caption"] = caption
                        }
                        
                        self.ref.child("users").child(uid).child("inbox").child(childID).setValue(inboxItem)
                        
                        self.ref.child("users").child(uid).child("notifications").childByAutoId()
                    }
                    
                    guard let creatorUsername = currentUser.displayName  else { return }
                    
                    let creatorAvatarURL = currentUser.photoURL?.absoluteString ?? "n/a"
                    let timestamp = Date().timeIntervalSince1970
                    let range = -2...2
                    let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
                    print(randomDistance)
                    let adjustedLatitude = currentLocation["latitude"]! + (Double(randomDistance) * 0.01)
                    let adjustedLongitude = currentLocation["longitude"]! + (Double(randomDistance) * 0.01)
                    
                    var mediaItem: [String:Any] = [
                        "timestamp": dateSent,
                        "type": "video",
                        "creatorUsername": creatorUsername,
                        "creatorAvatarURL": creatorAvatarURL,
                        "creatorID": currentUID,
                        "downloadURL": downloadURL,
                        "thumbnailURL": thumbnailURL,
                        "forwards": 0, // toUserIDs.count
                        "milesTraveled": 0,
                        "mapReference": [currentUID: ["latitude": adjustedLatitude, "longitude": adjustedLongitude, "avatarURL": currentUser.photoURL?.absoluteString ?? "n/a", "username": currentUser.displayName!, "timestamp": timestamp]]
                    ]
                    
                    self.ref.child("mediaItems").child(childID).setValue(mediaItem)
                    
                    if let caption = caption {
                        self.ref.child("mediaItems").child(childID).child("caption").setValue(caption)
                        
                        let comment = Comment(senderID: currentUID, username: creatorUsername, message: caption, timestamp: Date().timeIntervalSince1970, senderAvatarURL: creatorAvatarURL)
                        self.ref.child("mediaItems").child(childID).child("comments").childByAutoId().setValue(comment.dictionaryRepresentation())
                    }
                    
                    self.ref.child("mediaItems").child(childID).child("forwarders").child(currentUID).setValue(true)
                    
                    toUserIDs.forEach { userID in
                        self.ref.child("mediaItems").child(childID).child("recipients").child(userID).setValue(true)
                    }
                    
                    if self.contest {
                        self.ref.child("startAMovement").child(childID).setValue(true)
                    }
                    
                    if self.startAMovement {
                        self.ref.child("contest").child(childID).setValue(true)
                    }
                    
                    SVProgressHUD.setDefaultMaskType(.black)
                    SVProgressHUD.setBackgroundColor(.white)
                    SVProgressHUD.showSuccess(withStatus: "Forwarded!")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }
            }
        }
        
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { (snapshot) in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { (snapshot) in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.showProgress(Float(percentComplete))
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            //            if let error = snapshot.error {
            //                switch (StorageErrorCode(rawValue: error.code)!) {
            //                case .objectNotFound:
            //                    // File doesn't exist
            //                    break
            //                case .unauthorized:
            //                    // User doesn't have permission to access file
            //                    break
            //                case .cancelled:
            //                    // User canceled the upload
            //                    break
            //                case .unknown:
            //                    // Unknown error occurred, inspect the server response
            //                    break
            //                default:
            //                    // A separate error occurred. This is a good place to retry the upload.
            //                    break
            //                }
            //            }
            if let error = snapshot.error {
                print(error.localizedDescription)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.showError(withStatus: "Error Uploading Media")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
    }
    
    func sendPhoto(caption: String?, data: Data, type: String, toUserIDs: [String], currentLocation: [String:Double]) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // File to upload
        let localData = data
        
        let identifier = UUID().uuidString
        let fileRef = storageRef.child("images/\(identifier)")
        
        // Upload file and metadata to the object
        let uploadTask = fileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            guard let downloadURL = metadata.downloadURL()?.absoluteString else { print("No Download URL"); return }
            
            // store downloadURL at database
            if let currentUID = Auth.auth().currentUser?.uid {
                let childID = UUID().uuidString
                let dateSent = Date().timeIntervalSince1970
                self.ref.child("users").child(currentUID).child("uploads").child(childID).setValue(["downloadURL": downloadURL,"thumbnailURL": "n/a", "timestamp": dateSent, "type": "photo"])
                
                NotificationCenter.default.post(Notification(name: Notifications.didUploadMedia))
                
                // add file to the inboxes of selected users
                for uid in toUserIDs {
                    
                    var inboxItem: [String:Any] = [
                        "type": type,
                        "downloadURL": downloadURL,
                        "thumbnailURL": "n/a",
                        "opened": false,
                        "senderID": currentUID,
                        "senderUsername": currentUser.displayName!,
                        "senderAvatarURL": currentUser.photoURL?.absoluteString ?? "n/a",
                        "creatorID": currentUID,
                        "creatorUsername": currentUser.displayName!,
                        "creatorAvatarURL": currentUser.photoURL?.absoluteString ?? "n/a",
                        "timestamp": dateSent
                    ]
                    
                    if let caption = caption { inboxItem["caption"] = caption }
                    
                    self.ref.child("users").child(uid).child("inbox").child(childID).setValue(inboxItem)
                    
                    self.ref.child("users").child(uid).child("notifications").childByAutoId()
                }
                
                guard let creatorUsername = currentUser.displayName else { return }
                let creatorAvatarURL = currentUser.photoURL?.absoluteString ?? "n/a"
                let timestamp = Date().timeIntervalSince1970
                let range = -2...2
                let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
                print(randomDistance)
                let adjustedLatitude = currentLocation["latitude"]! + (Double(randomDistance) * 0.01)
                let adjustedLongitude = currentLocation["longitude"]! + (Double(randomDistance) * 0.01)
                
                var mediaItem: [String:Any] = [
                    "timestamp": dateSent,
                    "type": type,
                    "creatorAvatarURL": creatorAvatarURL,
                    "creatorUsername": creatorUsername,
                    "creatorID": currentUID,
                    "downloadURL": downloadURL,
                    "thumbnailURL": "n/a",
                    "forwards": 0, // toUserIDs.count
                    "milesTraveled": 0,
                    "mapReference": [currentUID: ["latitude": adjustedLatitude, "longitude": adjustedLongitude, "avatarURL": currentUser.photoURL?.absoluteString ?? "n/a", "username": currentUser.displayName!, "timestamp": timestamp]]
                ]
                
                self.ref.child("mediaItems").child(childID).setValue(mediaItem)
                
                if let caption = caption {
                    self.ref.child("mediaItems").child(childID).child("caption").setValue(caption)
                    
                    let comment = Comment(senderID: currentUID, username: creatorUsername, message: caption, timestamp: Date().timeIntervalSince1970, senderAvatarURL: creatorAvatarURL)
                    self.ref.child("mediaItems").child(childID).child("comments").childByAutoId().setValue(comment.dictionaryRepresentation())
                }
                
                self.ref.child("mediaItems").child(childID).child("forwarders").child(currentUID).setValue(true)
                
                toUserIDs.forEach { userID in
                    self.ref.child("mediaItems").child(childID).child("recipients").child(userID).setValue(true)
                }
                
                if self.contest {
                    self.ref.child("contest").child(childID).setValue(true)
                }
                
                if self.startAMovement {
                    self.ref.child("startAMovement").child(childID).setValue(true)
                }
            }
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { (snapshot) in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { (snapshot) in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.showProgress(Float(percentComplete))
        }
        
        uploadTask.observe(.success) { (snapshot) in
            // Upload completed successfully
            // store downloadURL
            
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.showSuccess(withStatus: "Forwarded!")
            SVProgressHUD.dismiss(withDelay: 1.5)
        }
        
        uploadTask.observe(.failure) { (snapshot) in
//            if let error = snapshot.error {
//                switch (StorageErrorCode(rawValue: error.code)!) {
//                case .objectNotFound:
//                    // File doesn't exist
//                    break
//                case .unauthorized:
//                    // User doesn't have permission to access file
//                    break
//                case .cancelled:
//                    // User canceled the upload
//                    break
//                case .unknown:
//                    // Unknown error occurred, inspect the server response
//                    break
//                default:
//                    // A separate error occurred. This is a good place to retry the upload.
//                    break
//                }
//            }
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    
    
//    func isEmailInUse(_ email: String, completion: @escaping ((Error?) -> Void) = {_ in}) -> Bool? {
//        var isEmailInUse: Bool?
//
//        Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            // if there are no providers, the email is not in
//            if let providers = providers { isEmailInUse = !providers.isEmpty }
//        }
//        return isEmailInUse
//    }
}
