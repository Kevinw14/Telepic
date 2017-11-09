//
//  FirebaseController.swift
//  Telepic
//
//  Created by Michael Bart on 10/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class FirebaseController {
    
    static var shared = FirebaseController()
    
    private var ref = Database.database().reference()
    
    let storageRef = Storage.storage().reference()
    
    var inboxItems = [InboxItem]()
    
    var photoToPresent: UIImageView? {
        didSet {
            NotificationCenter.default.post(name: Notifications.presentMedia, object: self)
        }
    }
    
    var currentMediaItem: MediaItem?
    
    var filteredUsers = [SearchableUser]()
    
    var selectedGroupMembers = [Friend]()
    
    var groupName = ""
    
    var friendRequests = [FriendRequest]()
    
    var eventNotifications = [EventNotification]() {
        didSet {
            NotificationCenter.default.post(name: Notifications.newEventNotification, object: self)
        }
    }
    
    var friends = [Friend]()
    
//    var receivableFriendIDs = [String]() {
//        didSet {
//            print(receivableFriendIDs)
//        }
//    }
//    
//    func fetchReceivableFriendIDs(forItemID itemID: String) {
//        let friendIDs = friends.map { $0.uid }
//        
//        for friendID in friendIDs {
//            let itemRef = self.ref.child("users").child(friendID).child("inbox").child(itemID)
//            itemRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                if snapshot.exists() {
//                    self.receivableFriendIDs.append(friendID)
//                }
//            })
//        }
//    }
    
    func storeUsername(_ username: String, uid: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        self.ref.child("users").child(uid).setValue(["username": username, "searchableUsername": username.lowercased()])
        self.ref.child("usernames").child(username.lowercased()).setValue(true)
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
        
    }
    
    func signOut() {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
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
                
                    let banner = StatusBarNotificationBanner(title: notification.message, style: .success)
                    banner.show()
                    
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
                let inboxItem = InboxItem(itemID: key, dict: value)
                inboxItems.append(inboxItem)
            }
            self.inboxItems = inboxItems.sorted { $0.timestamp > $1.timestamp }
            NotificationCenter.default.post(name: Notifications.didLoadInbox, object: self)
        }
    }
    
    func isInboxEmpty() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let inboxRef = ref.child("users").child(currentUser.uid).child("inbox")
        inboxRef.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.hasChildren() { NotificationCenter.default.post(name: Notifications.inboxIsEmpty, object: self) }
        }
    }
    
    func setItemOpened(forItemID itemID: String, latitude: Double, longitude: Double) {
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child("users").child(currentUser.uid).child("inbox").child(itemID).updateChildValues(["opened": true])
        let avatarURL = currentUser.photoURL?.absoluteString ?? "n/a"

        // DANGER
        let timestamp = Date().timeIntervalSince1970
        let range = -2...2
        let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
        print(randomDistance)
        let adjustedLatitude = latitude + (Double(randomDistance) * 0.01)
        let adjustedLongitude = longitude + (Double(randomDistance) * 0.01)
        
        ref.child("mediaItems").child(itemID).child("mapReference").child(currentUser.uid).setValue(["latitude": adjustedLatitude, "longitude": adjustedLongitude, "avatarURL": avatarURL, "username": currentUser.displayName!, "timestamp": timestamp])
        
        ref.child("users").child(currentUser.uid).child("notifications").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let notifications = snapshot.value as? [String:[String:Any]] else { return }
                var updatedNotifications = [EventNotification]()
                for (key, value) in notifications {
                    if let id = value["mediaID"] as? String, id == itemID {
                        self.ref.child("users").child(currentUser.uid).child("notifications").child(key).removeValue()
                    } else {
                        updatedNotifications.append(EventNotification(dict: value))
                    }
                }
                self.eventNotifications = updatedNotifications
            }
        }
        
