//
//  GroupsVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/1/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Stevia

class GroupsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroupsStackView: UIStackView!
    
    lazy var backBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    lazy var addGroupBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "plus - anticon"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        btn.addTarget(self, action: #selector(toCreateGroupVC), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    var groups = [Group]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Groups"
        
        tableView.isHidden = true
        
//        FirebaseController.shared.fetchGroups { (groups) in
//            self.groups = groups
//            self.tableView.isHidden = false
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.rightBarButtonItem = addGroupBarButton
        
        FirebaseController.shared.fetchGroups { (groups) in
            self.groups = groups
            self.tableView.isHidden = false
        }
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func toCreateGroupVC() {
        performSegue(withIdentifier: "toCreateGroupVC", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGroupDetailVC" {
            if let groupDetailVC = segue.destination as? GroupDetailVC {
                let group = groups[tableView.indexPathForSelectedRow!.row]
                groupDetailVC.group = group
            }
        }
    }

}

extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupCell else { return UITableViewCell() }
        
        cell.group = groups[indexPath.row]
        cell.setUpViews()
        
        return cell
    }
}
