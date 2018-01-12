//
//  LoginContainerVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/8/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginContainerVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    // if new FB user, root view should be createUsernameVC
    lazy var createUsernameVC: CreateUsernameVC = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.createUsernameVC) as! CreateUsernameVC
    }()
    
    // if using email, root view should be emailLoginVC
    lazy var emailLoginVC: EmailLoginVC = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.emailLoginVC) as! EmailLoginVC
    }()
    
    lazy var rootNavVC: UINavigationController = {
        let rootVC = self.isUsingEmail ? emailLoginVC : createUsernameVC
        if let delegate = rootVC as? LoginChildDelegate { self.loginChildDelegate = delegate }
        let navVC = UINavigationController(rootViewController: rootVC)
        navVC.setNavigationBarHidden(true, animated: false)
        return navVC
    }()

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var isUsingEmail = true
    weak var loginChildDelegate: LoginChildDelegate?
    weak var previousDelegate: LoginChildDelegate?
    var customInteractor: CustomInteractor?
    
//    let activityIndicatorView: UIActivityIndicatorView = {
//        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//        aiv.translatesAutoresizingMaskIntoConstraints = false
//        aiv.hidesWhenStopped = true
//        return aiv
//    }()
    
    var keyboardShowing = true
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        
        rootNavVC.willMove(toParentViewController: self)
        self.containerView.addSubview(rootNavVC.view)
        self.addChildViewController(rootNavVC)
        rootNavVC.didMove(toParentViewController: self)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if self.rootNavVC.viewControllers.count == 1 {
            self.rootNavVC.visibleViewController?.view.endEditing(true)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.loginChildDelegate = previousDelegate
            self.rootNavVC.visibleViewController?.view.endEditing(true)
            self.rootNavVC.popViewController(animated: true)
        }

    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        loginChildDelegate?.getNextVC(completion: { (nextVC) in
            
            if let tabBarController = nextVC as? TabBarController {
                self.present(tabBarController, animated: true, completion: nil)
            } else {
                self.previousDelegate = self.loginChildDelegate
                self.loginChildDelegate = nextVC as! LoginChildDelegate
                self.rootNavVC.delegate = self
                self.rootNavVC.pushViewController(nextVC, animated: true)
                //self.activityIndicatorView.stopAnimating()
            }
        })
    }
    
    @objc func keyboardShow() {
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func keyboardHide() {
        view.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        let endFrame = ((notification as Notification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if keyboardShowing {
            bottomConstraint.constant = view.bounds.height - endFrame.origin.y + 8
        } else {
            bottomConstraint.constant = view.bounds.height - endFrame.origin.y + 8
        }
        keyboardShowing = !keyboardShowing
        self.view.layoutIfNeeded()
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
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

extension LoginContainerVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            self.customInteractor = CustomInteractor(attachTo: toVC)
            return CustomPushTransition()
        default:
            return CustomPopTransition()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
}

extension LoginContainerVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPushTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPopTransition()
    }
}

protocol LoginChildDelegate: class {
    func getNextVC(completion: @escaping(UIViewController)-> Void)
}
