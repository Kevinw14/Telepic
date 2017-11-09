//
//  SelectMembersVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/2/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class SelectMembersVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseController.shared.fetchFriends()
        
        searchBar.tintColor = .white
        searchBar.barTintColor = .white
        searchBar.setTextColor(color: .white)
        
        if let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField,
            let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            
            let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as! UIButton
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = .white
            
            //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .white
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.didLoadFriends, object: nil)
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("view appeared")
        NotificationCenter.default.post(Notification(name: Notifications.isSelectingMembers))
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

extension SelectMembersVC: CreateGroupDelegate {
    func saveSelectedMembers() {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return }
        let selectedFriends = selectedIndexPaths.map { FirebaseController.shared.friends[$0.row] }
        FirebaseController.shared.selectedGroupMembers = selectedFriends
    }
    
    func resetSelection() {
        guard let selectedIndexes = tableView.indexPathsForVisibleRows else { return }
        for indexPath in selectedIndexes {
            tableView.deselectRow(at: indexPath, animated: false)
            guard let cell = tableView.cellForRow(at: indexPath) as? FriendCell else { return }
            cell.checkmark.isHidden = true
        }
        FirebaseController.shared.selectedGroupMembers = [Friend]()
    }
    
    func isValidSelection() -> Bool {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return false }
        
        return !selectedIndexPaths.isEmpty
    }
}

extension SelectMembersVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendCell else { return UITableViewCell() }
        
        cell.friend = FirebaseController.shared.friends[indexPath.row]
        cell.setUpCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendCell else { return }
        
        cell.checkmark.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendCell else { return }
        
        cell.checkmark.isHidden = true
    }
}
