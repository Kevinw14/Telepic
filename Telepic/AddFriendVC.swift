//
//  AddFriendVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/10/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AddFriendVC: UIViewController, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableHeaderView?.layer.backgroundColor = UIColor.white.cgColor
        searchController.extendedLayoutIncludesOpaqueBars = true
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
                
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notifications.didLoadUsers, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Back button
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let titleAttrs = [
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "333333"),
            NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 18)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        self.navigationItem.title = "Add Friend"
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func updateData() {
        tableView.reloadData()
    }
    
//    @objc func adjustForKeyboard(notification: Notification) {
//        let userInfo = notification.userInfo!
//
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//
//        if notification.name == Notification.Name.UIKeyboardWillHide {
//            tableView.contentInset = UIEdgeInsets.zero
//        } else {
//            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
//        }
//
//        tableView.scrollIndicatorInsets = tableView.contentInset
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell") as? AddFriendCell else { return UITableViewCell() }
        
        let user = FirebaseController.shared.filteredUsers[indexPath.row]
        
        cell.usernameLabel.text = user.username
        cell.uid = user.uid
        cell.delegate = self
        
        let url = URL(string: user.avatarURL)
        cell.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = FirebaseController.shared.filteredUsers[indexPath.row]
        
        segueToProfileVC(withUID: user.uid, username: user.username)
    }
    
    func segueToProfileVC(withUID uid: String, username: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()?.children[0] as! ProfileVC
        profileVC.userID = uid
        if Auth.auth().currentUser!.uid != uid {
            profileVC.isCurrentUser = false
            profileVC.username = username
        }
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.filteredUsers.count
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            FirebaseController.shared.searchUsers(text: searchText.lowercased())
            tableView.reloadData()
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

extension AddFriendVC: AddFriendDelegate {
    func sendRequest(uid: String, cell: UITableViewCell) {
        FirebaseController.shared.sendFriendRequest(toUID: uid)
        let index = tableView.indexPath(for: cell)?.row
        FirebaseController.shared.filteredUsers.remove(at: index!)
        tableView.reloadData()
    }
}
