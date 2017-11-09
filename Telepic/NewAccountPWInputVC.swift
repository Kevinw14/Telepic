//
//  NewAccountPWInputVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewAccountPWInputVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var userEmail = UserController.shared.currentUser.email
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.becomeFirstResponder()
        passwordTextField.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let userEmail = userEmail {
            promptLabel.text = "Welcome,\n\(userEmail)"
        }
        
    }
}

extension NewAccountPWInputVC: LoginChildDelegate {
    func getNextVC(completion: @escaping (UIViewController) -> Void) {
        guard let password = passwordTextField.text else {
            print("Password field is empty.")
            return
        }
        SVProgressHUD.show()
        if validator.isPasswordValid(password) {
            
            UserController.shared.currentUser.password = password
            
            let createUsernameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateUsernameVC") as! CreateUsernameVC
            completion(createUsernameVC)
            
        } else {
            print("password not valid")
        }
        SVProgressHUD.dismiss()
    }
}
