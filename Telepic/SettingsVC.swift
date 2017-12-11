//
//  SettingsVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/3/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Stevia

class SettingsVC: UITableViewController {

    lazy var backBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    var user: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInsetAdjustmentBehavior = .never

        self.navigationItem.title = "Settings"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let titleAttrs = [
            NSAttributedStringKey.foregroundColor: UIColor(hexString: "333333"),
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttrs
        
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "logoutCell" {
            
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
                print("log out")
                do {
                    try Auth.auth().signOut()
                    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    self.present(loginVC!, animated: true, completion: nil)
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cance", style: .cancel, handler: { (_) in
                
                self.tableView.deselectRow(at: indexPath, animated: false)
            }))
            present(alertController, animated: true, completion: nil)
        }
        
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "changePasswordCell" {
            let alertController = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Current Password"
            })
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "New Password"
            })
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Confirm New Password"
            })
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                print("save password")
            }))
            alertController.addAction(UIAlertAction(title: "Cance", style: .cancel, handler: { (_) in
                
                self.tableView.deselectRow(at: indexPath, animated: false)
            }))
            present(alertController, animated: true, completion: nil)
        }
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        return
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toEditProfileVC" {
            if let destination = segue.destination as? EditProfileVC, let user = user {
                let username = user["username"] as! String
                let bio = user["bio"] as? String ?? "Edit your bio."
                destination.username = username
                destination.bio = bio
            }
        }
    }

}
