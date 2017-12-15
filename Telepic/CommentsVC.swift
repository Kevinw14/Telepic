//
//  CommentsVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

struct Comment {
    var senderID: String
    var username: String
    var message: String
    var timestamp: Double
    var senderAvatarURL: String
    
    func dictionaryRepresentation() -> [String:Any] {
        
        return [
            "senderID": self.senderID,
            "senderAvatarURL": self.senderAvatarURL,
            "username": self.username,
            "message": self.message,
            "timestamp": self.timestamp
        ]
    }
}

extension Comment {
    init(dict: [String:Any]) {
        let senderID = dict["senderID"] as! String
        let username = dict["username"] as! String
        let message = dict["message"] as! String
        let timestamp = dict["timestamp"] as! Double
        let senderAvatarURL = dict["senderAvatarURL"] as! String
        
        self.init(senderID: senderID,
                  username: username,
                  message: message,
                  timestamp: timestamp,
                  senderAvatarURL: senderAvatarURL)
    }
}

class CommentsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyCommentsView: UIView!
    
    var comments = [Comment]() {
        didSet {
            updateData()
        }
    }
    
    var keyboardShowing = false
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    lazy var backBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    var mediaItemID: String?
    var isModal = false
    
    let dateFormatter = DateFormatter()
    let placeHolderText = "Post a comment..."
    let placeHolderColor = UIColor(hexString: "#B0B0B0")
    let postButtonColor = UIColor(hexString: "#007AFF")
    let textColor = UIColor(hexString: "333333")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.edgesForExtendedLayout = []

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 74
        
        postButton.isEnabled = false
        
        inputTextView.delegate = self
        //inputTextView.textContainerInset = .zero
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEmptyCommentsView), name: Notifications.emptyComments, object: nil)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        
        guard let mediaItemID = mediaItemID else { return }
        FirebaseController.shared.fetchComments(forMediaItemID: mediaItemID) { (comments) in
            self.comments = comments
            self.tableView.isHidden = false
            self.emptyCommentsView.isHidden = true
        }
        
        let titleAttrs = [
            NSAttributedStringKey.foregroundColor: UIColor(hexString: "333333"),
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.navigationItem.title = "Comments"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func showEmptyCommentsView() {
        self.tableView.isHidden = true
        self.emptyCommentsView.isHidden = false
    }
    
    @objc func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        if let text = inputTextView.text, let mediaItemID = mediaItemID {
            FirebaseController.shared.postComment(text: text, toMediaItem: mediaItemID)
            self.inputTextView.text = ""
            self.postButton.setTitleColor(placeHolderColor, for: .normal)
            self.postButton.isEnabled = false
            self.tableViewScrollToBottom(animated: true, delay: 0)
        }
    }
    
    @IBAction func unwindToMapVC(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToMapVC", sender: self)
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func updateData() {
        tableView.reloadData()
    }
    
    @objc func keyboardShow() {
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func keyboardHide() {
        view.removeGestureRecognizer(tapGestureRecognizer)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        let endFrame = ((notification as Notification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        print(self.navigationController?.navigationBar.frame.height)
        
        if keyboardShowing {
            bottomConstraint.constant = -((view.bounds.height + 64) - endFrame.origin.y)
        } else {
            bottomConstraint.constant = (view.bounds.height + 64) - endFrame.origin.y
        }
        keyboardShowing = !keyboardShowing
        self.view.layoutIfNeeded()
        
        tableViewScrollToBottom(animated: true, delay: 0)
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

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentCell else { return UITableViewCell() }
        
        let comment = comments[indexPath.row]
        cell.comment = comment
        cell.setUpViews()
        
        let date = NSDate(timeIntervalSince1970: comment.timestamp)
        cell.timestampLabel.text = dateFormatter.timeSince(from: date, numericDates: true)
        
        return cell
    }
    
    func tableViewScrollToBottom(animated: Bool, delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = comments[indexPath.row]
        
        segueToProfileVC(withUID: comment.senderID, username: comment.username)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func segueToProfileVC(withUID uid: String, username: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()?.childViewControllers[0] as! ProfileVC
        
        profileVC.isCurrentUser = false
        profileVC.username = username
        profileVC.userID = uid
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension CommentsVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" || textView.text == placeHolderText {
            postButton.isEnabled = false
            postButton.setTitleColor(placeHolderColor, for: .normal)
        } else {
            postButton.isEnabled = true
            postButton.setTitleColor(postButtonColor, for: .normal)
            textView.textColor = textColor
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = ""
            textView.textColor = textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeHolderText
            textView.textColor = placeHolderColor
            postButton.isEnabled = false
            postButton.setTitleColor(placeHolderColor, for: .normal)
        }
    }
}
