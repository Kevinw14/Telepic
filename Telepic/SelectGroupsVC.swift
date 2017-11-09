//
//  SelectGroupsVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/3/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class SelectGroupsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var groups = [Group]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        FirebaseController.shared.fetchGroups { (groups) in
            self.groups = groups
        }
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

extension SelectGroupsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupCell else { return UITableViewCell() }
        
        cell.group = groups[indexPath.row]
        cell.setUpViews()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GroupCell else { return }
        
        cell.groupNameLabel.textColor = UIColor(hexString: "ffffff")
        cell.contentView.backgroundColor = UIColor(hexString: "10BB6C")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GroupCell else { return }
        
        cell.groupNameLabel.textColor = UIColor(hexString: "333333")
        cell.contentView.backgroundColor = UIColor(hexString: "ffffff")
    }
    
}

extension SelectGroupsVC: SendVCDelegate {
    func getSelectedFriendIDs() -> [String]? {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return nil }
        let selectedGroups = indexPaths.map { self.groups[$0.row] }
        let selectedFriends = selectedGroups.flatMap { $0.members }
        let selectedFriendIDs = selectedFriends.map { $0.uid }
        
        return Array(Set(selectedFriendIDs))
    }
}
