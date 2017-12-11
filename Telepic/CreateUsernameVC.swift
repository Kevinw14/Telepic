//
//  CreateUsernameVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateUsernameVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        usernameTextField.becomeFirstResponder()
    }
}

extension CreateUsernameVC: LoginChildDelegate {
    func getNextVC(completion: @escaping (UIViewController) -> Void) {
        guard let username = usernameTextField.text else { return }
        
        if username.characters.count <= 24 {
            
            UserController.shared.currentUser.username = username
            
            if UserController.shared.currentUser.usingFacebook {
                
                // store username on firebase
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                SVProgressHUD.show()
                FirebaseController.shared.verifyUniqueUsername(username, completion: { (isUnique) in
                    if isUnique {
                        self.usernameTextField.resignFirstResponder()
                        FirebaseController.shared.storeUsername(username, uid: uid)
                        SVProgressHUD.dismiss()
                        let nextVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController)
                        completion(nextVC)
                    } else {
                        SVProgressHUD.dismiss()
                        print("Username is already taken.")
                    }
                })
//                let addFBFriendsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFBFriendsVC")
//                completion(addFBFriendsVC)
                
            } else {
                // create user using email & password
                guard let email = UserController.shared.currentUser.email,
                    let password = UserController.shared.currentUser.password else { return }
                
                SVProgressHUD.show()
                
                DispatchQueue.main.async {
                    FirebaseController.shared.verifyUniqueUsername(username, completion: { (isUnique) in
                        if isUnique {
                            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                SVProgressHUD.dismiss()
                                guard let uid = user?.uid else { return }
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    self.usernameTextField.resignFirstResponder()
                                    FirebaseController.shared.storeUsername(username, uid: uid)
                                    let nextVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController)
                                    completion(nextVC)
                                }
                            })
                        } else {
                            SVProgressHUD.dismiss()
                            print("Username is already taken.")
                        }
                    })
                }
                SVProgressHUD.dismiss()
                print("Still loading...")
            }
        } else {
            print("username is too long")
        }
    }
}
