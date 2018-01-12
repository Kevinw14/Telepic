//
//  AppDelegate.swift
//  Telepic
//
//  Created by Michael Bart on 8/24/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FBSDKCoreKit
import UserNotifications
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeStoryboard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            self.window?.rootViewController = homeStoryboard.instantiateViewController(withIdentifier: Identifiers.tabBarController)

        } else {
            // No user is signed in.
            window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        }
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
        print("Firebase registration token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        //FirebaseController.shared.updateBadgeCount()
        
        if application.applicationState == .inactive {
            
            guard Auth.auth().currentUser != nil else { return }
            
            if let aps = userInfo["aps"] as? [String:Any] {
                if let category = aps["category"] as? String {
                    switch category {
                    case "notifications":
                        let rootVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController) as! TabBarController
                        rootVC.selectedIndex = 3
                        self.window?.rootViewController = rootVC
                        self.window?.makeKeyAndVisible()
                    case "comments":
                        if let mediaID = userInfo["mediaID"] as? String {
                            print(mediaID)
                            SVProgressHUD.show()
                            FirebaseController.shared.fetchMediaItem(forItemID: mediaID, completion: { (item) in
                                FirebaseController.shared.currentMediaItem = item
                                
                                let imageView = UIImageView()
                                imageView.kf.setImage(with: URL(string: item.downloadURL)!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                                    let rootVC = self.window?.rootViewController as! TabBarController
                                    
                                    let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mediaViewVC) as! MediaViewVC
                                    mediaViewVC.hidesBottomBarWhenPushed = true
                                    mediaViewVC.photo = image
                                    mediaViewVC.isFromNotification = true
                                    let navController = UINavigationController(rootViewController: mediaViewVC)
                                    //                                rootVC.navigationController?.pushViewController(navController, animated: true)
                                    rootVC.present(navController, animated: true, completion: {
                                        let commentsVC = UIStoryboard(name: "Comments", bundle: nil).instantiateViewController(withIdentifier: Identifiers.commentsVC) as! CommentsVC
                                        commentsVC.mediaItemID = mediaID
                                        navController.navigationBar.isHidden = false
                                        navController.pushViewController(commentsVC, animated: true)
                                        SVProgressHUD.dismiss()
                                    })
                                })
                                NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
                            })
                        }
                    case "mediaView":
                        print(category)
                        if let mediaID = userInfo["mediaID"] as? String {
                            print(mediaID)
                            
                        }
                    default:
                        print(category)
                    }
                }
            }
        } else if application.applicationState == .active {
            FirebaseController.shared.fetchNotifications()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        FirebaseController.shared.resetBadgeCount()
        AppEventsLogger.activate(application)
        
        //FirebaseController.remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)!
        //        FirebaseController.remoteConfig.fetch(withExpirationDuration: 1) { (status, error) in
        //            if let error = error {
        //                print(error.localizedDescription)
        //                return
        //            }
        //
        //            FirebaseController.remoteConfig.activateFetched()
        //            print(FirebaseController.remoteConfig["contestOfTheWeek"].stringValue)
        //        }
        FirebaseController.remoteConfig.fetch { (status, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            FirebaseController.remoteConfig.activateFetched()

            print(FirebaseController.remoteConfig["contestOfTheWeek"].stringValue)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

