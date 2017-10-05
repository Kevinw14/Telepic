//
//  EmailLoginVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/4/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class EmailLoginVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var spacerHeightConstraint: NSLayoutConstraint!
    
    var signingIn = false
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        emailTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        loginVC.isHeroEnabled = true
        loginVC.heroModalAnimationType = .slide(direction: .right)
        self.hero_replaceViewController(with: loginVC)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if emailTextField.text == "michaeljbart@me.com" {
            let existingAccountPWInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExistingAccountPWInputVC") as! ExistingAccountPWInputVC
            existingAccountPWInputVC.isHeroEnabled = true
            existingAccountPWInputVC.heroModalAnimationType = .slide(direction: .left)
            existingAccountPWInputVC.userEmail = "michaeljbart@me.com"
            self.hero_replaceViewController(with: existingAccountPWInputVC)
        }
        
        guard let emailText = emailTextField.text else { return }
        guard let email = validator.validate(email: emailText) else { return }
        
        UserController.shared.currentUser.email = email
        
        let newAccountPWInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAccountPWInputVC") as! NewAccountPWInputVC
        newAccountPWInputVC.isHeroEnabled = true
        newAccountPWInputVC.heroModalAnimationType = .slide(direction: .left)
        self.hero_replaceViewController(with: newAccountPWInputVC)
        
        if emailTextField.text == "newAccount@email.com" {
            let newAccountPWInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAccountPWInputVC") as! NewAccountPWInputVC
            newAccountPWInputVC.isHeroEnabled = true
            newAccountPWInputVC.heroModalAnimationType = .slide(direction: .left)
            newAccountPWInputVC.userEmail = "newAccount@email.com"
            self.hero_replaceViewController(with: newAccountPWInputVC)
        }
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
