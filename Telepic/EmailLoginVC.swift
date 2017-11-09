//
//  EmailLoginVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/4/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class EmailLoginVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    var signingIn = false
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.becomeFirstResponder()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension EmailLoginVC: LoginChildDelegate {
    func getNextVC(completion: @escaping(UIViewController) -> Void) {
        
        guard let emailText = emailTextField.text else {
            print("Email field is empty.")
            return
        }
        guard let email = validator.validate(email: emailText) else {
            print("Email is invalid.")
            return
        }
        
        UserController.shared.currentUser.email = email
        
        SVProgressHUD.show()
        DispatchQueue.main.async {
            Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if providers != nil {
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.existingAccountPWInputVC) as! ExistingAccountPWInputVC
                    completion(nextVC)
                } else {
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.newAccountPWInputVC) as! NewAccountPWInputVC
                    completion(nextVC)
                }
                print("Finished loading.")
            }
        }
    }
}
