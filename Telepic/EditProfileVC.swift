//
//  EditProfileVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/27/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditProfileVC: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var usernameBioCell: UITableViewCell!
    
    var username: String?
    var bio: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = username, let bio = bio {
            self.usernameTextField.text = username
            self.bioTextView.text = bio
        }
        
        tableView.estimatedRowHeight = 202
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
        
        bioTextView.delegate = self
        
        usernameTextField.setBottomBorder()
        bioTextView.textContainerInset = UIEdgeInsets.zero
        bioTextView.textContainer.lineFragmentPadding = 0

        self.navigationItem.title = "Edit Profile"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveChanges))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(Notification(name: Notifications.userDataChanged))
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        usernameBioCell.selectionStyle = .none
        return usernameBioCell
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == bioTextView {
            let newHeight = usernameBioCell.frame.size.height + textView.contentSize.height
            usernameBioCell.frame.size.height = newHeight
            updateTableViewContentOffsetForTextView()
        }
    }
    
    func updateTableViewContentOffsetForTextView() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveChanges() {
        guard let username = usernameTextField.text, let uid = Auth.auth().currentUser?.uid else { return }
        if Auth.auth().currentUser?.displayName == username {
            if bioTextView.text != "" {
                FirebaseController.shared.storeBio(uid: uid, text: bioTextView.text)
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            FirebaseController.shared.updateUsername(username)
            
            if bioTextView.text != "" {
                FirebaseController.shared.storeBio(uid: uid, text: bioTextView.text)
            }
            self.navigationController?.popViewController(animated: true)
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
