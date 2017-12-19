//
//  SelectFriendsVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/3/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class SelectFriendsVC: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tapGesture: UITapGestureRecognizer!
    var searchController: UISearchController!
    
    var filteredFriends = [Friend]()
    var selectedFriendIDs = [String]()
    
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
        
        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notifications.didLoadValidTargets, object: nil)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText != "" {
                filteredFriends = FirebaseController.shared.validForwardTargets.filter { $0.username.lowercased().contains(searchText.lowercased()) }
            }
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

extension SelectFriendsVC: SendVCDelegate {
    func getSelectedFriendIDs() -> [String]? {
//        guard let indexPaths = tableView.indexPathsForSelectedRows else { return nil }
//        let friendIDs = indexPaths.map { FirebaseController.shared.validForwardTargets[$0.row].uid }
//
        //return friendIDs
        return selectedFriendIDs
    }
}

extension SelectFriendsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFriends.count
        }
        
        return FirebaseController.shared.validForwardTargets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendCell else { return UITableViewCell() }
        
        
        if isFiltering() {
            cell.friend = filteredFriends[indexPath.row]
        } else {
            cell.friend = FirebaseController.shared.validForwardTargets[indexPath.row]
        }
        
        if selectedFriendIDs.contains(cell.friend!.uid) {
            cell.checkmark.isHidden = false
        } else {
            cell.checkmark.isHidden = true
        }
        cell.setUpCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendCell else { return }
        
        selectedFriendIDs.append(cell.friend!.uid)
        
        cell.checkmark.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendCell else { return }
        
        selectedFriendIDs = selectedFriendIDs.filter { $0 != cell.friend!.uid }
        
        cell.checkmark.isHidden = true
    }
}