//        self.ref.child("mediaItems").child(itemID).child("mapReference").observeSingleEvent(of: .value, with: { (snapshot) in
//            var distance
//            var previousCoordinate: CLLocation?
//            if let mapRef = snapshot.value as? [String:[String:Any]], snapshot.exists() {
//                mapRef.values.forEach { value in
//                    
//                }
//            }
//        })
        
        loadInboxItems()
    }
    
    
    
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
                
                let banner = StatusBarNotificationBanner(title: notification.message, style: .success)
                banner.show()
                
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
    }
    
    func fetchFriends() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(currentUID).child("friends").observeSingleEvent(of: .value) { (snapshot) in
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
    
    func fetchMediaItem(forItemID itemID: String, completion: @escaping (MediaItem) -> Void) {
        
        self.ref.child("mediaItems").child(itemID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let mediaItemDict = snapshot.value as? [String:Any] else { return }
                let creatorUsername = mediaItemDict["creatorUsername"] as! String
                let creatorID = mediaItemDict["creatorID"] as! String
                let downloadURL = mediaItemDict["downloadURL"] as! String
                let thumbnailURL = mediaItemDict["thumbnailURL"] as! String
                let type = mediaItemDict["type"] as! String
                let forwards = mediaItemDict["forwards"] as! Int
                let mapReference = mediaItemDict["mapReference"] as! [String:[String:Any]]
                let milesTraveled = mediaItemDict["milesTraveled"] as! Int
                let mediaItem = MediaItem(itemID: itemID, type: type, creatorUsername: creatorUsername, creatorID: creatorID, downloadURL: downloadURL, thumbnailURL: thumbnailURL, forwards: forwards, mapReference: mapReference, milesTraveled: milesTraveled)
                completion(mediaItem)
                
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
                        users.append(SearchableUser(uid: key, username: username, avatarURL: avatarURL))
                    }
                }
                print(self.filteredUsers)
                self.filteredUsers = users
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUsers))
            })
        }
    }
    
    func getValidForwardTargets(_ item: InboxItem, targets: [String], completion: @escaping ([String]) -> Void) {
        var validIDs = [String]()
        
        for uid in targets {
            self.ref.child("users").child(uid).child("inbox").child(item.itemID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("User already has inbox item.")
                } else if uid == item.creatorID {
                    print("User is the creator.")
                } else {
                    validIDs.append(uid)
                    if uid == targets.last { completion(validIDs) }
                }
            })
        }
    }
    
    func forwardInboxItem(_ item: InboxItem, toFriendIDs friendIDs: [String]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if let currentUID = Auth.auth().currentUser?.uid {
            
            let dateSent = Date().timeIntervalSince1970
            let inboxItem: [String:Any] = [
                "type": item.type,
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
            
            getValidForwardTargets(item, targets: friendIDs, completion: { (validIDs) in
                guard validIDs.count != 0 else {
                    // alert user
                    print("Error: no valid forward targets.")
                    return
                }
                
                let forwardCount = validIDs.count
                for uid in validIDs {
                    self.ref.child("users").child(uid).child("inbox").child(item.itemID).setValue(inboxItem)
                }
                
                self.ref.child("users").child(currentUID).child("forwards").child(item.itemID).setValue(["downloadURL": item.downloadURL, "timestamp": dateSent])
                NotificationCenter.default.post(Notification(name: Notifications.didForwardMedia))
                
                
                let forwardCountRef = self.ref.child("users").child(item.creatorID).child("forwardCount")
                forwardCountRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let oldCount = snapshot.value as! Int
                        let newCount = oldCount + forwardCount
                        forwardCountRef.setValue(newCount)
                    } else {
                        forwardCountRef.setValue(forwardCount)
                    }
                })
                NotificationCenter.default.post(Notification(name: Notifications.userDataChanged))
                
                
                var mediaItem = [String:Any]()
                self.ref.child("mediaItems").child(item.itemID).child("forwards").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, snapshot.exists() {
                        mediaItem["forwards"] = value + forwardCount
                        self.ref.child("mediaItems").child(item.itemID).updateChildValues(mediaItem)
                    }
                })
            })
        }
    }
    
    func fetchNotifications() {
        
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
    
//    func fetchMostForwarded() {
//        
//    }
//    
//    func fetchMostMilesTraveled() {
//        
//    }
//    
//    func fetchNewItems() {
//        
//    }
    
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
    
    func sendVideo(videoURL: URL, thumbnailData: Data, toUserIDs: [String], currentLocation: [String:Double]) {
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
                        
                        let inboxItem: [String:Any] = [
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
                        
                        self.ref.child("users").child(uid).child("inbox").child(childID).setValue(inboxItem)
                        
                        self.ref.child("users").child(uid).child("notifications").childByAutoId()
                    }
                    
                    guard let creatorUsername = currentUser.displayName else { return }
                    let timestamp = Date().timeIntervalSince1970
                    let range = -2...2
                    let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
                    print(randomDistance)
                    let adjustedLatitude = currentLocation["latitude"]! + (Double(randomDistance) * 0.01)
                    let adjustedLongitude = currentLocation["longitude"]! + (Double(randomDistance) * 0.01)
                    
                    let mediaItem: [String:Any] = [
                        "type": "video",
                        "creatorUsername": creatorUsername,
                        "creatorID": currentUID,
                        "downloadURL": downloadURL,
                        "thumbnailURL": thumbnailURL,
                        "forwards": toUserIDs.count,
                        "milesTraveled": 0,
                        "mapReference": [currentUID: ["latitude": adjustedLatitude, "longitude": adjustedLongitude, "avatarURL": currentUser.photoURL?.absoluteString ?? "n/a", "username": currentUser.displayName!, "timestamp": timestamp]]
                    ]
                    self.ref.child("mediaItems").child(childID).setValue(mediaItem)
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
    
    func sendPhoto(data: Data, toUserIDs: [String], currentLocation: [String:Double]) {
        
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
                    
                    let inboxItem: [String:Any] = [
                        "type": "photo",
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
                    
                    self.ref.child("users").child(uid).child("inbox").child(childID).setValue(inboxItem)
                    
                    self.ref.child("users").child(uid).child("notifications").childByAutoId()
                }
                
                guard let creatorUsername = currentUser.displayName else { return }
                let timestamp = Date().timeIntervalSince1970
                let range = -2...2
                let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
                print(randomDistance)
                let adjustedLatitude = currentLocation["latitude"]! + (Double(randomDistance) * 0.01)
                let adjustedLongitude = currentLocation["longitude"]! + (Double(randomDistance) * 0.01)
                
                let mediaItem: [String:Any] = [
                    "type": "photo",
                    "creatorUsername": creatorUsername,
                    "creatorID": currentUID,
                    "downloadURL": downloadURL,
                    "thumbnailURL": "n/a",
                    "forwards": toUserIDs.count,
                    "milesTraveled": 0,
                    "mapReference": [currentUID: ["latitude": adjustedLatitude, "longitude": adjustedLongitude, "avatarURL": currentUser.photoURL?.absoluteString ?? "n/a", "username": currentUser.displayName!, "timestamp": timestamp]]
                ]
                self.ref.child("mediaItems").child(childID).setValue(mediaItem)
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
