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
        loginManager.logIn([.publicProfile], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    // user is signed in
                    UserController.shared.currentUser.usingFacebook = true
                    print("successfully signed in using firebase")
                })
            }
        }
    }
    
    @IBAction func continueWithEmailButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            let emailLoginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmailLoginVC") as! EmailLoginVC
            emailLoginVC.isHeroEnabled = true
            emailLoginVC.heroModalAnimationType = .slide(direction: .left)
            self.hero_replaceViewController(with: emailLoginVC)
        }
    }
}
