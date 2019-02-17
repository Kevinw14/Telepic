//
//  AddFBFriendsVC.swift
//  Telepic
//
//  Created by Michael Bart on 1/8/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class AddFBFriendsVC: UIViewController, FBSDKAppInviteDialogDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
        let isUsingFacebook = UserDefaults.standard.value(forKey: "isUsingFacebook") as! Bool
        
        if isUsingFacebook {
            let inviteDialog = FBSDKAppInviteDialog()
            
            if inviteDialog.canShow {
                let appLinkURL = URL(string: "https://itunes.apple.com/app/id1279816444")
                let previewImageURL = URL(string: "")
                
                let inviteContent = FBSDKAppInviteContent()
                inviteContent.appLinkURL = appLinkURL
                inviteContent.appInvitePreviewImageURL = previewImageURL
                
                inviteDialog.content = inviteContent
                inviteDialog.delegate = self
                inviteDialog.show()
            }
        } else {
            let ac = UIAlertController(title: "Not Using Facebook", message: "Log in using Facebook to use this feature.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

    @IBAction func skip(_ sender: Any) {
        // delegate present tabbarcontroller
        let nextVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController)
        self.parent?.present(nextVC, animated: true, completion: nil)
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print(results)
        // delegate present tabbarcontroller
        let nextVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController)
        self.parent?.present(nextVC, animated: true, completion: nil)
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Did fail with error")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
