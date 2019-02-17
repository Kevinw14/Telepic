//
//  LoginVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/4/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var facebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.loginBehavior = .web
        loginManager.logIn(readPermissions: [.publicProfile, .userFriends], viewController : self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    // user is signed in
                    UserController.shared.currentUser.usingFacebook = true
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "isUsingFacebook")
                    // if user has a username continue to inbox
                    if let user = user {
                        FirebaseController.shared.isUsernameStored(uid: user.uid, completion: { (result) in
                            if result {
                                let tabBarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController)
                                self.present(tabBarController, animated: true, completion: nil)
                                
                            } else {
                                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.loginContainerVC) as! LoginContainerVC
                                nextVC.isUsingEmail = false
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }
                        })
                    }
                    
                    print("successfully signed in using firebase")
                })
            }
        }
    }
    
    @IBAction func continueWithEmailButtonTapped(_ sender: Any) {
        UserController.shared.currentUser.usingFacebook = false
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isUsingFacebook")
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.loginContainerVC) as! LoginContainerVC
        nextVC.isUsingEmail = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
