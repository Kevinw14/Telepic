//
//  ShareViewController.swift
//  TelepicShareExt
//
//  Created by Michael Bart on 11/7/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    var friends: [String:String]?
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Forward Photo"
        
        let defaults = UserDefaults(suiteName: "group.MichaelBart.Telepic")
        defaults?.synchronize()
        
        if let friends = defaults?.object(forKey: "friends") as? [String:String] {
            print(friends)
            self.friends = friends
        } else {
            print("Can't find friends.")
        }
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        guard let friends = self.friends else { return [] }
        
        var friendItems = [SLComposeSheetConfigurationItem]()
        for (key, value) in friends {
            if let item = SLComposeSheetConfigurationItem() {
                item.title = value
                item.tapHandler = {
                    
                }
                friendItems.append(item)
            }
        }
        
        return friendItems
    }

}
