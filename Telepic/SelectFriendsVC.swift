//
//  SelectFriendsVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/3/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class SelectFriendsVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.didLoadValidTargets, object: nil)
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SelectFriendsVC: SendVCDelegate {
    func getSelectedFriendIDs() -> [String]? {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return nil }
        let friendIDs = indexPaths.map { FirebaseController.shared.validForwardTargets[$0.row].uid }
        
        return friendIDs
    }
}

extension SelectFriendsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.validForwardTargets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendCell else { return UITableViewCell() }
        
        cell.friend = FirebaseController.shared.validForwardTargets[indexPath.row]
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
