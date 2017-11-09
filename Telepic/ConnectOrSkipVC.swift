//
//  ConnectOrSkipVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/7/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Hero

class ConnectOrSkipVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let createUsernameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateUsernameVC") as! CreateUsernameVC
        createUsernameVC.isHeroEnabled = true
        createUsernameVC.heroModalAnimationType = .slide(direction: .right)
        self.hero_replaceViewController(with: createUsernameVC)
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        let addFBFriendsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFBFriendsVC")
        addFBFriendsVC.isHeroEnabled = true
        addFBFriendsVC.heroModalAnimationType = .slide(direction: .left)
        
        self.hero_replaceViewController(with: addFBFriendsVC)
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
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
