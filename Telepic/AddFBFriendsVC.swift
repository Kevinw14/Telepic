//
//  AddFBFriendsVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/6/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import FacebookCore

class AddFBFriendsVC: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    
    var tempFriends = ["Michael Bart", "Stephanie Joyce", "Steve Jobs", "Donald Trump"]
    var avatars = [#imageLiteral(resourceName: "avatar"),#imageLiteral(resourceName: "avatar2"),#imageLiteral(resourceName: "avatar3"),#imageLiteral(resourceName: "avatar4")]
    var friends = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
        
        let connection = GraphRequestConnection()
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
        let request = GraphRequest(graphPath: "me/friends", parameters: params)
        
        connection.add(request) { response, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
            case .failed(let error):
                print("Graph Request Failed: \(error.localizedDescription)")
            }
        }

        connection.start()
//        makeFBRequestToPath(path: "me/taggable_friends", withParameters: params, success: { (results) in
//            print("Found friends are: \(String(describing: results))")
//        }) { (error) in
//            print("Something went wrong: \(String(describing: error?.localizedDescription))")
//        }
        
        
    }
    
//    func makeFBRequestToPath(path: String, withParameters parameters: [String:Any], success successBlock: @escaping ([Any]?) -> (), failure failureBlock: @escaping (Error?) -> ()) {
//        // store results of multiple requests
//        let receivedDataStorage = [Any]()
//
//        // run requests with array to store results in
//        performRequestFromPath(path: path, parameters: parameters, storage: receivedDataStorage, success: successBlock, failure: failureBlock)
//    }
//
//    func performRequestFromPath(path: String, parameters: [String:Any], storage: [Any], success successBlock: @escaping ([Any]?) -> (), failure failureBlock: @escaping (Error?) -> ()) {
//
//        var storage = storage
//        let request = GraphRequest(graphPath: path, parameters: parameters)
//        request.start { (response, result) in
//            switch result {
//            case .success(let response):
//
//                guard let responseDictionary = response.dictionaryValue else { return }
//
//                if let data = responseDictionary["data"] as? [String:Any] {
//
//                    storage.append(data)
//                    if let paging = data["paging"] as? [String:Any] {
//                        if let cursors = paging["cursors"] as? [String:Any] {
//                            if let after = cursors["after"] as? String {
//                                let paramsOfNextPage = ["fields": "id, first_name, last_name, middle_name, name, email, picture", "after": "\(after)"]
//                                self.performRequestFromPath(path: path, parameters: paramsOfNextPage, storage: storage, success: successBlock, failure: failureBlock)
//                                return
//                            }
//                        }
//                    }
//                    successBlock(storage)
//                }
//
//
//
//            case .failed(let error):
//                print("Graph Request Failed: \(error.localizedDescription)")
//                failureBlock(error)
//            }
//        }
//    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
    }
    @IBAction func doneButtonTapped(_ sender: Any) {
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

extension AddFBFriendsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FBFriendCell") as? FBFriendCell else { return UITableViewCell() }
        
        let avatar = avatars[indexPath.row]
        let friendName = tempFriends[indexPath.row]
        
        cell.avatarImageView.image = avatar
        cell.nameLabel.text = friendName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FBFriendCell else { return }
        cell.checkmarkImageView.isHidden = !cell.checkmarkImageView.isHidden

        if !cell.checkmarkImageView.isHidden {
            cell.avatarImageView.alpha = 0.5
            cell.nameLabel.alpha = 0.5
        } else {
            cell.avatarImageView.alpha = 1
            cell.nameLabel.alpha = 1
        }
        
    }
}
