//
//  InboxVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/18/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class InboxVC: UIViewController {

    let item1 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item2 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item3 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item4 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item5 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item6 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    
    var inboxItems = [InboxItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inboxItems = [item1, item2, item3, item4, item5, item6]
        
        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}

extension InboxVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as? InboxCell else { return UITableViewCell() }
        
        cell.inboxItem = inboxItems[indexPath.row]
        cell.setUpCell()
        cell.delegate = self
        
        return cell
    }
}

extension InboxVC: FullscreenViewDelegate {
    
    func goFullscreen(_ imageView: UIImageView) {
        let fullscreenView = UIImageView(image: imageView.image)
        fullscreenView.frame = UIScreen.main.bounds
        fullscreenView.backgroundColor = .black
        fullscreenView.contentMode = .scaleAspectFit
        fullscreenView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreen))
        fullscreenView.addGestureRecognizer(tapGesture)
        self.view.addSubview(fullscreenView)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func dismissFullscreen(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
}
