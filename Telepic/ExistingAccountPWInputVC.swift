//
//  ExistingAccountPWInputVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ExistingAccountPWInputVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var userEmail = UserController.shared.currentUser.email

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.becomeFirstResponder()
        passwordTextField.tintColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let userEmail = userEmail {
            promptLabel.text = "Welcome back,\n\(userEmail)"
        }
    }
}

extension ExistingAccountPWInputVC: LoginChildDelegate {
    func getNextVC(completion: @escaping (UIViewController) -> Void) {
        guard let userEmail = userEmail, let password = passwordTextField.text, password != "" else {
            print("Empty fields.")
            return
        }
        self.passwordTextField.resignFirstResponder()
        
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: userEmail, password: password) { (user, error) in
            
            SVProgressHUD.dismiss()
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let user = user {
                print("Signed in as user: \(user)")
                let nextVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: Identifiers.tabBarController)
                completion(nextVC)
            }
        }
    }
}
