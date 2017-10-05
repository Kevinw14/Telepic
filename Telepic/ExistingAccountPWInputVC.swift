//
//  ExistingAccountPWInputVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ExistingAccountPWInputVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spacerHeightConstraint: NSLayoutConstraint!
    
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.tintColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let userEmail = userEmail {
            promptLabel.text = "Welcome back,\n\(userEmail)"
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
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if Constant.keyboardHeight == 0.0 {
                Constant.keyboardHeight = keyboardHeight + 8
            }
            spacerHeightConstraint.constant = Constant.keyboardHeight
        }
    }

}
