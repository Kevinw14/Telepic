//
//  InviteFriendsVC.swift
//  Telepic
//
//  Created by Michael Bart on 12/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import AddressBook


class InviteFriendsVC: UIViewController, FBSDKAppInviteDialogDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func fbInviteButtonTapped(_ sender: Any) {
        let isUsingFacebook = UserDefaults.standard.value(forKey: "isUsingFacebook") as! Bool
        
        if isUsingFacebook {
            let inviteDialog = FBSDKAppInviteDialog()
            
            if inviteDialog.canShow() {
                let appLinkURL = URL(string: "https://itunes.apple.com/app/id1279816444")
                let previewImageURL = URL(string: "")
                
                let inviteContent = FBSDKAppInviteContent()
                inviteContent.appLinkURL = appLinkURL
                inviteContent.appInvitePreviewImageURL = previewImageURL
                
                inviteDialog.content = inviteContent
                inviteDialog.delegate = self
                self.navigationController?.navigationBar.isHidden = true
                inviteDialog.show()
            }
        } else {
            let ac = UIAlertController(title: "Not Using Facebook", message: "Log in using Facebook to use this feature.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print(results)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Did fail with error")
        self.navigationController?.navigationBar.isHidden = false
    }
}
