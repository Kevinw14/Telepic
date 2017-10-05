//
//  CreateUsernameVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase

class CreateUsernameVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var spacerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        usernameTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text else { return }
        
        if username.characters.count <= 24 {
            
            UserController.shared.currentUser.username = username
            
            if UserController.shared.currentUser.usingFacebook {
                // create user using facebook
                
                // store username on firebase
                
                let addFBFriendsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFBFriendsVC")
                addFBFriendsVC.isHeroEnabled = true
                addFBFriendsVC.heroModalAnimationType = .slide(direction: .left)
                self.usernameTextField.resignFirstResponder()
                self.hero_replaceViewController(with: addFBFriendsVC)
                
            } else {
                // create user using email & password
                guard let email = UserController.shared.currentUser.email,
                    let password = UserController.shared.currentUser.password else { return }
                
                print("Loading...")
                
                DispatchQueue.main.async {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("finished loading...")
                            
                            // store username on firebase
                            
                            
                            self.performSegue(withIdentifier: "newUserInbox", sender: nil)
                        }
                    })
                }
                
                print("Still loading...")
            }
            
            
        } else {
            print("username is too long")
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let newAccountPWInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAccountPWInputVC") as! NewAccountPWInputVC
        newAccountPWInputVC.isHeroEnabled = true
        newAccountPWInputVC.heroModalAnimationType = .slide(direction: .right)
        self.hero_replaceViewController(with: newAccountPWInputVC)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if Constant.keyboardHeight == 0.0 {
                Constant.keyboardHeight = keyboardHeight + 8
            }
            spacerHeightConstraint.constant = Constant.keyboardHeight
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
