//
//  NewAccountPWInputVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class NewAccountPWInputVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spacerHeightConstraint: NSLayoutConstraint!
    
    var userEmail = UserController.shared.currentUser.email
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let userEmail = userEmail {
            promptLabel.text = "Welcome,\n\(userEmail)"
        }
        
        passwordTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let emailLoginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmailLoginVC") as! EmailLoginVC
        emailLoginVC.isHeroEnabled = true
        emailLoginVC.heroModalAnimationType = .slide(direction: .right)
        self.hero_replaceViewController(with: emailLoginVC)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        guard let password = passwordTextField.text else { return }
        
        if validator.isPasswordValid(password) {
            
            UserController.shared.currentUser.password = password
            
            let createUsernameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateUsernameVC") as! CreateUsernameVC
            createUsernameVC.isHeroEnabled = true
            createUsernameVC.heroModalAnimationType = .slide(direction: .left)
            self.hero_replaceViewController(with: createUsernameVC)
        } else {
            print("password not valid")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
