//
//  CreateGroupVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/2/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class CreateGroupVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var isSelectingMembers = true
    
    weak var pagingDelegate: PagingDelegate?
    weak var createGroupDelegate: CreateGroupDelegate?
    weak var groupNameDelegate: GroupNameDelegate?
    
    var keyboardShowing = true
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectingMembers), name: Notifications.isSelectingMembers, object: nil)
        
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        view.endEditing(true)
        pagingDelegate?.previousPage()
        self.backButton.isHidden = true
        self.nextButton.setTitle("Next", for: .normal)
        isSelectingMembers = true
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if isSelectingMembers {
            view.endEditing(true)
            if createGroupDelegate!.isValidSelection() {
                createGroupDelegate?.saveSelectedMembers()
                pagingDelegate?.nextPage()
                self.backButton.isHidden = false
                nextButton.setTitle("Done", for: .normal)
                isSelectingMembers = false
            }
            
        } else {
            // Done was tapped, save to firebase and go back to list of groups
            groupNameDelegate?.saveGroupName()
            if FirebaseController.shared.groupName != "" {
                FirebaseController.shared.createGroup(withName: FirebaseController.shared.groupName, completion: { (_) in
                    //self.dismiss(animated: true, completion: nil)
                })
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func selectingMembers() {
        isSelectingMembers = true
        self.backButton.isHidden = true
        self.nextButton.setTitle("Next", for: .normal)
        createGroupDelegate?.resetSelection()
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
            bottomConstraint.constant = -(view.bounds.height - endFrame.origin.y)
        } else {
            bottomConstraint.constant = view.bounds.height - endFrame.origin.y
        }
        keyboardShowing = !keyboardShowing
        self.view.layoutIfNeeded()
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPageVC" {
            if let pageVC = segue.destination as? CreateGroupPageVC {
                self.pagingDelegate = pageVC
                guard let selectMembersVC = pageVC.orderedViewControllers.first as? SelectMembersVC else { print("Can't find VC for delegate."); return }
                self.createGroupDelegate = selectMembersVC
                guard let nameGroupVC = pageVC.orderedViewControllers.last as? NameGroupVC else { return }
                self.groupNameDelegate = nameGroupVC
            }
        }
    }

}

protocol PagingDelegate: class {
    func nextPage()
    func previousPage()
}

protocol CreateGroupDelegate: class {
    func saveSelectedMembers()
    func resetSelection()
    func isValidSelection() -> Bool
}

protocol GroupNameDelegate: class {
    func saveGroupName()
}
